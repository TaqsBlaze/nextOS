#!/bin/bash
# Quick health check for rootfs BEFORE building the ISO
# Run this from the project root directory

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RESET='\033[0m'

echo -e "\n${GREEN}=== NextOS Rootfs Health Check ===${RESET}\n"

ERRORS=0

# 1. Check bash binary
if [ -f rootfs/bin/bash ]; then
    echo -e "${GREEN}✓${RESET} rootfs/bin/bash exists"
    file rootfs/bin/bash
    ldd rootfs/bin/bash | head -3
else
    echo -e "${RED}✗ rootfs/bin/bash MISSING${RESET}"
    echo "  Fix: cp /bin/bash rootfs/bin/bash"
    ERRORS=$((ERRORS + 1))
fi

# 2. Check sh symlink
if [ -L rootfs/bin/sh ]; then
    TARGET=$(readlink rootfs/bin/sh)
    echo -e "${GREEN}✓${RESET} rootfs/bin/sh -> $TARGET"
elif [ -f rootfs/bin/sh ]; then
    echo -e "${YELLOW}!${RESET} rootfs/bin/sh exists but is not a symlink"
else
    echo -e "${RED}✗ rootfs/bin/sh MISSING${RESET}"
    echo "  Fix: ln -sf bash rootfs/bin/sh"
    ERRORS=$((ERRORS + 1))
fi

# 3. Check bash libraries
echo -e "\nChecking bash dependencies:"
LIBS_MISSING=0
ldd /bin/bash 2>/dev/null | grep -oP '/[^ ]+' | while read lib; do
    DEST="rootfs${lib}"
    if [ -f "$DEST" ]; then
        echo -e "  ${GREEN}✓${RESET} $lib"
    else
        echo -e "  ${RED}✗${RESET} $lib (copy to rootfs$(dirname "$lib")/)"
        LIBS_MISSING=$((LIBS_MISSING + 1))
    fi
done

# 4. Check /sbin/init
echo -e "\nChecking rootfs/sbin/init:"
if [ -f rootfs/sbin/init ]; then
    echo -e "${GREEN}✓${RESET} rootfs/sbin/init exists"
    SHEBANG=$(head -1 rootfs/sbin/init)
    echo "  Shebang: $SHEBANG"
    
    if echo "$SHEBANG" | grep -q '#!/bin/bash'; then
        echo -e "  ${GREEN}✓${RESET} Shebang is #!/bin/bash (correct)"
    elif echo "$SHEBANG" | grep -q '#!/bin/sh'; then
        echo -e "  ${YELLOW}!${RESET} Shebang is #!/bin/sh (will work if sh->bash symlink exists)"
    else
        echo -e "  ${RED}✗${RESET} Invalid shebang"
        ERRORS=$((ERRORS + 1))
    fi
    
    if [ -x rootfs/sbin/init ]; then
        echo -e "  ${GREEN}✓${RESET} Executable bit set"
    else
        echo -e "  ${RED}✗${RESET} Not executable"
        echo "  Fix: chmod +x rootfs/sbin/init"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo -e "${RED}✗ rootfs/sbin/init MISSING${RESET}"
    ERRORS=$((ERRORS + 1))
fi

# 5. Summary
echo -e "\n${GREEN}==================================${RESET}"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}All checks passed - safe to build${RESET}"
    exit 0
else
    echo -e "${RED}$ERRORS error(s) found - fix before building${RESET}"
    exit 1
fi
