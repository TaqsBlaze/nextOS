# NextOS — Refined Project Structure

> Generated as part of the build-system audit.  
> Changes from original structure are marked with `[NEW]`, `[MOVED]`, `[FIXED]`, or `[REMOVED]`.

```
.
├── banner/
│   └── nexOS2.png                        # Source banner/logo image
│
├── boot/                                 # BUILD OUTPUT — gitignore this dir
│   ├── initramfs.img                     # Built by Step 4
│   ├── rootfs.img                        # Built by Step 5 (needs sudo)
│   └── vmlinuz                           # Built by Step 1
│
├── build/                                # Helper/modular build scripts
│   ├── build_all.sh
│   ├── build_initramfs.sh
│   ├── build_iso.sh
│   ├── build_rootfs.sh
│   ├── configure_kernel.sh
│   ├── download_kernel.sh
│   ├── mnt/                              # Temporary mount point (gitignore)
│   ├── quick_iso.sh
│   ├── setup_virtualbox.sh
│   ├── test.sh
│   └── use_system_kernel.sh
│
├── docs/
│   ├── BUILD_SYSTEM.md
│   ├── CI_CD.md
│   ├── CODE_OF_CONDUCT.md
│   ├── design_philosophy.md
│   ├── road_map.md
│   └── security_model.md
│
├── grub/                                 # [NEW] GRUB source files (version controlled)
│   ├── grub.cfg                          # [MOVED] Was generated inline in build script
│   └── themes/
│       └── nexos/
│           ├── nexOS2.png                # [NEW] Copied from banner/ at build time
│           └── theme.txt                 # [NEW] Custom GRUB theme definition
│
├── initramfs/                            # initramfs source tree (packed by Step 4)
│   ├── bin/
│   │   ├── busybox                       # Must be STATIC binary
│   │   ├── adduser    -> busybox
│   │   ├── cat        -> busybox
│   │   ├── clear      -> busybox
│   │   ├── echo       -> busybox
│   │   ├── hostname   -> busybox
│   │   ├── losetup    -> busybox         # [NEW] Required: attach loop device for rootfs.img
│   │   ├── ls         -> busybox
│   │   ├── mkdir      -> busybox
│   │   ├── modprobe   -> busybox         # [NEW] Required: load iso9660/loop/ext4 modules
│   │   ├── mount      -> busybox
│   │   ├── sh         -> busybox
│   │   ├── switch_root -> busybox        # Required: pivot from initramfs to rootfs
│   │   ├── touch      -> busybox
│   │   ├── vi         -> busybox
│   │   └── wget       -> busybox
│   │   # [REMOVED] init  -> busybox     — /init is the real script, not a busybox applet
│   │   # [REMOVED] vim   -> busybox     — busybox has no vim applet; use vi instead
│   │   # [REMOVED] adduser -> busybox   — not needed in early boot environment
│   ├── build.sh
│   ├── dev/                              # Empty dir (devtmpfs mounted here at boot)
│   ├── init                             # [FIXED] Real init script (PID 1), must be chmod +x
│   ├── lib/
│   │   └── modules/                     # [NEW] Kernel modules for initramfs use
│   │       └── 6.19.0/                  # Copy from rootfs/lib/modules/ or kernel build
│   │           └── (module files)       # Needed if iso9660/loop/ext4 built as modules
│   ├── mnt/
│   │   ├── iso/                         # Mount point: the boot ISO device
│   │   └── root/                        # Mount point: rootfs.img (target for switch_root)
│   ├── proc/                            # Empty dir (mount point)
│   └── sys/                             # Empty dir (mount point)
│
├── iso/                                 # ISO staging dir — FULLY CLEANED on each build
│   └── boot/                            # [FIXED] Was: iso/boot/boot/boot/.../boot (nested!)
│       ├── grub/
│       │   ├── fonts/
│       │   │   └── unicode.pf2          # [NEW] Copied from system grub at build time
│       │   ├── grub.cfg                 # Copied from grub/grub.cfg at build time
│       │   ├── nexOS2.png               # Copied from banner/ at build time
│       │   └── themes/
│       │       └── nexos/
│       │           ├── nexOS2.png       # Copied at build time
│       │           └── theme.txt        # Copied from grub/themes/nexos/
│       ├── initramfs.img                # Copied from boot/
│       ├── rootfs.img                   # Copied from boot/ (if built)
│       └── vmlinuz                      # Copied from boot/
│
├── rootfs/                              # Root filesystem source (packed into rootfs.img)
│   ├── bin/
│   │   ├── bash                         # Dynamic bash binary
│   │   └── sh        -> bash            # [FIXED] Was: sh -> busybox (busybox not in rootfs/bin)
│   ├── dev/                             # Empty — devtmpfs mounted here at runtime
│   ├── etc/
│   │   ├── group                        # [NEW] Basic group file
│   │   ├── hostname                     # [NEW] Contains "nexos"
│   │   ├── passwd                       # root + user entries
│   │   └── profile                      # [NEW] Sets PATH, PS1 for interactive shells
│   ├── home/
│   │   └── user/
│   ├── lib/
│   │   ├── modules/
│   │   │   └── 6.19.0/                 # Kernel modules (installed by make modules_install)
│   │   │       ├── modules.alias
│   │   │       ├── modules.alias.bin
│   │   │       ├── modules.builtin
│   │   │       ├── modules.builtin.alias.bin
│   │   │       ├── modules.builtin.bin
│   │   │       ├── modules.builtin.modinfo
│   │   │       ├── modules.dep
│   │   │       ├── modules.dep.bin
│   │   │       ├── modules.devname
│   │   │       ├── modules.order
│   │   │       ├── modules.softdep
│   │   │       ├── modules.symbols
│   │   │       └── modules.symbols.bin
│   │   └── x86_64-linux-gnu/
│   │       ├── libc.so.6
│   │       └── libtinfo.so.6
│   ├── lib64/
│   │   └── ld-linux-x86-64.so.2         # [NEW] ELF dynamic linker — REQUIRED for bash
│   ├── proc/                            # Empty — mount point
│   ├── root/                            # root home directory
│   ├── run/                             # Empty — tmpfs mounted here at runtime
│   ├── sbin/
│   │   └── init                         # [NEW] CRITICAL: PID 1 target for switch_root
│   ├── sys/                             # Empty — mount point
│   ├── system/                          # NextOS custom init/UI system
│   │   ├── config/
│   │   ├── init.py                      # Python-based init (called from sbin/init)
│   │   ├── services/
│   │   └── ui/
│   ├── tmp/                             # Empty — tmpfs at runtime
│   ├── usr/
│   │   └── apps/
│   └── var/
│       └── log/
│
├── .gitignore                           # [NEW] Should ignore: boot/*.img, iso/, *.iso, linux-*/
├── CICD_SETUP.md
├── full-build.sh                        # Master build script (in project root)
├── KernelBuildNotes.md
├── LICENSE
├── Next-OS.iso                          # BUILD OUTPUT — gitignore
├── project-structure.md                 # Original structure
├── refined-project-structure.md         # This file
└── README.md
```

