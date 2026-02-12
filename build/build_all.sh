#!/bin/sh
set -e

echo "==============================="
echo "next OS Full Build Script"
echo "==============================="

# -------------------------------
# Variables
# -------------------------------
ROOTFS_DIR=rootfs
INITRAMFS_DIR=initramfs
BOOT_DIR=boot
ISO_DIR=iso
MNT_DIR=build/mnt
ISO_OUT=Next-OS.iso
IMG_SIZE=60M

# -------------------------------
# 1️⃣ Check kernel
# -------------------------------
if [ ! -f "$BOOT_DIR/vmlinuz" ]; then
    echo "ERROR: Kernel not found at $BOOT_DIR/vmlinuz"
    echo "Copy a host kernel or a prebuilt kernel to $BOOT_DIR/vmlinuz"
    exit 1
fi

# -------------------------------
# 2️⃣ Build rootfs image
# -------------------------------
echo "[1/4] Building root filesystem..."
rm -f "$BOOT_DIR/rootfs.img"
mkdir -p "$MNT_DIR"
dd if=/dev/zero of="$BOOT_DIR/rootfs.img" bs=1M count=50
mkfs.ext4 -F "$BOOT_DIR/rootfs.img"
sudo mount -o loop "$BOOT_DIR/rootfs.img" "$MNT_DIR"
sudo cp -a "$ROOTFS_DIR/." "$MNT_DIR/"
sudo chown -R root:root "$MNT_DIR"
sudo umount "$MNT_DIR"
rmdir "$MNT_DIR"
echo "Rootfs image created: $BOOT_DIR/rootfs.img"

# -------------------------------
# 3️⃣ Build initramfs
# -------------------------------
echo "[2/4] Building initramfs..."
cd "$INITRAMFS_DIR"
find . -print0 | cpio --null -ov --format=newc | gzip -9 > "../$BOOT_DIR/initramfs.img"
cd ..
echo "Initramfs image created: $BOOT_DIR/initramfs.img"

# -------------------------------
# 4️⃣ Prepare ISO staging
# -------------------------------
echo "[3/4] Preparing ISO staging area..."
mkdir -p "$ISO_DIR/boot"
cp -f "$BOOT_DIR/vmlinuz" "$ISO_DIR/boot/"
cp -f "$BOOT_DIR/initramfs.img" "$ISO_DIR/boot/"
cp -r "$ISO_DIR/boot" "$ISO_DIR/boot" 2>/dev/null || true
# Make sure grub.cfg exists
if [ ! -f "$ISO_DIR/boot/grub/grub.cfg" ]; then
    mkdir -p "$ISO_DIR/boot/grub"
    cat > "$ISO_DIR/boot/grub/grub.cfg" <<EOF
set timeout=3
set default=0

menuentry "Next OS" {
    linux /boot/vmlinuz
    initrd /boot/initramfs.img
}
EOF
fi
echo "ISO staging ready."

# -------------------------------
# 5️⃣ Build ISO
# -------------------------------
echo "[4/4] Building ISO..."
grub-mkrescue -o "$ISO_OUT" "$ISO_DIR" || {
    echo "ERROR: grub-mkrescue failed. Make sure xorriso and grub packages are installed."
    exit 1
}
echo "ISO build complete: $ISO_OUT"
echo "==============================="
echo "nextOS build finished successfully!"
