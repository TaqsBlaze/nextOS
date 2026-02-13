#!/bin/bash
set -e

echo "==============================="
echo "NextOS VirtualBox Setup"
echo "==============================="
echo ""

ISO_FILE="Next-OS.iso"
VDI_FILE="NextOS.vdi"
VM_NAME="NextOS"

# Check if ISO exists
if [ ! -f "$ISO_FILE" ]; then
    echo "❌ ERROR: $ISO_FILE not found"
    echo "Build the ISO first with: ./full-build.sh"
    exit 1
fi

# Check if VirtualBox is installed
if ! command -v VBoxManage &> /dev/null; then
    echo "❌ ERROR: VirtualBox not installed"
    echo "Install with: sudo apt install virtualbox"
    exit 1
fi

echo "📀 ISO file: $ISO_FILE"
echo "Size: $(du -h $ISO_FILE | cut -f1)"
echo ""

# Option 1: Create VDI from ISO
echo "1️⃣  Converting ISO to VDI format..."
if [ -f "$VDI_FILE" ]; then
    echo "   VDI already exists. Skipping conversion."
else
    VBoxManage convertdd "$ISO_FILE" "$VDI_FILE" --format VDI
    echo "   ✅ Created: $VDI_FILE"
fi

echo ""
echo "2️⃣  Checking for existing VM..."

# Check if VM already exists
if VBoxManage list vms | grep -q "\"$VM_NAME\""; then
    echo "   VM '$VM_NAME' already exists"
    echo "   To delete: VBoxManage unregistervm '$VM_NAME' --delete"
else
    echo "   Creating new VM: $VM_NAME"
    
    # Create VM
    VBoxManage createvm \
        --name "$VM_NAME" \
        --ostype "Linux_64" \
        --basefolder "$PWD" \
        --register
    
    echo "   ✅ VM created"
fi

echo ""
echo "3️⃣  Configuring VM..."

VM_UUID=$(VBoxManage list vms | grep "\"$VM_NAME\"" | sed 's/.*{\(.*\)}/\1/')

# Configure VM
VBoxManage modifyvm "$VM_NAME" \
    --memory 512 \
    --cpus 2 \
    --vram 16 \
    --boot1 dvd \
    --boot2 disk \
    --nic1 nat \
    --nictype1 82540EM

echo "   Memory: 512 MB"
echo "   CPUs: 2"
echo "   Video: 16 MB"
echo "   Network: NAT"

echo ""
echo "4️⃣  Creating storage controller..."

# Remove existing controller if present
VBoxManage storagectl "$VM_NAME" --name "IDE" --remove 2>/dev/null || true

# Create IDE controller
VBoxManage storagectl "$VM_NAME" \
    --name "IDE" \
    --add ide \
    --bootable on

echo "   ✅ IDE controller created"

echo ""
echo "5️⃣  Attaching ISO to VM..."

# Attach ISO as CD/DVD
VBoxManage storageattach "$VM_NAME" \
    --storagectl "IDE" \
    --port 0 \
    --device 0 \
    --type dvddrive \
    --medium "$ISO_FILE"

echo "   ✅ ISO attached as DVD"

echo ""
echo "6️⃣  Attaching VDI as hard disk..."

# Attach VDI as hard disk
VBoxManage storageattach "$VM_NAME" \
    --storagectl "IDE" \
    --port 1 \
    --device 0 \
    --type hdd \
    --medium "$VDI_FILE"

echo "   ✅ VDI attached as hard disk"

echo ""
echo "==============================="
echo "✅ VirtualBox VM Ready!"
echo "==============================="
echo ""
echo "VM Name: $VM_NAME"
echo "ISO: $ISO_FILE"
echo "Disk: $VDI_FILE"
echo ""
echo "To start the VM:"
echo "  VBoxManage startvm '$VM_NAME' --type gui"
echo ""
echo "Or open VirtualBox GUI:"
echo "  virtualbox &"
echo ""
echo "To remove VM:"
echo "  VBoxManage unregistervm '$VM_NAME' --delete"
echo ""
