.
├── banner
│   └── nexOS2.png
├── boot
│   ├── initramfs.img
│   ├── rootfs.img
│   └── vmlinuz
├── build
│   ├── build_all.sh
│   ├── build_initramfs.sh
│   ├── build_iso.sh
│   ├── build_rootfs.sh
│   ├── configure_kernel.sh
│   ├── download_kernel.sh
│   ├── mnt
│   ├── quick_iso.sh
│   ├── setup_virtualbox.sh
│   ├── test.sh
│   └── use_system_kernel.sh
├── CICD_SETUP.md
├── docs
│   ├── BUILD_SYSTEM.md
│   ├── CI_CD.md
│   ├── CODE_OF_CONDUCT.md
│   ├── design_philosophy.md
│   ├── road_map.md
│   └── security_model.md
├── full-build.sh
├── initramfs
│   ├── bin
│   │   ├── adduser -> busybox
│   │   ├── busybox
│   │   ├── cat -> busybox
│   │   ├── clear -> busybox
│   │   ├── echo -> busybox
│   │   ├── hostname -> busybox
│   │   ├── init -> busybox
│   │   ├── ls -> busybox
│   │   ├── mkdir -> busybox
│   │   ├── mount -> busybox
│   │   ├── sh -> busybox
│   │   ├── switch_root -> busybox
│   │   ├── touch -> busybox
│   │   ├── vi -> busybox
│   │   ├── vim -> busybox
│   │   ├── wget -> busybox
│   │   └── whoami -> busybox
│   ├── build.sh
│   ├── dev
│   ├── init
│   ├── mnt
│   │   ├── iso
│   │   └── root
│   ├── proc
│   └── sys
├── iso
│   └── boot
│       ├── boot
│       │   ├── boot
│       │   │   ├── boot
│       │   │   │   ├── boot
│       │   │   │   │   ├── boot
│       │   │   │   │   │   ├── boot
│       │   │   │   │   │   │   ├── grub
│       │   │   │   │   │   │   │   └── grub.cfg
│       │   │   │   │   │   │   ├── initramfs.img
│       │   │   │   │   │   │   └── vmlinuz
│       │   │   │   │   │   ├── grub
│       │   │   │   │   │   │   └── grub.cfg
│       │   │   │   │   │   ├── initramfs.img
│       │   │   │   │   │   └── vmlinuz
│       │   │   │   │   ├── grub
│       │   │   │   │   │   └── grub.cfg
│       │   │   │   │   ├── initramfs.img
│       │   │   │   │   └── vmlinuz
│       │   │   │   ├── grub
│       │   │   │   │   └── grub.cfg
│       │   │   │   ├── initramfs.img
│       │   │   │   └── vmlinuz
│       │   │   ├── grub
│       │   │   │   └── grub.cfg
│       │   │   ├── initramfs.img
│       │   │   └── vmlinuz
│       │   ├── grub
│       │   │   └── grub.cfg
│       │   ├── initramfs.img
│       │   └── vmlinuz
│       ├── grub
│       │   └── grub.cfg
│       ├── initramfs.img
│       ├── rootfs.img
│       └── vmlinuz
├── KernelBuildNotes.md
├── LICENSE
├── Next-OS.iso
├── project-structure.md
├── README.md
└── rootfs
    ├── bin
    │   ├── bash
    │   └── sh -> busybox
    ├── dev
    ├── etc
    │   └── passwd
    ├── home
    │   └── user
    ├── lib
    │   ├── modules
    │   │   └── 6.19.0
    │   │       ├── modules.alias
    │   │       ├── modules.alias.bin
    │   │       ├── modules.builtin
    │   │       ├── modules.builtin.alias.bin
    │   │       ├── modules.builtin.bin
    │   │       ├── modules.builtin.modinfo
    │   │       ├── modules.dep
    │   │       ├── modules.dep.bin
    │   │       ├── modules.devname
    │   │       ├── modules.order
    │   │       ├── modules.softdep
    │   │       ├── modules.symbols
    │   │       └── modules.symbols.bin
    │   └── x86_64-linux-gnu
    │       ├── libc.so.6
    │       └── libtinfo.so.6
    ├── lib64
    ├── proc
    ├── root
    ├── run
    ├── sbin
    ├── sys
    ├── system
    │   ├── config
    │   ├── init.py
    │   ├── services
    │   └── ui
    ├── tmp
    ├── usr
    │   └── apps
    └── var
        └── log

54 directories, 87 files
