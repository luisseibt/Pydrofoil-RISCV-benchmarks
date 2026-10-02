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

# Get directory of script itself
SOURCE="${BASH_SOURCE[0]}"
# resolve $SOURCE until the file is no longer a symlink
while [ -h "$SOURCE" ]; do
    DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    # if $SOURCE was a relative symlink, we need to resolve it relative to the
    # path where the symlink file was located
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

PROJECT_ROOT="$(dirname "$DIR")"
TEMPLATE="$PROJECT_ROOT/vp_config/sysc_simulator.cfg.in"

USAGE="usage: $0 <embench_iot|riscv_tests> <benchmark name> <32|64> [quantum, e.g. 10us]"
SUITE="${1:?$USAGE}"
BENCHMARK="${2:?$USAGE}"
ARCH_TYPE="${3:?$USAGE}"
QUANTUM="${4:-10us}"

if [[ $ARCH_TYPE != 32 && $ARCH_TYPE != 64 ]]; then
    echo "Wrong architecture parameter, it should either be 32 or 64"
    exit 1
fi

if [[ ! $QUANTUM =~ ^[0-9]+(s|ms|us|ns)$ ]]; then
    echo "Quantum must be an integer followed by s, ms, us or ns"
    exit 1
fi

if [[ $SUITE == "embench_iot" ]]; then
    BINARY="$PROJECT_ROOT/build/$SUITE/$ARCH_TYPE/src/$BENCHMARK/$BENCHMARK"
elif [[ $SUITE == "riscv_tests" ]]; then
    BINARY="$PROJECT_ROOT/build/$SUITE/$ARCH_TYPE/benchmarks/$BENCHMARK.riscv"
else
    echo "Unknown suite: $SUITE"
    exit 1
fi

REL_BINARY="$(realpath --relative-to="$DIR" "$BINARY")"

if [[ ! -f $BINARY ]]; then
    echo "$BINARY does not exist, build the benchmark first"
    exit 1
fi

sed -e "s|@NAME@|$BENCHMARK|g" \
    -e "s|@ARCH@|$ARCH_TYPE|g" \
    -e "s|@QUANTUM@|$QUANTUM|g" \
    -e "s|@ELF@|$REL_BINARY|g" \
    "$TEMPLATE" > "$DIR/${BENCHMARK}_${ARCH_TYPE}.cfg"
