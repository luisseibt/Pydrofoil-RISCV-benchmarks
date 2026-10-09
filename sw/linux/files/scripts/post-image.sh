#!/usr/bin/env bash
###############################################################################
#                                                                             #
# Copyright 2026 Chiara Ghinami  Nils Bosbach                                 #
#                                                                             #
# This software is licensed under the MIT license found in the                #
# LICENSE file at the root directory of this source tree.                     #
#                                                                             #
###############################################################################

set -euo pipefail

echo "Running post-image.sh"

OUT_DIR=/app/output/
BUILDROOT_OUT_DIR=$OUT_DIR/buildroot

mkdir -p "$BUILDROOT_OUT_DIR"
cp "$BINARIES_DIR/rootfs.ext4" "$BUILDROOT_OUT_DIR/"

echo "Compiling fw_jump"
make -C /app/bootcode O=$BUILDROOT_OUT_DIR CC=riscv64-buildroot-linux-gnu-gcc OC=riscv64-buildroot-linux-gnu-objcopy

echo "Generating vmlinux.bin"
cp $BINARIES_DIR/vmlinux $BUILDROOT_OUT_DIR/vmlinux.elf
riscv64-buildroot-linux-gnu-objcopy -O binary $BINARIES_DIR/vmlinux $BUILDROOT_OUT_DIR/vmlinux.bin

echo "Installing vcml-pydrofoil artifacts"
cp "/app/files/vp_config/pydrofoil.cfg" "$BUILDROOT_OUT_DIR/"
cp "$BINARIES_DIR/fw_jump.bin" "$BUILDROOT_OUT_DIR/opensbi_fw_jump.bin"
# pydrofoil-vp-x{1,2,4,8}.dtb, one per hart count (files/dt/Makefile)
make -C /app/files/dt O=$BUILDROOT_OUT_DIR

# Thin wrapper next to the RoR ones, so both are launched the same way.
echo '%include ${dir}/buildroot/pydrofoil.cfg' > "$OUT_DIR/pydrofoil.cfg"

echo "post-image.sh done"
