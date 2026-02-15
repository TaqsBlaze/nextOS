#!/bin/bash
# =============================================================
#  NextOS — Master Build Script
#  Usage: ./full-build.sh [--skip-kernel] [--skip-rootfs]
# =============================================================
set -euo pipefail

# ── Colour helpers ────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'
info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
ok()      { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
die()     { echo -e "${RED}[FATAL]${RESET} $*" >&2; exit 1; }
step()    { echo -e "\n${BOLD}${GREEN}[$1/6] $2${RESET}"; }

# ── Argument parsing ─────────────────────────────────────────
SKIP_KERNEL=0
SKIP_ROOTFS_IMG=0
for arg in "$@"; do
    case "$arg" in
        --skip-kernel)       SKIP_KERNEL=1 ;;
        --skip-rootfs)       SKIP_ROOTFS_IMG=1 ;;
        --help|-h)
            echo "Usage: $0 [--skip-kernel] [--skip-rootfs]"
            echo "  --skip-kernel   Re-use existing vmlinuz (saves ~10 min)"
            echo "  --skip-rootfs   Skip rootfs.img creation (needs sudo)"
            exit 0
            ;;
    esac
done

# ── Paths ─────────────────────────────────────────────────────
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KERNEL_VERSION="6.19"
KERNEL_DIR="$PROJECT_DIR/linux-${KERNEL_VERSION}"
ROOTFS_DIR="$PROJECT_DIR/rootfs"
INITRAMFS_DIR="$PROJECT_DIR/initramfs"
BOOT_DIR="$PROJECT_DIR/boot"
ISO_DIR="$PROJECT_DIR/iso"
BUILD_DIR="$PROJECT_DIR/build"
MNT_DIR="$BUILD_DIR/mnt"
GRUB_SRC="$PROJECT_DIR/grub"
BANNER_SRC="$PROJECT_DIR/banner/nexOS2.png"
ISO_OUT="$PROJECT_DIR/Next-OS.iso"

# ── Prerequisite check ────────────────────────────────────────
info "Checking build prerequisites..."
MISSING=""
for cmd in make cpio gzip grub-mkrescue xorriso mformat; do
    command -v "$cmd" >/dev/null 2>&1 || MISSING="$MISSING $cmd"
done
[ -n "$MISSING" ] && die "Missing tools:$MISSING\n  Run: sudo apt install build-essential grub-pc-bin grub-efi-amd64-bin xorriso mtools"

echo -e "${BOLD}"
echo "========================================"
echo "   NextOS Complete Build"
echo "   Project: $PROJECT_DIR"
echo "   Kernel:  $KERNEL_VERSION"
echo "========================================"
echo -e "${RESET}"

# ── Create required directories ───────────────────────────────
mkdir -p "$BOOT_DIR" "$MNT_DIR"

# =============================================================
# STEP 1 — Build Kernel
# =============================================================
step 1 "Building kernel ${KERNEL_VERSION}..."

if [ "$SKIP_KERNEL" = "1" ]; then
    warn "Skipping kernel build (--skip-kernel passed)"
    [ -f "$BOOT_DIR/vmlinuz" ] || die "No existing vmlinuz found at $BOOT_DIR/vmlinuz"
else
    [ -d "$KERNEL_DIR" ] || die "Kernel source not found at $KERNEL_DIR\n  Run: build/download_kernel.sh"

    cd "$KERNEL_DIR"

    # Use olddefconfig to preserve existing config, then ensure
    # the following options are enabled for ISO boot + switch_root:
    #   CONFIG_ISO9660_FS=y   — read the boot ISO
    #   CONFIG_BLK_DEV_LOOP=y — loop-mount rootfs.img
    #   CONFIG_EXT4_FS=y      — rootfs filesystem
    #   CONFIG_DEVTMPFS=y     — automatic /dev population
    #   CONFIG_DEVTMPFS_MOUNT=y
    #   CONFIG_FB_VESA=y      — GRUB framebuffer handoff
    info "Applying kernel config..."
    make olddefconfig

    # Patch critical options in (non-destructive)
    scripts/config \
        --enable  CONFIG_ISO9660_FS \
        --enable  CONFIG_BLK_DEV_LOOP \
        --enable  CONFIG_EXT4_FS \
        --enable  CONFIG_DEVTMPFS \
        --enable  CONFIG_DEVTMPFS_MOUNT \
        --enable  CONFIG_FB_VESA \
        --enable  CONFIG_FRAMEBUFFER_CONSOLE \
        --disable CONFIG_ISO9660_FS_MODULE \
        --disable CONFIG_BLK_DEV_LOOP_MODULE

    info "Building kernel (using $(nproc) threads)..."
    make -j"$(nproc)"

    cp arch/x86/boot/bzImage "$BOOT_DIR/vmlinuz"
    ok "Kernel built → $BOOT_DIR/vmlinuz"

    cd "$PROJECT_DIR"
