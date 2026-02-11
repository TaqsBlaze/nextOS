#!/bin/sh

set -e

ISO_DIR=iso
OUT=glassos.iso

if [ ! -f boot/vmlinuz ]; then
  echo "ERROR: kernel (boot/vmlinuz) not found."
  echo "ISO cannot be built without a kernel."
  exit 1
fi

mkdir -p iso/boot

cp boot/vmlinuz iso/boot/
cp boot/initramfs.img iso/boot/

grub-mkrescue -o "$OUT" "$ISO_DIR"

echo "ISO built: $OUT"
