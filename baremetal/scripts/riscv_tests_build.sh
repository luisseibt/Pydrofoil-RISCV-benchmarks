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
cd /app/build

if [[ "$ARCH_TYPE" != 64 && "$ARCH_TYPE" != 32 ]]; then
    echo "Invalid architecture"
    exit 1
fi;

../riscv_tests/configure --with-xlen="$ARCH_TYPE"

# -k makes the build continue even when one target fails: 
# the toolchain might not support all the extensions the test suite uses
make -k -j$(nproc)

echo "Finished building riscv_tests"
