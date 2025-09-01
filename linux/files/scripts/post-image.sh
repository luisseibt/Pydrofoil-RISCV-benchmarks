#!/usr/bin/env bash
set -euo pipefail

echo "Running post-image.sh"

OUT_DIR=/app/output/
BUILDROOT_OUT_DIR=$OUT_DIR/buildroot

mkdir -p "$BUILDROOT_OUT_DIR"
cp "/app/files/vp_config/buildroot.cfg" "$BUILDROOT_OUT_DIR/"
cp "$BINARIES_DIR/rootfs.ext4" "$BUILDROOT_OUT_DIR/"

echo "Compiling fw_jump"
make -C /app/bootcode O=$BUILDROOT_OUT_DIR CC=riscv64-buildroot-linux-gnu-gcc OC=riscv64-buildroot-linux-gnu-objcopy

echo "Generating vmlinux.bin"
cp $BINARIES_DIR/vmlinux $BUILDROOT_OUT_DIR/vmlinux.elf
riscv64-buildroot-linux-gnu-objcopy -O binary $BINARIES_DIR/vmlinux $BUILDROOT_OUT_DIR/vmlinux.bin

echo "Compiling device trees"
for n in 1 2 4; do
    sed "s/%NHARTS%/$n/" /app/files/vp_config/buildroot-xn.cfg > "$OUT_DIR/buildroot-x${n}.cfg"
    make -C /app/files/dt O=$BUILDROOT_OUT_DIR $BUILDROOT_OUT_DIR/ror-vp-x${n}.dtb
done

echo "post-image.sh done"
