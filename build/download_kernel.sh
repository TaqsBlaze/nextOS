#!/bin/bash
set -e

echo "==============================="
echo "NextOS Kernel Source Setup"
echo "==============================="
echo ""

KERNEL_VERSION="6.19"
KERNEL_TARBALL="linux-${KERNEL_VERSION}.tar.xz"
KERNEL_URL="https://cdn.kernel.org/pub/linux/kernel/v6.x/${KERNEL_TARBALL}"

# Check if already downloaded
if [ -d "linux-${KERNEL_VERSION}" ]; then
    echo "✅ Kernel source already exists: linux-${KERNEL_VERSION}/"
    exit 0
fi

# Download
echo "📥 Downloading Linux ${KERNEL_VERSION} kernel source..."
echo "URL: ${KERNEL_URL}"
echo ""

if command -v wget &> /dev/null; then
    wget -c "${KERNEL_URL}"
elif command -v curl &> /dev/null; then
    curl -C - -O "${KERNEL_URL}"
else
    echo "❌ ERROR: Neither wget nor curl found. Please install one of them."
    exit 1
fi

# Extract
echo ""
echo "📦 Extracting kernel source..."
tar xf "${KERNEL_TARBALL}"

# Cleanup
echo "🧹 Cleaning up tarball..."
rm "${KERNEL_TARBALL}"

echo ""
echo "✅ Kernel source ready: linux-${KERNEL_VERSION}/"
echo ""
echo "Next steps:"
echo "  1. Configure kernel: cd linux-${KERNEL_VERSION} && make menuconfig"
echo "  2. Build everything: ./full-build.sh"
echo ""
echo "Or use default config and build immediately:"
echo "  cd linux-${KERNEL_VERSION} && make olddefconfig && cd .."
echo "  ./full-build.sh"
