#!/bin/env bash

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

LINUX_DIR="/app/output/build/linux-6.6"
LINUX_DIR_HOST="$DIR/BUILD/build/linux-6.6"

if [ ! -d "${LINUX_DIR_HOST}" ]; then
	$DIR/files/scripts/run_container "-it -e FORCE_UNSAFE_CONFIGURE=1" "make -C /app/buildroot O=/app/output linux-menuconfig"
fi;

cp "$DIR/files/config/linux_config" "${LINUX_DIR_HOST}/.config"
$DIR/files/scripts/run_container "-it" "cd $LINUX_DIR && make menuconfig ARCH=riscv"
cp "${LINUX_DIR_HOST}/.config" "$DIR/files/config/linux_config"
