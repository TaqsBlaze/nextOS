#!/bin/bash
set -e

echo "==============================="
echo "NextOS Complete Build Script"
echo "==============================="

# -----------------------------
# Directories
# -----------------------------
PROJECT_DIR=$(pwd)
KERNEL_DIR="$PROJECT_DIR/linux-6.19"
ROOTFS_DIR="$PROJECT_DIR/rootfs"
INITRAMFS_DIR="$PROJECT_DIR/initramfs"
BOOT_DIR="$PROJECT_DIR/boot"
ISO_DIR="$PROJECT_DIR/iso"
BUILD_DIR="$PROJECT_DIR/build"
MNT_DIR="$BUILD_DIR/mnt"
ISO_OUT="$PROJECT_DIR/Next-OS.iso"

KERNEL_VERSION="6.19"

# -----------------------------
# 1️ Build Kernel
# -----------------------------
echo "[1/6] Building kernel..."
cd "$KERNEL_DIR"

make olddefconfig
make -j$(nproc)

cp arch/x86/boot/bzImage "$BOOT_DIR/vmlinuz"

echo "Kernel built and copied."

# -----------------------------
# 2️ Install Kernel Modules
# -----------------------------
echo "[2/6] Installing kernel modules..."
make modules_install INSTALL_MOD_PATH="$ROOTFS_DIR"
cd "$PROJECT_DIR"

# -----------------------------
# 3️ Install Bash into rootfs
# -----------------------------
echo "[3/6] Installing bash into rootfs..."

mkdir -p "$ROOTFS_DIR/bin"
cp /bin/bash "$ROOTFS_DIR/bin/"

# Copy required libraries
for lib in $(ldd /bin/bash | awk '{print $3}' | grep "/"); do
    mkdir -p "$ROOTFS_DIR$(dirname $lib)"
    cp "$lib" "$ROOTFS_DIR$lib"
done

# Add basic filesystem structure
mkdir -p "$ROOTFS_DIR"/{dev,proc,sys,etc}

# Create minimal passwd
echo "root:x:0:0:root:/root:/bin/bash" | tee "$ROOTFS_DIR/etc/passwd"

echo "Bash installed."

# -----------------------------
# 4️ Build initramfs
# -----------------------------
echo "[4/6] Building initramfs..."

cd "$INITRAMFS_DIR"
find . -print0 | cpio --null -ov --format=newc | gzip -9 > "$BOOT_DIR/initramfs.img"
cd "$PROJECT_DIR"

echo "Initramfs created."

# Note: Rootfs image creation requires sudo/loop device
# For now, we boot from initramfs only (RAM-based root)
# To create rootfs.img, run:
#   sudo dd if=/dev/zero of=boot/rootfs.img bs=1M count=120
#   sudo mkfs.ext4 -F boot/rootfs.img
#   sudo mount -o loop boot/rootfs.img build/mnt
#   sudo cp -a rootfs/. build/mnt/
#   sudo umount build/mnt

echo "[5/6] Skipping rootfs image (using initramfs-only boot)..."

# -----------------------------
# 6️ Build ISO
# -----------------------------
echo "[6/6] Building ISO..."

mkdir -p "$ISO_DIR/boot/grub"

cp "$BOOT_DIR/vmlinuz" "$ISO_DIR/boot/"
cp "$BOOT_DIR/initramfs.img" "$ISO_DIR/boot/"

cat > "$ISO_DIR/boot/grub/grub.cfg" <<EOF
set timeout=5
set default=0

menuentry "NextOS" {
    linux /boot/vmlinuz root=/dev/ram0 rw quiet
    initrd /boot/initramfs.img
}

menuentry "NextOS (Verbose)" {
    linux /boot/vmlinuz root=/dev/ram0 rw
    initrd /boot/initramfs.img
}
EOF

grub-mkrescue -o "$ISO_OUT" "$ISO_DIR"

echo "==============================="
echo "NextOS build complete!"
echo "ISO created at: $ISO_OUT"
echo "==============================="
