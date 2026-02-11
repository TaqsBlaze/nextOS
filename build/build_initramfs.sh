#!/bin/sh

set -e

INITRAMFS_DIR=initramfs
OUT=boot/initramfs.img

mkdir -p boot

echo "Building initramfs..."

cd "$INITRAMFS_DIR"

find . -print0 \
  | cpio --null -ov --format=newc \
  | gzip -9 > "../$OUT"

cd ..

echo "initramfs created at $OUT"
