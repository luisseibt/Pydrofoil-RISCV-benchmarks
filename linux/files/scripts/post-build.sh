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

echo "Running post-build.sh"

echo "Compiling hclktime app"
HCLKTIME_BUILD_DIR=/app/apps/hclktime/build_buildroot
HCLKTIME_INSTALL_DIR=$TARGET_DIR/root/apps/hclktime
mkdir -p "$HCLKTIME_BUILD_DIR" "$HCLKTIME_INSTALL_DIR"
pushd "$HCLKTIME_BUILD_DIR" > /dev/null
cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$HCLKTIME_INSTALL_DIR" \
    -DCMAKE_C_COMPILER=riscv64-buildroot-linux-gnu-gcc \
    ..

make -j `nproc`
make install
popd > /dev/null


COREMARK_PRO_PATH="$TARGET_DIR/usr/bin/coremark-pro.sh"
if [[ -e "$COREMARK_PRO_PATH" && ! -x "$COREMARK_PRO_PATH" ]]; then
    echo "Making coremark-pro.sh executable"
    chmod +x "$COREMARK_PRO_PATH"
fi

echo "post-build.sh done"
