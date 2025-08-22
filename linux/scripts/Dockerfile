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
        wget
WORKDIR /app/build
