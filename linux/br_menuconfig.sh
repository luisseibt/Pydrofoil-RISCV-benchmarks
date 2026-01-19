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

mkdir -p $DIR/build

cp $DIR/files/config/br_config $DIR/build/.config
$DIR/files/scripts/run_container "-it -e BR2_DEFCONFIG=/app/files/config/br_config" " make -C /app/buildroot O=/app/build defconfig && make -C /app/buildroot O=/app/build menuconfig"
cp $DIR/build/.config $DIR/files/config/br_config