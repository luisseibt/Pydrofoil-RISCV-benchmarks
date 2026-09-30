###############################################################################
#                                                                             #
# Copyright 2026 Chiara Ghinami  Nils Bosbach                                 #
#                                                                             #
# This software is licensed under the MIT license found in the                #
# LICENSE file at the root directory of this source tree.                     #
#                                                                             #
###############################################################################

FROM debian:bookworm
ENV TERM=xterm-256color
RUN apt-get update \
	&& apt-get -y install \
        build-essential \
        which \
        sed \
        make \
        binutils \
        diffutils \
        gcc \
        g++ \
        bash \
        patch \
        gzip \
        bzip2 \
        perl \
        tar \
        cpio \
        unzip \
        rsync \
        file \
        bc \
        findutils \
        wget \
        python3 \
        curl \
        libncurses5-dev \
        libncursesw5-dev \
        ncurses-term \
        libssl-dev \
        libelf-dev \
        bc \
        wget \
        cmake
WORKDIR /app/build