fi

# =============================================================
# STEP 2 — Install Kernel Modules into rootfs
# =============================================================
step 2 "Installing kernel modules into rootfs..."

if [ "$SKIP_KERNEL" = "0" ]; then
    cd "$KERNEL_DIR"
    make modules_install INSTALL_MOD_PATH="$ROOTFS_DIR"
    # Remove build/source symlinks (they point to build host paths)
    find "$ROOTFS_DIR/lib/modules" -maxdepth 2 \
        \( -name build -o -name source \) -type l -delete 2>/dev/null || true
    ok "Modules installed into $ROOTFS_DIR/lib/modules/"
    cd "$PROJECT_DIR"
else
    warn "Skipping module install (kernel build was skipped)"
fi

# =============================================================
# STEP 3 — Populate rootfs
# =============================================================
step 3 "Populating rootfs with bash and libraries..."

mkdir -p "$ROOTFS_DIR"/{bin,sbin,lib,lib64,dev,proc,sys,etc,tmp,run}

# ── Bash ──────────────────────────────────────────────────────
cp /bin/bash "$ROOTFS_DIR/bin/bash"

# Copy all shared library dependencies for bash
copy_libs() {
    local binary="$1"
    local dest_root="$2"
    # Extract all .so paths from ldd output (handles symlinks and direct paths)
    ldd "$binary" 2>/dev/null | grep -oP '(/[a-zA-Z0-9_./-]+\.so[.0-9]*)' | sort -u | \
    while read -r lib; do
        [ -f "$lib" ] || continue
        local dest_dir="$dest_root$(dirname "$lib")"
        mkdir -p "$dest_dir"
        # -L: follow symlinks so we get the real .so file
        cp -L "$lib" "$dest_dir/" 2>/dev/null || true
        # Also copy the canonical symlink name if it differs
        local linkname
        linkname=$(basename "$lib")
        [ -f "$dest_dir/$linkname" ] || cp "$lib" "$dest_dir/$linkname" 2>/dev/null || true
    done

    # Copy the ELF dynamic linker (ld-linux) explicitly
    local interp
    interp=$(patchelf --print-interpreter "$binary" 2>/dev/null || \
             readelf -l "$binary" 2>/dev/null | grep -oP '\[.+ld[^]]+\]' | tr -d '[]')
    if [ -n "$interp" ] && [ -f "$interp" ]; then
        local dest_dir="$dest_root$(dirname "$interp")"
        mkdir -p "$dest_dir"
        cp -L "$interp" "$dest_dir/"
    fi
}
copy_libs /bin/bash "$ROOTFS_DIR"

# ── /sbin/init (our PID 1 script) ────────────────────────────
# This file must exist in rootfs — switch_root calls it
if [ -f "$PROJECT_DIR/rootfs/sbin/init" ]; then
    chmod +x "$ROOTFS_DIR/sbin/init"
    ok "/sbin/init present in rootfs"
else
    die "MISSING: rootfs/sbin/init — create it before building.\n  See: docs/BUILD_SYSTEM.md"
fi

# ── Minimal /etc ─────────────────────────────────────────────
if [ ! -f "$ROOTFS_DIR/etc/passwd" ]; then
    {
        echo "root:x:0:0:root:/root:/bin/bash"
        echo "user:x:1000:1000:NextOS User:/home/user:/bin/bash"
    } > "$ROOTFS_DIR/etc/passwd"
fi

if [ ! -f "$ROOTFS_DIR/etc/group" ]; then
    {
        echo "root:x:0:"
        echo "user:x:1000:"
    } > "$ROOTFS_DIR/etc/group"
fi

if [ ! -f "$ROOTFS_DIR/etc/hostname" ]; then
    echo "nexos" > "$ROOTFS_DIR/etc/hostname"
