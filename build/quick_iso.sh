#!/bin/bash
set -e

echo "==============================="
echo "NextOS Quick ISO Builder"
echo "==============================="
echo ""
echo "This script builds a bootable ISO from existing boot artifacts."
echo "Prerequisites: boot/vmlinuz and boot/initramfs.img must exist."
echo ""

# Check prerequisites
if [ ! -f boot/vmlinuz ]; then
    echo "❌ ERROR: boot/vmlinuz not found"
    echo "Run './full-build.sh' first to build the kernel"
    exit 1
fi

if [ ! -f boot/initramfs.img ]; then
    echo "❌ ERROR: boot/initramfs.img not found"
    echo "Run './build/build_initramfs.sh' to build initramfs"
    exit 1
fi

# Clean and prepare ISO structure
echo "📁 Preparing ISO structure..."
rm -rf iso/boot
mkdir -p iso/boot/grub

# Copy boot files
echo "📦 Copying boot artifacts..."
cp boot/vmlinuz iso/boot/
cp boot/initramfs.img iso/boot/

# Create GRUB config
echo "⚙️  Creating GRUB configuration..."
cat > iso/boot/grub/grub.cfg <<'EOF'
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

# Build ISO
echo "🔨 Building ISO with grub-mkrescue..."
ISO_OUT="NextOS.iso"
grub-mkrescue -o "$ISO_OUT" iso/ 2>&1 | grep -v "warning: Couldn't find" || true

if [ -f "$ISO_OUT" ]; then
    SIZE=$(du -h "$ISO_OUT" | cut -f1)
    echo ""
    echo "✅ ISO built successfully!"
    echo "📀 File: $ISO_OUT"
    echo "📊 Size: $SIZE"
    echo ""
    echo "To test in QEMU:"
    echo "  qemu-system-x86_64 -cdrom $ISO_OUT -m 512M"
else
    echo "❌ ISO build failed"
    exit 1
fi
