FROM spencertipping/ssh-base:latest

# Prevent the keyboard-configuration package setup from blocking the apt-get
# install below
ADD etc-keyboard /etc/default/keyboard

ENV DEBIAN_FRONTEND noninteractive

RUN sed -i 's/^#\s*\(deb.*multiverse\)$/\1/g; s/^#\s*deb-src/deb-src/g' \
        /etc/apt/sources.list \
 && apt-get update \
 && apt-get install -y \
        rsync tree build-essential ranger \
        man manpages manpages-posix manpages-dev \
        tmux htop atop iotop curl \
        vim apt-transport-https git git-lfs \
        nmap sshuttle pv netcat-traditional socat iputils-ping dnsutils \
        xzip zip unzip unrar-free lzop liblz4-tool pbzip2 pigz zpaq lrzip \
        p7zip-full zstd \
        ffmpeg imagemagick \
        python3 perl jq perl-doc ascii \
        python3-scipy python3-pip python-is-python3 \
        gnuplot-nox \
        npm \
        libtinfo5 libtinfo6 \
        rustc rust-doc rust-gdb cargo \
        golang \
        libsys-mmap-perl \
 && curl -sSL https://get.haskellstack.org/ | sh

# NB: ARG user is here because nothing above depends on it (so we want to reuse
# those layers)
ARG user=pm
RUN useradd -ms /bin/bash $user -G adm,sudo \
 && echo "%sudo ALL=NOPASSWD: ALL" >> /etc/sudoers

ADD $user-id_rsa.pub $user-user-setup install-perf /home/$user/
RUN chown $user:$user /home/$user/$user-id_rsa.pub \
 && chmod 0700 /home/$user/$user-id_rsa.pub \
 && mkdir -p /run/user/1000 && chown $user:$user /run/user/1000

USER $user
ENV USER=$user
WORKDIR /home/$user
RUN bash $user-user-setup

VOLUME /mnt

USER root
WORKDIR /
