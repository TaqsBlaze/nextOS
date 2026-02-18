#!/bin/bash
set -e

echo "========================================"
echo "Adding Essential Utilities Beyond BusyBox"
echo "========================================"

PROJECT_DIR=$(pwd)
ROOTFS_DIR="$PROJECT_DIR/rootfs"

# Create directory structure
echo "[1/7] Creating directory structure..."
mkdir -p "$ROOTFS_DIR"/{bin,sbin,usr/{bin,sbin,lib,share},etc,var,tmp,opt,home,root}
mkdir -p "$ROOTFS_DIR"/etc/{init.d,network}
mkdir -p "$ROOTFS_DIR"/var/{log,run,tmp}

# Set permissions
chmod 1777 "$ROOTFS_DIR"/tmp
chmod 1777 "$ROOTFS_DIR"/var/tmp

echo "  ✓ Directory structure created"

# Essential GNU coreutils (beyond BusyBox)
echo "[2/7] Installing GNU coreutils..."
COREUTILS=(
    /usr/bin/env
    /usr/bin/sort
    /usr/bin/uniq
    /usr/bin/head
    /usr/bin/tail
    /usr/bin/wc
    /usr/bin/tr
    /usr/bin/cut
    /usr/bin/paste
    /usr/bin/join
    /usr/bin/split
    /usr/bin/od
    /usr/bin/base64
    /usr/bin/sha256sum
    /usr/bin/md5sum
    /usr/bin/dirname
    /usr/bin/basename
    /usr/bin/realpath
    /usr/bin/readlink
)

for util in "${COREUTILS[@]}"; do
    if [ -f "$util" ]; then
        cp -a "$util" "$ROOTFS_DIR/usr/bin/" 2>/dev/null || true
    fi
done

echo "  ✓ Coreutils installed"

# Text editors
echo "[3/7] Installing text editors..."
if command -v nano &> /dev/null; then
    cp -a /usr/bin/nano "$ROOTFS_DIR/usr/bin/" 2>/dev/null || true
    mkdir -p "$ROOTFS_DIR/usr/share/nano"
    cp -a /usr/share/nano/* "$ROOTFS_DIR/usr/share/nano/" 2>/dev/null || true
    echo "  ✓ nano installed"
fi

if command -v vim.basic &> /dev/null; then
    cp -a /usr/bin/vim.basic "$ROOTFS_DIR/usr/bin/vim" 2>/dev/null || true
    ln -sf vim "$ROOTFS_DIR/usr/bin/vi" 2>/dev/null || true
    echo "  ✓ vim installed"
fi

# Networking tools
echo "[4/7] Installing networking utilities..."
NETWORK_TOOLS=(
    /usr/bin/wget
    /usr/bin/curl
    /usr/sbin/ip
    /sbin/ip
    /usr/bin/ping
    /bin/ping
    /usr/bin/netstat
    /sbin/ifconfig
    /usr/sbin/ifconfig
)

for tool in "${NETWORK_TOOLS[@]}"; do
    if [ -f "$tool" ]; then
        target_dir="$ROOTFS_DIR$(dirname $tool)"
        mkdir -p "$target_dir"
        cp -a "$tool" "$target_dir/" 2>/dev/null || true
    fi
done

echo "  ✓ Networking tools installed"

# Libraries required by the utilities
echo "[5/7] Copying required libraries..."
mkdir -p "$ROOTFS_DIR/lib/x86_64-linux-gnu"
mkdir -p "$ROOTFS_DIR/usr/lib/x86_64-linux-gnu"
mkdir -p "$ROOTFS_DIR/lib64"

# Copy dynamic linker
cp -a /lib64/ld-linux-x86-64.so.* "$ROOTFS_DIR/lib64/" 2>/dev/null || true

# Find and copy libraries for each executable
find_libs() {
    local exe="$1"
    ldd "$exe" 2>/dev/null | grep "=> /" | awk '{print $3}'
}

echo "  Finding dependencies for installed programs..."
for exe in "$ROOTFS_DIR"/usr/bin/* "$ROOTFS_DIR"/bin/* "$ROOTFS_DIR"/sbin/* "$ROOTFS_DIR"/usr/sbin/*; do
    if [ -f "$exe" ] && [ -x "$exe" ]; then
        for lib in $(find_libs "$exe"); do
            if [ -f "$lib" ]; then
                lib_dir=$(dirname "$lib")
                target_dir="$ROOTFS_DIR$lib_dir"
                mkdir -p "$target_dir"
                cp -a "$lib" "$target_dir/" 2>/dev/null || true
            fi
        done
    fi
done

echo "  ✓ Libraries copied"

# Essential configuration files
echo "[6/7] Creating configuration files..."

# /etc/passwd
cat > "$ROOTFS_DIR/etc/passwd" <<EOF
root:x:0:0:root:/root:/bin/bash
nobody:x:65534:65534:nobody:/nonexistent:/bin/false
EOF

# /etc/group
cat > "$ROOTFS_DIR/etc/group" <<EOF
root:x:0:
nogroup:x:65534:
EOF

# /etc/hostname
echo "nextos" > "$ROOTFS_DIR/etc/hostname"

# /etc/hosts
cat > "$ROOTFS_DIR/etc/hosts" <<EOF
127.0.0.1   localhost
127.0.1.1   nextos

# IPv6
::1         localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
EOF

# /etc/fstab
cat > "$ROOTFS_DIR/etc/fstab" <<EOF
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
proc            /proc           proc    defaults        0       0
sysfs           /sys            sysfs   defaults        0       0
devtmpfs        /dev            devtmpfs mode=0755     0       0
tmpfs           /tmp            tmpfs   defaults        0       0
EOF

# /etc/profile
cat > "$ROOTFS_DIR/etc/profile" <<'EOF'
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export HOME=/root
export TERM=linux
export PS1='\u@\h:\w\$ '

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

echo "Welcome to NextOS!"
echo "Type 'help' for available commands"
EOF

echo "  ✓ Configuration files created"

# Summary
echo "[7/7] Installation summary..."
echo ""
echo "Rootfs size: $(du -sh $ROOTFS_DIR | cut -f1)"
echo "Executables: $(find $ROOTFS_DIR -type f -executable | wc -l)"
echo "Libraries: $(find $ROOTFS_DIR -name '*.so*' | wc -l)"
echo ""
echo "========================================"
echo "✅ Essential utilities installed!"
echo "========================================"
echo ""
echo "Added utilities:"
echo "  - GNU coreutils (env, sort, uniq, etc.)"
echo "  - Text editors (nano, vim)"
echo "  - Network tools (wget, curl, ip)"
echo "  - System libraries and configurations"
echo ""
echo "Next: Run './full-build.sh' to rebuild the ISO"
