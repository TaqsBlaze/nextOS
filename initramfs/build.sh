#!/bin/bash
set -e

INITRAMFS_DIR=$(pwd)
BOOT_DIR="../boot"

echo "Building initramfs from: $INITRAMFS_DIR"
echo ""

# Ensure permissions are set
chmod 755 $INITRAMFS_DIR
chmod 755 $INITRAMFS_DIR/bin
chmod 755 $INITRAMFS_DIR/init
chmod 755 $INITRAMFS_DIR/bin/*

echo "Creating initramfs.img..."

# Build using find + cpio with explicit format
find . -print0 | cpio --null -ov --format=newc 2>&1 | grep -E "^(.|init)" | head -10

# Redirect to file
find . -print0 | cpio --null -ov --format=newc 2>/dev/null | gzip -9 > $BOOT_DIR/initramfs.img

SIZE=$(stat -c%s $BOOT_DIR/initramfs.img)
echo ""
echo "✅ Initramfs built: $BOOT_DIR/initramfs.img"
echo "   Size: $(numfmt --to=iec $SIZE 2>/dev/null || echo $SIZE' bytes')"
echo ""

# Verify the archive
echo "Verifying archive contents..."
zcat $BOOT_DIR/initramfs.img | cpio -t 2>/dev/null | head -10
echo "..."
zcat $BOOT_DIR/initramfs.img | cpio -t 2>/dev/null | tail -5
