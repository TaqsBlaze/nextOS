#!/bin/bash
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'
info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
ok()      { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }

action_clean=1
skip_kernel=0

for arg in "$@"; do
    case "$arg" in
        --no-clean)     action_clean=0 ;;
        --skip-kernel)  skip_kernel=1 ;;
        --help|-h)
            echo "Usage: build/streamline.sh [--no-clean] [--skip-kernel]"
            echo "  --no-clean    Skip the clean-only step"
            echo "  --skip-kernel Reuse existing kernel for the build step"
            exit 0
            ;;
    esac
done


PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

FULL_BUILD="$PROJECT_DIR/full-build.sh"
FIX_ROOTFS="$PROJECT_DIR/Fix-rootfs-commands.sh"
HEALTH_CHECK="$PROJECT_DIR/healthCheck.sh"
BUILD_ISO="$PROJECT_DIR/build-iso"

for f in "$FULL_BUILD" "$FIX_ROOTFS" "$HEALTH_CHECK" "$BUILD_ISO"; do
    [ -f "$f" ] || { warn "Missing required script: $f"; exit 1; }
done

sudo -v

if [ "$action_clean" = "1" ]; then
    info "Step 1: full build --clean-only (as root)"
    sudo bash "$FULL_BUILD" --clean-only
else
    warn "Skipping clean-only step (--no-clean)"
fi

info "Step 2: fix-rootfs (as root)"
sudo bash "$FIX_ROOTFS"

info "Step 3: healthCheck"
bash "$HEALTH_CHECK"

info "Step 4: full build"
if [ "$skip_kernel" = "1" ]; then
    sudo bash "$FULL_BUILD" --skip-kernel
else
    sudo bash "$FULL_BUILD"
fi

info "Step 5: build-iso (as root)"
sudo bash "$BUILD_ISO"

ok "Streamlined build complete"
