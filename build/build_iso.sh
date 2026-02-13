#!/bin/sh

set -e

ISO_DIR=iso
OUT=nextOS.iso

if [ ! -f boot/vmlinuz ]; then
  echo "ERROR: kernel (boot/vmlinuz) not found."
  echo "ISO cannot be built without a kernel."
  exit 1
fi

if [ ! -f boot/initramfs.img ]; then
  echo "ERROR: initramfs (boot/initramfs.img) not found."
  echo "ISO cannot be built without an initramfs."
  exit 1
fi

mkdir -p iso/boot/grub

cp boot/vmlinuz iso/boot/
cp boot/initramfs.img iso/boot/

grub-mkrescue -o "$OUT" "$ISO_DIR"

echo "ISO built: $OUT"
