#!/usr/bin/env bash
set -euo pipefail

echo "Running post-image.sh"

echo "Compiling fw_jump"
make -C /app/bootcode O=$BINARIES_DIR CC=riscv64-buildroot-linux-gnu-gcc OC=riscv64-buildroot-linux-gnu-objcopy

echo "Compiling dts"
make -C /app/files/dt O=$BINARIES_DIR

if [ -e $BINARIES_DIR/vmlinux ]; then
    echo "Creating vmlinux.bin"
    mv $BINARIES_DIR/vmlinux $BINARIES_DIR/vmlinux.elf
    riscv64-buildroot-linux-gnu-objcopy -O binary $BINARIES_DIR/vmlinux.elf $BINARIES_DIR/vmlinux.bin
fi

echo "post-image.sh done"
