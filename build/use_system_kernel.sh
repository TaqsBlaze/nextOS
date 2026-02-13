#!/bin/bash
set -e

echo "==============================="
echo "NextOS System Kernel Setup"
echo "==============================="
echo ""
echo "Copying system kernel to NextOS boot directory..."

# Copy system kernel
sudo cp /boot/vmlinuz boot/vmlinuz
sudo chown $USER:$USER boot/vmlinuz

echo "✅ System kernel copied to boot/vmlinuz"
echo ""
echo "You can now build the ISO with:"
echo "  ./build/quick_iso.sh"
echo ""
echo "Or run the full build (skip kernel compilation):"
echo "  ./build/build_all.sh"
