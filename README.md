![icon](https://github.com/TaqsBlaze/nextOS/blob/main/banner/nexOS2.png)


# NextOS

NextOS is a **minimal, performance focused Linux based operating system** built entirely from source.

Its goal is to explore **modern kernel optimization, lightweight system architecture, and controlled userspace design** while maintaining clarity and engineering discipline.


## Visiom

NextOS is designed around:

* **Minimalism**
* **Performance first design**
* **Low memory footprint**
* **Fast boot**
* **Transparent system architecture**
* **Educational clarity**
* **Security conscious defaults**



## Current Status

* Early development stage
* Bootable ISO generation working
* Kernel built from source
* Minimal userspace with Bash


## Architecture Overview

* **Linux kernel** (custom configuration)
* **Minimal initramfs**
* **Lightweight root filesystem**
* **Manual ISO generation pipeline**
* No unnecessary background services


## Target Audience

* Systems programmers
* Kernel learners
* OS enthusiasts
* Performance engineers
* Security researchers


## Build Instructions

Make the build script executable:

```bash
chmod +x full-build.sh
```

Run the full build:

```bash
./full-build.sh
```

Test your ISO with QEMU:

```bash
qemu-system-x86_64 -m 2G -cdrom Next-OS.iso
```

---

## Quick Start – Containerized Build

To simplify building NextOS without polluting your host environment, use a **fully privileged container**:

1. **Stop and remove any old workspace container** (if it exists):

```bash
podman stop workspace
podman rm workspace
```

2. **Run a new privileged container with your project mounted**:

```bash
podman run --privileged -it \
  -v $HOME/Desktop/Halo:/work \
  --name workspace \
  debian:12 bash
```

> ⚠️ `--privileged` is required for mounting loop devices (`rootfs.img`) during the build.

3. **Inside the container**, navigate to the project directory and run the build:

```bash
cd /work/nextOS
chmod +x scripts/full-build.sh
./scripts/full-build.sh
```

4. **Test your ISO** inside the container or on the host:

```bash
qemu-system-x86_64 -m 2G -cdrom Next-OS.iso
```

> ✅ All installed packages and build artifacts will remain inside the mounted project folder (`/work`) for persistence.



## Philosophy

NextOS avoids unnecessary abstraction.
It favors **understanding over automation**, ensuring every component is **explainable and transparent**.

---

## License

Licensed under the GPL v2 License
