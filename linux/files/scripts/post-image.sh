#!/usr/bin/env bash

echo "Running post-image.sh"

echo "Compiling fw_jump"
make -C /app/bootcode O=$BINARIES_DIR CC=riscv64-buildroot-linux-gnu-gcc OC=riscv64-buildroot-linux-gnu-objcopy

echo "Creating vmlinux.bin"
mv $BINARIES_DIR/vmlinux $BINARIES_DIR/vmlinux.elf
riscv64-buildroot-linux-gnu-objcopy -O binary $BINARIES_DIR/vmlinux.elf $BINARIES_DIR/vmlinux.bin

echo "post-image.sh done"
