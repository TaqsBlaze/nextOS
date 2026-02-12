#!/bin/sh

set -e

ROOTFS_DIR=rootfs
OUT_IMG=boot/rootfs.img

echo "Building Next OS root filesystem..."

# Remove old image if exists
rm -f "$OUT_IMG"

# Calculate size (rough estimate, adjust as needed)
# 50 MB is fine for a hobby minimal rootfs
IMG_SIZE=50M

# Create empty image file
echo "Creating empty image file of size $IMG_SIZE..."
dd if=/dev/zero of="$OUT_IMG" bs=1M count=50

# Format as ext4
echo "Formatting image as ext4..."
mkfs.ext4 -F "$OUT_IMG"

# Mount image temporarily
MNT_DIR=build/mnt
mkdir -p "$MNT_DIR"
sudo mount -o loop "$OUT_IMG" "$MNT_DIR"

# Copy rootfs contents
echo "Copying rootfs contents..."
sudo cp -a "$ROOTFS_DIR/." "$MNT_DIR/"

# Set proper permissions (root owned)
sudo chown -R root:root "$MNT_DIR"

# Unmount image
sudo umount "$MNT_DIR"
rmdir "$MNT_DIR"

echo "Root filesystem image created at $OUT_IMG"
