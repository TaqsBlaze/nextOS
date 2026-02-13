#!/bin/bash
set -e

echo "==============================="
echo "NextOS Test Suite"
echo "==============================="
echo ""

FAILED=0
PASSED=0

# Test 1: Check if kernel config exists
test_kernel_config() {
    echo "Test 1: Kernel configuration..."
    if [ -f "linux-6.19/.config" ]; then
        echo "  ✅ PASS: Kernel config found"
        PASSED=$((PASSED + 1))
    else
        echo "  ❌ FAIL: Kernel config not found"
        FAILED=$((FAILED + 1))
    fi
}

# Test 2: Check if kernel was built
test_kernel_build() {
    echo "Test 2: Kernel binary..."
    if [ -f "boot/vmlinuz" ]; then
        SIZE=$(stat -c%s boot/vmlinuz)
        echo "  ✅ PASS: Kernel binary found ($(numfmt --to=iec $SIZE 2>/dev/null || echo $SIZE bytes))"
        PASSED=$((PASSED + 1))
    else
        echo "  ❌ FAIL: Kernel binary not found"
        FAILED=$((FAILED + 1))
    fi
}

# Test 3: Check if initramfs exists
test_initramfs() {
    echo "Test 3: Initramfs..."
    if [ -f "boot/initramfs.img" ]; then
        SIZE=$(stat -c%s boot/initramfs.img)
        echo "  ✅ PASS: Initramfs found ($(numfmt --to=iec $SIZE 2>/dev/null || echo $SIZE bytes))"
        PASSED=$((PASSED + 1))
    else
        echo "  ❌ FAIL: Initramfs not found"
        FAILED=$((FAILED + 1))
    fi
}

# Test 4: Check if ISO was built
test_iso() {
    echo "Test 4: ISO image..."
    ISO_FILE=$(ls -1 *.iso 2>/dev/null | head -1)
    if [ -n "$ISO_FILE" ]; then
        SIZE=$(stat -c%s "$ISO_FILE")
        echo "  ✅ PASS: ISO found - $ISO_FILE ($(numfmt --to=iec $SIZE 2>/dev/null || echo $SIZE bytes))"
        PASSED=$((PASSED + 1))
    else
        echo "  ❌ FAIL: No ISO found"
        FAILED=$((FAILED + 1))
    fi
}

# Test 5: Check initramfs contents
test_initramfs_contents() {
    echo "Test 5: Initramfs contents..."
    if zcat boot/initramfs.img 2>/dev/null | cpio -t 2>/dev/null | grep -q "^init$"; then
        echo "  ✅ PASS: /init found in initramfs"
        PASSED=$((PASSED + 1))
    else
        echo "  ❌ FAIL: /init not found in initramfs"
        FAILED=$((FAILED + 1))
    fi
}

# Test 6: Check if busybox is in initramfs
test_busybox() {
    echo "Test 6: Busybox in initramfs..."
    if zcat boot/initramfs.img 2>/dev/null | cpio -t 2>/dev/null | grep -q "^bin/busybox$"; then
        echo "  ✅ PASS: Busybox found in initramfs"
        PASSED=$((PASSED + 1))
    else
        echo "  ❌ FAIL: Busybox not found in initramfs"
        FAILED=$((FAILED + 1))
    fi
}

# Test 7: Check GRUB config
test_grub_config() {
    echo "Test 7: GRUB configuration..."
    if [ -f "iso/boot/grub/grub.cfg" ] && grep -q "NextOS" iso/boot/grub/grub.cfg; then
        echo "  ✅ PASS: GRUB config found with NextOS entry"
        PASSED=$((PASSED + 1))
    else
        echo "  ❌ FAIL: GRUB config missing or incomplete"
        FAILED=$((FAILED + 1))
    fi
}

# Test 8: Check build scripts
test_build_scripts() {
    echo "Test 8: Build scripts..."
    SCRIPTS=("full-build.sh" "build/quick_iso.sh" "build/setup_virtualbox.sh")
    ALL_FOUND=true
    for script in "${SCRIPTS[@]}"; do
        if [ ! -x "$script" ]; then
            ALL_FOUND=false
            echo "  ❌ Missing or not executable: $script"
        fi
    done
    if $ALL_FOUND; then
        echo "  ✅ PASS: All build scripts found and executable"
        PASSED=$((PASSED + 1))
    else
        FAILED=$((FAILED + 1))
    fi
}

# Run all tests
test_kernel_config
test_kernel_build
test_initramfs
test_iso
test_initramfs_contents
test_busybox
test_grub_config
test_build_scripts

# Summary
echo ""
echo "==============================="
echo "Test Results"
echo "==============================="
echo "✅ Passed: $PASSED"
echo "❌ Failed: $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "✅ All tests passed!"
    exit 0
else
    echo "❌ Some tests failed"
    exit 1
fi
