.
├── banner
│   └── nextOS2.png
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
├── build-iso
├── CICD_SETUP.md
├── Dockerfile
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
│   │   ├── [ -> busybox
│   │   ├── [[ -> busybox
│   │   ├── ar -> busybox
│   │   ├── arch -> busybox
│   │   ├── arping -> busybox
│   │   ├── ascii -> busybox
│   │   ├── ash -> busybox
│   │   ├── awk -> busybox
│   │   ├── base64 -> busybox
│   │   ├── basename -> busybox
│   │   ├── bc -> busybox
│   │   ├── blkdiscard -> busybox
│   │   ├── bunzip2 -> busybox
│   │   ├── busybox
│   │   ├── bzcat -> busybox
│   │   ├── bzip2 -> busybox
│   │   ├── cal -> busybox
│   │   ├── cat -> busybox
│   │   ├── chgrp -> busybox
│   │   ├── chmod -> busybox
│   │   ├── chown -> busybox
│   │   ├── chpasswd -> busybox
│   │   ├── chvt -> busybox
│   │   ├── clear -> busybox
│   │   ├── cmp -> busybox
│   │   ├── cp -> busybox
│   │   ├── cpio -> busybox
│   │   ├── crc32 -> busybox
│   │   ├── crond -> busybox
│   │   ├── crontab -> busybox
│   │   ├── cttyhack -> busybox
│   │   ├── cut -> busybox
│   │   ├── date -> busybox
│   │   ├── dc -> busybox
│   │   ├── dd -> busybox
│   │   ├── deallocvt -> busybox
│   │   ├── df -> busybox
│   │   ├── diff -> busybox
│   │   ├── dirname -> busybox
│   │   ├── dmesg -> busybox
│   │   ├── dnsdomainname -> busybox
│   │   ├── dos2unix -> busybox
│   │   ├── dpkg -> busybox
│   │   ├── dpkg-deb -> busybox
│   │   ├── du -> busybox
│   │   ├── dumpkmap -> busybox
│   │   ├── dumpleases -> busybox
│   │   ├── echo -> busybox
│   │   ├── ed -> busybox
│   │   ├── egrep -> busybox
│   │   ├── env -> busybox
│   │   ├── expand -> busybox
│   │   ├── expr -> busybox
│   │   ├── factor -> busybox
│   │   ├── fallocate -> busybox
│   │   ├── false -> busybox
│   │   ├── fatattr -> busybox
│   │   ├── fgrep -> busybox
│   │   ├── find -> busybox
│   │   ├── fold -> busybox
│   │   ├── free -> busybox
│   │   ├── fsfreeze -> busybox
│   │   ├── fstrim -> busybox
│   │   ├── ftpget -> busybox
│   │   ├── ftpput -> busybox
│   │   ├── getopt -> busybox
│   │   ├── grep -> busybox
│   │   ├── groups -> busybox
│   │   ├── gunzip -> busybox
│   │   ├── gzip -> busybox
│   │   ├── head -> busybox
│   │   ├── hexdump -> busybox
│   │   ├── hostid -> busybox
│   │   ├── hostname -> busybox
│   │   ├── httpd -> busybox
│   │   ├── i2cdetect -> busybox
│   │   ├── i2cdump -> busybox
│   │   ├── i2cget -> busybox
│   │   ├── i2cset -> busybox
│   │   ├── i2ctransfer -> busybox
│   │   ├── id -> busybox
│   │   ├── ionice -> busybox
│   │   ├── kill -> busybox
│   │   ├── killall -> busybox
│   │   ├── last -> busybox
│   │   ├── less -> busybox
│   │   ├── link -> busybox
│   │   ├── linux32 -> busybox
│   │   ├── linux64 -> busybox
│   │   ├── linuxrc -> busybox
│   │   ├── ln -> busybox
│   │   ├── loadfont -> busybox
│   │   ├── logger -> busybox
│   │   ├── login -> busybox
│   │   ├── logname -> busybox
│   │   ├── logread -> busybox
│   │   ├── ls -> busybox
│   │   ├── lsmod -> busybox
│   │   ├── lsscsi -> busybox
│   │   ├── lzcat -> busybox
│   │   ├── lzma -> busybox
│   │   ├── lzop -> busybox
│   │   ├── md5sum -> busybox
│   │   ├── microcom -> busybox
│   │   ├── mim -> busybox
│   │   ├── mkdir -> busybox
│   │   ├── mkfifo -> busybox
│   │   ├── mkpasswd -> busybox
│   │   ├── mktemp -> busybox
│   │   ├── more -> busybox
│   │   ├── mount -> busybox
│   │   ├── mt -> busybox
│   │   ├── mv -> busybox
│   │   ├── nbd-client -> busybox
│   │   ├── nc -> busybox
│   │   ├── netstat -> busybox
│   │   ├── nl -> busybox
│   │   ├── nologin -> busybox
│   │   ├── nproc -> busybox
│   │   ├── nsenter -> busybox
│   │   ├── nslookup -> busybox
│   │   ├── nuke -> busybox
│   │   ├── od -> busybox
│   │   ├── openvt -> busybox
│   │   ├── partprobe -> busybox
│   │   ├── passwd -> busybox
│   │   ├── paste -> busybox
│   │   ├── patch -> busybox
│   │   ├── pidof -> busybox
│   │   ├── ping -> busybox
│   │   ├── ping6 -> busybox
│   │   ├── printf -> busybox
│   │   ├── ps -> busybox
│   │   ├── pwd -> busybox
│   │   ├── rdate -> busybox
│   │   ├── readlink -> busybox
│   │   ├── realpath -> busybox
│   │   ├── renice -> busybox
│   │   ├── reset -> busybox
│   │   ├── resume -> busybox
│   │   ├── rev -> busybox
│   │   ├── rm -> busybox
│   │   ├── rmdir -> busybox
│   │   ├── rpm -> busybox
│   │   ├── rpm2cpio -> busybox
│   │   ├── run-init -> busybox
│   │   ├── run-parts -> busybox
│   │   ├── sed -> busybox
│   │   ├── seq -> busybox
│   │   ├── setkeycodes -> busybox
│   │   ├── setpriv -> busybox
│   │   ├── setsid -> busybox
│   │   ├── sh -> busybox
│   │   ├── sha1sum -> busybox
│   │   ├── sha256sum -> busybox
│   │   ├── sha3sum -> busybox
│   │   ├── sha512sum -> busybox
│   │   ├── shred -> busybox
│   │   ├── shuf -> busybox
│   │   ├── sleep -> busybox
│   │   ├── sort -> busybox
│   │   ├── ssl_client -> busybox
│   │   ├── stat -> busybox
│   │   ├── static-sh -> busybox
│   │   ├── strings -> busybox
│   │   ├── stty -> busybox
│   │   ├── su -> busybox
│   │   ├── svc -> busybox
│   │   ├── svok -> busybox
│   │   ├── sync -> busybox
│   │   ├── tac -> busybox
│   │   ├── tail -> busybox
│   │   ├── tar -> busybox
│   │   ├── taskset -> busybox
│   │   ├── tc -> busybox
│   │   ├── tee -> busybox
│   │   ├── telnet -> busybox
│   │   ├── telnetd -> busybox
│   │   ├── test -> busybox
│   │   ├── tftp -> busybox
│   │   ├── time -> busybox
│   │   ├── timeout -> busybox
│   │   ├── top -> busybox
│   │   ├── touch -> busybox
│   │   ├── tr -> busybox
│   │   ├── traceroute -> busybox
│   │   ├── traceroute6 -> busybox
│   │   ├── true -> busybox
│   │   ├── truncate -> busybox
│   │   ├── ts -> busybox
│   │   ├── tty -> busybox
│   │   ├── tunctl -> busybox
│   │   ├── ubirename -> busybox
│   │   ├── udhcpc6 -> busybox
│   │   ├── uevent -> busybox
│   │   ├── uname -> busybox
│   │   ├── uncompress -> busybox
│   │   ├── unexpand -> busybox
│   │   ├── uniq -> busybox
│   │   ├── unix2dos -> busybox
│   │   ├── unlink -> busybox
│   │   ├── unlzma -> busybox
│   │   ├── unshare -> busybox
│   │   ├── unxz -> busybox
│   │   ├── unzip -> busybox
│   │   ├── uptime -> busybox
│   │   ├── usleep -> busybox
│   │   ├── uudecode -> busybox
│   │   ├── uuencode -> busybox
│   │   ├── vconfig -> busybox
│   │   ├── vi -> busybox
│   │   ├── w -> busybox
│   │   ├── watch -> busybox
│   │   ├── watchdog -> busybox
│   │   ├── wc -> busybox
│   │   ├── wget -> busybox
│   │   ├── which -> busybox
│   │   ├── who -> busybox
│   │   ├── whoami -> busybox
│   │   ├── xargs -> busybox
│   │   ├── xxd -> busybox
│   │   ├── xz -> busybox
│   │   ├── xzcat -> busybox
│   │   ├── yes -> busybox
│   │   └── zcat -> busybox
│   ├── build.sh
│   ├── dev
│   ├── init
│   ├── mnt
│   │   ├── iso
│   │   │   └── boot
│   │   │       └── rootfs.img
│   │   └── root
│   ├── proc
│   ├── sbin
│   │   ├── acpid -> ../bin/busybox
│   │   ├── adjtimex -> ../bin/busybox
│   │   ├── arp -> ../bin/busybox
│   │   ├── blockdev -> ../bin/busybox
│   │   ├── brctl -> ../bin/busybox
│   │   ├── chroot -> ../bin/busybox
│   │   ├── depmod -> ../bin/busybox
│   │   ├── devmem -> ../bin/busybox
│   │   ├── fdisk -> ../bin/busybox
│   │   ├── findfs -> ../bin/busybox
│   │   ├── freeramdisk -> ../bin/busybox
│   │   ├── getty -> ../bin/busybox
│   │   ├── halt -> ../bin/busybox
│   │   ├── hwclock -> ../bin/busybox
│   │   ├── ifconfig -> ../bin/busybox
│   │   ├── ifdown -> ../bin/busybox
│   │   ├── ifup -> ../bin/busybox
│   │   ├── init -> ../bin/busybox
│   │   ├── insmod -> ../bin/busybox
│   │   ├── ip -> ../bin/busybox
│   │   ├── ipcalc -> ../bin/busybox
│   │   ├── klogd -> ../bin/busybox
│   │   ├── loadkmap -> ../bin/busybox
│   │   ├── losetup -> ../bin/busybox
│   │   ├── mdev -> ../bin/busybox
│   │   ├── mkdosfs -> ../bin/busybox
│   │   ├── mke2fs -> ../bin/busybox
│   │   ├── mknod -> ../bin/busybox
│   │   ├── mkswap -> ../bin/busybox
│   │   ├── modinfo -> ../bin/busybox
│   │   ├── modprobe -> ../bin/busybox
│   │   ├── nameif -> ../bin/busybox
│   │   ├── pivot_root -> ../bin/busybox
│   │   ├── poweroff -> ../bin/busybox
│   │   ├── reboot -> ../bin/busybox
│   │   ├── rmmod -> ../bin/busybox
│   │   ├── route -> ../bin/busybox
│   │   ├── start-stop-daemon -> ../bin/busybox
│   │   ├── sulogin -> ../bin/busybox
│   │   ├── swapoff -> ../bin/busybox
│   │   ├── swapon -> ../bin/busybox
│   │   ├── switch_root -> ../bin/busybox
│   │   ├── sysctl -> ../bin/busybox
│   │   ├── syslogd -> ../bin/busybox
│   │   ├── udhcpc -> ../bin/busybox
│   │   ├── udhcpd -> ../bin/busybox
│   │   └── umount -> ../bin/busybox
│   ├── sys
│   └── usr
│       ├── bin
│       └── sbin
├── iso
│   └── boot
│       ├── grub
│       │   ├── fonts
│       │   │   └── unicode.pf2
│       │   ├── grub.cfg
│       │   ├── nextOS2.png
│       │   └── themes
│       │       └── nextos
│       │           └── nextOS2.png
│       ├── initramfs.img
│       ├── rootfs.img
│       └── vmlinuz
├── KernelBuildNotes.md
├── LICENSE
├── newfiles
│   ├── grub.cfg
│   ├── init
│   ├── refined-project-structure.md
│   └── rootfs-sbin-init
├── Next-OS.iso
├── project-structure.md
├── README.md
├── rootfs
│   ├── bin
│   │   └── bash
│   ├── dev
│   ├── etc
│   │   ├── group
│   │   ├── hostname
│   │   ├── passwd
│   │   └── profile
│   ├── home
│   │   └── user
│   ├── lib
│   │   ├── modules
│   │   │   └── 6.19.0
│   │   │       ├── modules.builtin
│   │   │       └── modules.builtin.modinfo
│   │   └── x86_64-linux-gnu
│   │       ├── libc.so.6
│   │       └── libtinfo.so.6
│   ├── lib64
│   ├── proc
│   ├── root
│   ├── run
│   ├── sbin
│   │   └── init
│   ├── sys
│   ├── system
│   │   ├── config
│   │   ├── init.py
│   │   ├── services
│   │   └── ui
│   ├── tmp
│   ├── usr
│   │   └── apps
│   └── var
│       └── log
└── startDocker

51 directories, 327 files