fi

if [ ! -f "$ROOTFS_DIR/etc/profile" ]; then
    cat > "$ROOTFS_DIR/etc/profile" <<'PROFILE'
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
export HOME=/root
PROFILE
fi

ok "rootfs populated"

# =============================================================
# STEP 4 — Build initramfs
# =============================================================
step 4 "Building initramfs..."

# Ensure the init script is executable
[ -x "$INITRAMFS_DIR/init" ] || chmod +x "$INITRAMFS_DIR/init"

# Verify busybox is a static binary (required for initramfs)
if file "$INITRAMFS_DIR/bin/busybox" | grep -q "dynamically"; then
    warn "busybox appears to be dynamically linked!"
    warn "initramfs should use a STATIC busybox. Download from busybox.net."
fi

# Verify switch_root symlink exists in initramfs
if [ ! -e "$INITRAMFS_DIR/bin/switch_root" ]; then
    warn "Missing busybox symlink: bin/switch_root — adding it"
    (cd "$INITRAMFS_DIR/bin" && ln -sf busybox switch_root)
fi

# Same for losetup (needed to attach loop device in init)
if [ ! -e "$INITRAMFS_DIR/bin/losetup" ]; then
    warn "Missing busybox symlink: bin/losetup — adding it"
    (cd "$INITRAMFS_DIR/bin" && ln -sf busybox losetup)
fi

# Build the cpio archive
cd "$INITRAMFS_DIR"
find . -print0 | cpio --null -ov --format=newc | gzip -9 > "$BOOT_DIR/initramfs.img"
cd "$PROJECT_DIR"

ok "initramfs built → $BOOT_DIR/initramfs.img ($(du -sh "$BOOT_DIR/initramfs.img" | cut -f1))"

# =============================================================
# STEP 5 — Build rootfs image
# =============================================================
step 5 "Building rootfs.img (requires sudo)..."

if [ "$SKIP_ROOTFS_IMG" = "1" ]; then
    warn "Skipping rootfs.img creation (--skip-rootfs passed)"
    if [ ! -f "$BOOT_DIR/rootfs.img" ]; then
        warn "No existing rootfs.img — ISO will boot to emergency shell only."
    fi
else
    # Check sudo availability
    if ! sudo -n true 2>/dev/null && ! sudo -v 2>/dev/null; then
        warn "sudo not available. Skipping rootfs.img."
        warn "To build it manually:"
        warn "  sudo dd if=/dev/zero of=$BOOT_DIR/rootfs.img bs=1M count=256"
        warn "  sudo mkfs.ext4 -F -L nexos-root $BOOT_DIR/rootfs.img"
        warn "  sudo mount -o loop $BOOT_DIR/rootfs.img $MNT_DIR"
        warn "  sudo cp -a $ROOTFS_DIR/. $MNT_DIR/"
        warn "  sudo umount $MNT_DIR"
    else
        ROOTFS_SIZE_MB=256
        info "Creating ${ROOTFS_SIZE_MB}MB ext4 rootfs image..."
        sudo dd if=/dev/zero of="$BOOT_DIR/rootfs.img" bs=1M count="$ROOTFS_SIZE_MB" status=progress
        sudo mkfs.ext4 -F -L "nexos-root" "$BOOT_DIR/rootfs.img"

        info "Populating rootfs image..."
        sudo mount -o loop "$BOOT_DIR/rootfs.img" "$MNT_DIR"
        sudo cp -a "$ROOTFS_DIR/." "$MNT_DIR/"
        sudo umount "$MNT_DIR"

        ok "rootfs.img created → $BOOT_DIR/rootfs.img ($(du -sh "$BOOT_DIR/rootfs.img" | cut -f1))"
    fi
fi

# =============================================================
# STEP 6 — Build ISO
# =============================================================
step 6 "Building ISO..."

# ── CRITICAL: Clean the ISO staging dir each time ────────────
# Without this, re-runs accumulate nested boot/boot/boot/... directories!
info "Cleaning ISO staging directory..."
rm -rf "$ISO_DIR"
mkdir -p "$ISO_DIR/boot/grub/themes/nexos" \
         "$ISO_DIR/boot/grub/fonts"

# ── Stage boot files ─────────────────────────────────────────
cp "$BOOT_DIR/vmlinuz"       "$ISO_DIR/boot/"
cp "$BOOT_DIR/initramfs.img" "$ISO_DIR/boot/"

