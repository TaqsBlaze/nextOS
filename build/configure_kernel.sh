#!/bin/bash
set -e

echo "==============================="
echo "NextOS Kernel Quick Config"
echo "==============================="
echo ""

if [ ! -f Makefile ] || [ ! -d arch ]; then
    echo "❌ ERROR: Run this from the kernel source directory (linux-6.19/)"
    exit 1
fi

echo "📋 Creating optimized NextOS kernel config..."
echo ""

# Start with minimal config
echo "1️⃣  Using defconfig as base..."
make defconfig

# Enable essential features
echo "2️⃣  Enabling NextOS essentials..."
scripts/config \
    --enable CONFIG_DEVTMPFS \
    --enable CONFIG_DEVTMPFS_MOUNT \
    --enable CONFIG_BLK_DEV_INITRD \
    --enable CONFIG_RD_GZIP \
    --enable CONFIG_EXT4_FS \
    --enable CONFIG_ISO9660_FS \
    --enable CONFIG_JOLIET \
    --enable CONFIG_PROC_FS \
    --enable CONFIG_SYSFS \
    --enable CONFIG_TMPFS

# Disable debug bloat
echo "3️⃣  Removing debug bloat..."
scripts/config \
    --disable CONFIG_DEBUG_KERNEL \
    --disable CONFIG_DEBUG_INFO \
    --disable CONFIG_DEBUG_INFO_DWARF4 \
    --disable CONFIG_DEBUG_INFO_BTF

# Performance optimizations
echo "4️⃣  Applying performance optimizations..."
scripts/config \
    --enable CONFIG_PREEMPT \
    --set-val CONFIG_HZ 1000

# Disable unnecessary features
echo "5️⃣  Disabling unnecessary features..."
scripts/config \
    --disable CONFIG_WIRELESS \
    --disable CONFIG_WLAN \
    --disable CONFIG_BT \
    --disable CONFIG_SOUND

# Apply changes
make olddefconfig

echo ""
echo "✅ NextOS kernel configuration complete!"
echo ""
echo "Configuration optimized for:"
echo "  • Fast boot"
echo "  • Low memory footprint"
echo "  • ISO support"
echo "  • Minimal bloat"
echo ""
echo "Next steps:"
echo "  make -j\$(nproc)          # Build kernel (~20-40 min)"
echo "  cd .. && ./full-build.sh  # Build complete OS"
echo ""
echo "Or customize further:"
echo "  make menuconfig           # Manual tweaking"
