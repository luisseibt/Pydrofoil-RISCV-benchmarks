#!/usr/bin/env bash
###############################################################################
#                                                                             #
# Copyright 2026 Chiara Ghinami                                               #
#                                                                             #
# This software is licensed under the MIT license found in the                #
# LICENSE file at the root directory of this source tree.                     #
#                                                                             #
###############################################################################

set -euo pipefail

ARCH_TYPE="${ARCH_TYPE:-64}"
GSF="${GSF:-200}"
GCC=""
MARCH=""
HELPER_BUILD_PATH="/app/build/helper"

echo "Building with a global scale factor of $GSF for RV$ARCH_TYPE"

# Building with compressed instructions (C), general purpose extension set (G)
if [ "$ARCH_TYPE" == 32 ]; then
    GCC=riscv32-unknown-elf-gcc
    MARCH="-march=rv32gc -mabi=ilp32d"
elif [ "$ARCH_TYPE" == 64 ]; then
    GCC=riscv64-unknown-elf-gcc
    MARCH="-march=rv64gc -mabi=lp64d"
else 
    echo "Invalid architecture"
    exit 1
fi;

# Building the helper files, we are re-using linker etc from the riscv-tests suite
# NOTE: the linker places code at 0x80000000 --> -mcmodel=medany is the only possible choice
mkdir -p "$HELPER_BUILD_PATH"
CRT=/app/riscv_tests/benchmarks/common
ENV=/app/riscv_tests/env
LD=/app/embench_helper/test.ld
CFLAGS="-O2 -mcmodel=medany -fno-math-errno" # Use machine instructions instead of the libm math lib
                                             # for the 64-version toolchain, this avoids using a
                                             # library that was precompiled with medlow and fails here :(

$GCC $MARCH $CFLAGS -c -I$CRT -I$ENV $CRT/crt.S -o $HELPER_BUILD_PATH/crt.o
$GCC $MARCH $CFLAGS -fno-builtin-printf -fno-tree-loop-distribute-patterns -c -I$CRT -I$ENV $CRT/syscalls.c -o $HELPER_BUILD_PATH/syscalls.o
$GCC $MARCH $CFLAGS -c /app/embench_helper/nosys.c -o $HELPER_BUILD_PATH/nosys.o

cd /app/embench_iot
scons -k --build-dir=/app/build --config-dir=examples/native/speed gsf=$GSF cc=$GCC \
    cflags="$CFLAGS -std=gnu17 -fdata-sections -ffunction-sections $MARCH" \
    ldflags="-static -nostdlib -nostartfiles $MARCH -T$LD $HELPER_BUILD_PATH/crt.o $HELPER_BUILD_PATH/syscalls.o $HELPER_BUILD_PATH/nosys.o" \
    user_libs="-lm -lc -lgcc"
