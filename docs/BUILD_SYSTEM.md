# NextOS Build System

## Overview
NextOS uses a modular build system that creates a minimal, bootable Linux ISO from source.

## Build Scripts

### Full Build: `full-build.sh`
Builds everything from scratch:
1. Compiles Linux kernel 6.19
2. Installs kernel modules
3. Sets up rootfs with bash
4. Creates initramfs
5. Generates bootable ISO

**Usage:**
```bash
./full-build.sh
```

**Requirements:**
- Linux kernel 6.19 source in `linux-6.19/`
- Build tools: gcc, make, grub-mkrescue, xorriso
- Root privileges (for mounting)

---

### Quick ISO: `build/quick_iso.sh`
Builds ISO from existing boot artifacts (kernel + initramfs already built).

**Usage:**
```bash
./build/quick_iso.sh
```

**Prerequisites:**
- `boot/vmlinuz` (kernel)
- `boot/initramfs.img` (initramfs)

---

### Modular Scripts

#### `build/build_initramfs.sh`
Creates initramfs from `initramfs/` directory.

#### `build/build_rootfs.sh`
Builds root filesystem image.

#### `build/build_iso.sh`
Generates ISO from boot files (basic version).

#### `build/build_all.sh`
Alternative full build without kernel compilation.

---

## Directory Structure

```
nextOS/
├── linux-6.19/          # Kernel source
├── boot/                # Boot artifacts
│   ├── vmlinuz         # Compiled kernel
│   ├── initramfs.img   # Initial RAM filesystem
│   └── rootfs.img      # Root filesystem (optional)
├── initramfs/           # Initramfs source files
│   ├── init            # Init script
│   └── bin/            # Essential binaries
├── rootfs/              # Root filesystem source
│   ├── bin/
│   └── system/
├── iso/                 # ISO staging area
│   └── boot/
│       ├── grub/
│       │   └── grub.cfg
│       ├── vmlinuz
│       └── initramfs.img
└── build/               # Build scripts
```

---

## Quick Start

### 1. First Time Build
```bash
# Build kernel + full system + ISO
./full-build.sh
```

### 2. Rebuild ISO Only
```bash
# After modifying initramfs or configs
./build/quick_iso.sh
```

### 3. Test in QEMU
```bash
qemu-system-x86_64 -cdrom NextOS.iso -m 512M
```

---

## Boot Configuration

GRUB configuration in `iso/boot/grub/grub.cfg`:

- **NextOS**: Normal boot (quiet mode)
- **NextOS (Verbose)**: Boot with full kernel messages

Both configurations use:
- Kernel: `/boot/vmlinuz`
- Initramfs: `/boot/initramfs.img`
- Root: `/dev/ram0` (RAM disk)

---

## Troubleshooting

### ISO Build Fails
**Error:** `grub-mkrescue` not found
```bash
# Ubuntu/Debian
sudo apt install grub-pc-bin xorriso

# Arch
sudo pacman -S grub libisoburn
```

### Kernel Not Found
Build kernel first:
```bash
cd linux-6.19
make menuconfig  # Configure if needed
make -j$(nproc)
cp arch/x86/boot/bzImage ../boot/vmlinuz
```

### Nested Boot Directories
If `iso/boot/boot/boot/...` appears, clean and rebuild:
```bash
rm -rf iso/boot
mkdir -p iso/boot/grub
./build/quick_iso.sh
```

---

## Build Artifacts

- **NextOS.iso** - Bootable ISO image (~50-100MB)
- **boot/vmlinuz** - Compressed kernel (~10MB)
- **boot/initramfs.img** - Initial filesystem (~500KB-2MB)
- **boot/rootfs.img** - Root filesystem image (~50MB, optional)

---

## Performance Tips

1. **Parallel Builds:** Kernel builds use `make -j$(nproc)` automatically
2. **Incremental Builds:** Use `quick_iso.sh` when only initramfs changes
3. **Kernel Size:** Optimize `.config` to reduce kernel size (see `KernelBuildNotes.md`)

---

## Next Steps

- [ ] Add GitHub Actions for automated builds
- [ ] Implement squashfs for smaller ISOs
- [ ] Add package manager support
- [ ] Create installer system