---

## Summary of Changes

### Critical Fixes (build will fail or misbehave without these)

| Issue | Location | Fix |
|-------|----------|-----|
| `iso/` directory deeply nested (`boot/boot/boot/...`) | `iso/` | Build script now runs `rm -rf "$ISO_DIR"` before every build |
| `rootfs/sbin/init` missing | `rootfs/sbin/` | Added — `switch_root` has no target without it |
| `rootfs/lib64/ld-linux-x86-64.so.2` missing | `rootfs/lib64/` | Added — bash (and any dynamic binary) cannot run without the ELF linker |
| `init` script never calls `switch_root` | `initramfs/init` | Rewritten to scan devices, mount ISO, loop-mount rootfs.img, switch_root |
| `bin/init -> busybox` in initramfs | `initramfs/bin/` | Removed — `/init` is the real script; busybox `init` applet would clobber it |
| `bin/vim -> busybox` | `initramfs/bin/` | Removed — busybox has no `vim` applet; `vi` is correct |
| Broken emoji step markers (`1ï¸`) | `full-build.sh` | Replaced with clean `[1/6]` step markers |

### Important Additions (needed for objectives)

| Addition | Why |
|----------|-----|
| `grub/` source directory | Version-control your GRUB config, don't generate it only at build time |
| `grub/themes/nexos/theme.txt` | Enables custom GRUB background, menu colours, countdown bar |
| `initramfs/bin/losetup -> busybox` | init script uses `losetup` to attach rootfs.img to a loop device |
| `initramfs/bin/modprobe -> busybox` | Loads `iso9660`, `loop`, `ext4` if built as modules |
| `initramfs/lib/modules/` | Module files for initramfs-phase modprobe calls |
| Kernel config flags in build script | `CONFIG_ISO9660_FS=y`, `CONFIG_BLK_DEV_LOOP=y`, `CONFIG_DEVTMPFS=y` etc. |
| `rootfs/etc/{group,hostname,profile}` | Minimal but functional userland environment |
| `.gitignore` | Keeps build outputs (ISO, kernel, images) out of git |

### Recommended .gitignore

```
# Build outputs
boot/
iso/
Next-OS.iso
linux-*/

# Temporary
build/mnt/
*.img
*.iso
```
