# CI/CD Pipeline Documentation

## GitHub Actions Workflow

NextOS includes automated build pipeline using GitHub Actions. Every push and pull request triggers a complete build and test cycle.

### Workflow File
- **Location:** `.github/workflows/build.yml`
- **Trigger events:**
  - Push to `main` branch
  - Pull requests to `main` branch
  - Manual trigger (`workflow_dispatch`)

### Build Steps

1. **Dependency Installation**
   - Installs all build tools: gcc, make, libncurses-dev, flex, bison, etc.
   - Installs GRUB and xorriso for ISO generation
   - Installs QEMU for testing

2. **Kernel Download** (if needed)
   - Downloads Linux 6.19 source (cached if already present)
   - Saves time on subsequent runs

3. **Kernel Configuration**
   - Runs `build/configure_kernel.sh`
   - Applies NextOS optimizations
   - Creates `.config` for build

4. **Kernel Compilation**
   - Parallel build: `make -j$(nproc)`
   - Outputs: `arch/x86/boot/bzImage`
   - Copies to `boot/vmlinuz`

5. **Initramfs Setup**
   - Copies busybox binary
   - Rebuilds initramfs with all dependencies

6. **ISO Generation**
   - Runs `build/quick_iso.sh`
   - Creates bootable NextOS ISO

7. **Verification**
   - Checks ISO file exists and has valid size
   - Verifies ISO integrity

8. **QEMU Testing**
   - Boots ISO in QEMU with timeout
   - Captures first 100 lines of output
   - Ensures kernel and init system work

9. **Artifact Upload**
   - Uploads ISO as GitHub artifact (30-day retention)
   - Available for download from Actions tab

10. **Release Creation** (on version tags)
    - Automatically creates GitHub Release when tag pushed
    - Attaches ISO file for distribution

### Testing Locally

Run the full test suite:
```bash
./build/test.sh
```

### Test Suite

Tests verify:
1. ✅ Kernel configuration exists
2. ✅ Kernel binary compiled
3. ✅ Initramfs created
4. ✅ ISO image generated
5. ✅ /init in initramfs
6. ✅ Busybox included
7. ✅ GRUB config valid
8. ✅ Build scripts executable

### Building Locally

```bash
# Full build
./full-build.sh

# Quick rebuild (ISO only)
./build/quick_iso.sh

# Test
./build/test.sh

# Setup VirtualBox
./build/setup_virtualbox.sh
```

### Creating a Release

To trigger automatic ISO release:

```bash
# Tag a release
git tag v1.0.0
git push origin v1.0.0
```

This will:
1. Run complete build
2. Create GitHub Release
3. Attach ISO as downloadable artifact

### Environment Secrets

No secrets required for basic build. The workflow uses `secrets.GITHUB_TOKEN` for releases, which is automatically provided.

### Build Performance

- **First run:** ~45-60 minutes (kernel download + compile)
- **Subsequent runs:** ~10-15 minutes (kernel cached, quick rebuild)
- **ISO-only rebuild:** ~2 minutes

### Troubleshooting

**Workflow fails on kernel compilation:**
- Check Ubuntu runner has enough disk space
- Kernel source is ~2.5GB uncompressed
- Build directory can be 5GB+

**QEMU test fails:**
- This is informational - if kernel boots and init runs, it's successful
- Timeout is expected (30 seconds to prove it works)

**ISO upload fails:**
- GitHub artifact storage limit is 5GB per workflow run
- NextOS.iso is ~25MB, no issues expected

### Future Enhancements

- [ ] Run full QEMU boot sequence
- [ ] Generate checksums (SHA256)
- [ ] Create squashfs-based ISOs (smaller)
- [ ] Build for multiple architectures
- [ ] Automated performance benchmarks
- [ ] Docker container builds
- [ ] Automated documentation generation
