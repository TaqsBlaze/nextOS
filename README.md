![NextOS Banner](https://github.com/TaqsBlaze/nextOS/blob/main/banner/nexOS2.png)

# NextOS

> A minimal, performance-focused Linux operating system built entirely from source.

[![Build Status](https://github.com/TaqsBlaze/nextOS/actions/workflows/build.yml/badge.svg)](https://github.com/TaqsBlaze/nextOS/actions)
[![License: GPL v2](https://img.shields.io/badge/License-GPLv2-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
[![Linux](https://img.shields.io/badge/Linux-6.19-FCC624?logo=linux&logoColor=black)](https://www.kernel.org/)

## Overview

NextOS is a purpose-built Linux distribution that prioritizes **minimalism**, **transparency**, and **performance**. Every component is configured and built from source, providing complete control over the system stack. Designed for systems programmers, kernel developers, and OS enthusiasts who value understanding over convenience.

## Key Features

### Core Philosophy
- **Minimalism by default** — Only essential components included
- **Transparency first** — Every configuration choice is documented and explainable
- **Performance optimized** — Lean kernel configuration targeting fast boot and low memory overhead
- **Educational clarity** — Clear separation between build system and runtime components
- **Security through reduction** — Smaller attack surface via minimal userspace

### Technical Specifications
| Component | Version | Size |
|-----------|---------|------|
| **Kernel** | Linux 6.19 | 13 MB (optimized) |
| **Userspace** | BusyBox 1.36.1 | 2.1 MB |
| **Initramfs** | Custom | 1.1 MB |
| **ISO Image** | Bootable | ~25 MB |

## Architecture

```
NextOS System Architecture
├── Bootloader (GRUB 2)
│   └── Linux Kernel 6.19 (custom config)
│       └── Initramfs (minimal rootfs)
│           ├── BusyBox (core utilities)
│           ├── Essential drivers
│           └── Custom init system
└── Root filesystem (RAM-based)
    └── Shell + core tools
```

### Design Principles
1. **No unnecessary services** — Everything runs on-demand
2. **Static binaries where possible** — Reduce runtime dependencies
3. **Reproducible builds** — Same input always produces same output
4. **Clear separation** — Build tools ≠ runtime system

## Getting Started

### Prerequisites
- Linux system with build tools
- 5GB+ free disk space
- 2GB RAM minimum
- Internet connection (for kernel download)

### Quick Start

**Option 1: Automated Build**
```bash
./full-build.sh
```

**Option 2: Step-by-step**
```bash
# Download kernel (one-time)
./build/download_kernel.sh

# Configure and compile kernel
cd linux-6.19
../build/configure_kernel.sh
make -j$(nproc)
cd ..

# Build ISO
./build/quick_iso.sh
```

### Testing

**QEMU (Lightweight)**
```bash
qemu-system-x86_64 -cdrom NextOS.iso -m 512M
```

**VirtualBox**
```bash
./build/setup_virtualbox.sh
VBoxManage startvm NextOS --type gui
```

**Test Suite**
```bash
./build/test.sh
```

## Documentation

| Document | Purpose |
|----------|---------|
| [BUILD_SYSTEM.md](docs/BUILD_SYSTEM.md) | Build system overview and scripts |
| [CI_CD.md](docs/CI_CD.md) | GitHub Actions pipeline documentation |
| [CICD_SETUP.md](CICD_SETUP.md) | CI/CD configuration guide |
| [KernelBuildNotes.md](KernelBuildNotes.md) | Kernel optimization reference |
| [design_philosophy.md](docs/design_philosophy.md) | Design principles |
| [security_model.md](docs/security_model.md) | Security considerations |

## CI/CD Pipeline

NextOS includes automated build and test infrastructure:

- **Automated builds** on every commit
- **Pull request validation**
- **QEMU boot testing**
- **Artifact storage** (30 days)
- **Automatic releases** on version tags

See [CI_CD.md](docs/CI_CD.md) for detailed documentation.

## Project Structure

```
nextOS/
├── .github/workflows/      # GitHub Actions pipeline
├── boot/                   # Compiled kernel & initramfs
├── build/                  # Build helper scripts
│   ├── test.sh            # Test suite
│   ├── quick_iso.sh       # Fast ISO rebuild
│   └── setup_virtualbox.sh # VirtualBox setup
├── docs/                  # Documentation
├── initramfs/             # Initramfs source
│   ├── init               # System initialization
│   └── bin/               # Core utilities
├── iso/                   # ISO staging area
├── kernel-6.19/           # Linux kernel source (generated)
├── rootfs/                # Root filesystem template
├── full-build.sh          # Complete build script
└── README.md             # This file
```

## Development Workflow

### For Contributors

1. **Create feature branch**
   ```bash
   git checkout -b feat/your-feature
   ```

2. **Make changes** and test
   ```bash
   ./build/test.sh
   ```

3. **Push and create PR**
   ```bash
   git push origin feat/your-feature
   ```

4. **CI/CD validates** automatically

### Local Testing Before PR
```bash
# Run full test suite
./build/test.sh

# Boot in QEMU
qemu-system-x86_64 -cdrom NextOS.iso -m 512M

# Or in VirtualBox
./build/setup_virtualbox.sh
```

## Performance Characteristics

| Metric | Value |
|--------|-------|
| **Boot time** | ~5-10 seconds (QEMU) |
| **Memory footprint** | <100MB idle |
| **Kernel size (compressed)** | 13MB |
| **Initramfs size** | 1.1MB |
| **ISO size** | 25MB |

## Known Limitations

- **No package manager** — Minimal approach focuses on system core
- **Limited drivers** — Optimized for virtualization and modern hardware
- **RAM-based rootfs** — Changes are not persisted (by design)
- **Initramfs-only boot** — No persistent root filesystem in base ISO

## Roadmap

- [ ] Package manager integration
- [ ] Persistent storage support
- [ ] Squashfs optimization (smaller ISOs)
- [ ] Multi-architecture builds (ARM64, etc.)
- [ ] Docker/OCI container support
- [ ] Automated performance benchmarks

## Target Audience

- **Systems Programmers** — Learn OS internals from working code
- **Kernel Developers** — Test custom kernel configurations
- **OS Enthusiasts** — Understand complete system stack
- **Performance Engineers** — Baseline for optimization
- **Security Researchers** — Minimal attack surface platform

## Contributing

Contributions welcome! Please:

1. Follow the design philosophy
2. Document all changes
3. Test with `./build/test.sh`
4. Create PR with clear description
5. Ensure CI/CD passes

## License

Licensed under the **GNU General Public License v2.0**

See [LICENSE](LICENSE) file for details.

## Related Resources

- [Linux Kernel Documentation](https://www.kernel.org/doc/)
- [BusyBox](https://busybox.net/)
- [GRUB](https://www.gnu.org/software/grub/)
- [nextOS Design Philosophy](docs/design_philosophy.md)

## Support & Contact

- **Issues**: [GitHub Issues](https://github.com/TaqsBlaze/nextOS/issues)
- **Discussions**: [GitHub Discussions](https://github.com/TaqsBlaze/nextOS/discussions)
- **Repository**: [TaqsBlaze/nextOS](https://github.com/TaqsBlaze/nextOS)

---

**Built with ❤️ by the NextOS community**
