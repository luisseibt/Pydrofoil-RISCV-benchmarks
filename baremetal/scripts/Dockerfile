###############################################################################
#                                                                             #
# Copyright 2026 Chiara Ghinami                                               #
#                                                                             #
# This software is licensed under the MIT license found in the                #
# LICENSE file at the root directory of this source tree.                     #
#                                                                             #
###############################################################################

FROM ubuntu:22.04
ENV TERM=xterm-256color
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get -y install --no-install-recommends \
        build-essential \
        python3 \
        scons \
        curl \
        ca-certificates \
        xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Prebuilt newlib toolchains from riscv-gnu-toolchain
ARG TOOLCHAIN_VERSION=2026.08.27
ARG TOOLCHAIN_URL=https://github.com/riscv-collab/riscv-gnu-toolchain/releases/download/${TOOLCHAIN_VERSION}

#---- curl ----#
# -f: fail on HTTPS error, so that tar does not run if curl fails
# -L: follow redirects
#---- tar ----#
# -x: extract
# -J: work with xz compression
# --strip-components: remove the first dir from every path while extracting (eg riscv32-elf-ubuntu-24.04-gcc)
RUN mkdir -p /opt/riscv32 /opt/riscv64 \
    && curl -fL -o /tmp/riscv32.tar.xz \
        "${TOOLCHAIN_URL}/riscv32-elf-ubuntu-22.04-gcc.tar.xz" \
    && tar -xJf /tmp/riscv32.tar.xz \
        -C /opt/riscv32 --strip-components=1 \
    && curl -fL -o /tmp/riscv64.tar.xz \
        "${TOOLCHAIN_URL}/riscv64-elf-ubuntu-22.04-gcc.tar.xz" \
    && tar -xJf /tmp/riscv64.tar.xz \
        -C /opt/riscv64 --strip-components=1 \
    && rm /tmp/riscv32.tar.xz /tmp/riscv64.tar.xz

ENV PATH="/opt/riscv32/bin:/opt/riscv64/bin:${PATH}"

WORKDIR /app/build