# rootfs.img is optional (boot still works, just stays in initramfs)
if [ -f "$BOOT_DIR/rootfs.img" ]; then
    cp "$BOOT_DIR/rootfs.img" "$ISO_DIR/boot/"
    ok "rootfs.img staged into ISO"
else
    warn "rootfs.img not found — ISO will not switch_root"
fi

# ── Stage GRUB config ────────────────────────────────────────
if [ -f "$GRUB_SRC/grub.cfg" ]; then
    cp "$GRUB_SRC/grub.cfg" "$ISO_DIR/boot/grub/"
    ok "grub.cfg staged from $GRUB_SRC/"
else
    # Fallback: generate minimal grub.cfg inline
    warn "grub/ source directory not found, generating minimal grub.cfg"
    cat > "$ISO_DIR/boot/grub/grub.cfg" <<'GRUBEOF'
set timeout=10
set default=0
insmod all_video
insmod gfxterm
insmod png
set gfxmode=1024x768,auto
terminal_output gfxterm
if background_image /boot/grub/nexOS2.png ; then true ; fi
menuentry "NextOS" {
    linux  /boot/vmlinuz root=/dev/ram0 rw quiet nexos.rootfs=/boot/rootfs.img
    initrd /boot/initramfs.img
}
menuentry "NextOS (Verbose)" {
    linux  /boot/vmlinuz root=/dev/ram0 rw nexos.rootfs=/boot/rootfs.img
    initrd /boot/initramfs.img
}
GRUBEOF
fi

# ── Stage GRUB theme ─────────────────────────────────────────
if [ -d "$GRUB_SRC/themes/nexos" ]; then
    cp -r "$GRUB_SRC/themes/nexos/." "$ISO_DIR/boot/grub/themes/nexos/"
    ok "GRUB theme staged"
else
    warn "GRUB theme directory not found at $GRUB_SRC/themes/nexos"
    warn "Create it to enable the custom boot UI"
fi

# ── Stage background image ───────────────────────────────────
if [ -f "$BANNER_SRC" ]; then
    cp "$BANNER_SRC" "$ISO_DIR/boot/grub/"
    # Also copy into theme directory if it exists
    [ -d "$ISO_DIR/boot/grub/themes/nexos" ] && \
        cp "$BANNER_SRC" "$ISO_DIR/boot/grub/themes/nexos/"
    ok "Banner image staged"
else
    warn "Banner image not found at $BANNER_SRC"
fi

# ── Embed GRUB unicode font (for theme text rendering) ────────
UNICODE_FONT=""
for f in \
    /usr/share/grub/unicode.pf2 \
    /usr/share/grub2/unicode.pf2 \
    /boot/grub/fonts/unicode.pf2; do
    [ -f "$f" ] && UNICODE_FONT="$f" && break
done
if [ -n "$UNICODE_FONT" ]; then
    cp "$UNICODE_FONT" "$ISO_DIR/boot/grub/fonts/"
    ok "GRUB unicode font staged"
else
    warn "unicode.pf2 not found — install grub-common or grub2-common"
fi

# ── Run grub-mkrescue ────────────────────────────────────────
info "Running grub-mkrescue..."
grub-mkrescue \
    --output="$ISO_OUT" \
    "$ISO_DIR" \
    -- \
    -volid "NEXTOS" \
    -joliet \
    -joliet-long

ok "ISO created → $ISO_OUT ($(du -sh "$ISO_OUT" | cut -f1))"

# =============================================================
# Summary
# =============================================================
echo ""
echo -e "${BOLD}${GREEN}========================================"
echo "   NextOS build complete!"
echo "========================================"
echo -e "${RESET}"
echo "  ISO:        $ISO_OUT"
echo "  Kernel:     $BOOT_DIR/vmlinuz"
echo "  initramfs:  $BOOT_DIR/initramfs.img"
[ -f "$BOOT_DIR/rootfs.img" ] && \
echo "  rootfs:     $BOOT_DIR/rootfs.img"
echo ""
echo "  Test with QEMU:"
echo "    qemu-system-x86_64 -m 512M -cdrom $ISO_OUT -boot d"
echo ""
echo "  Test with VirtualBox:"
echo "    See build/setup_virtualbox.sh"
echo ""
