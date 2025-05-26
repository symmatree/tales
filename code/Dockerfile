ARG BASE_IMAGE=quay.io/jupyter/datascience-notebook
ARG BASE_TAG=2025-05-24
FROM $BASE_IMAGE:$BASE_TAG
ARG USERNAME=symmetry
ARG UID=1000
ENV USER_ID=$UID
ENV GROUP_ID=$UID
ENV USERNAME=$USERNAME


RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    gosu stow curl wget zsh zsh-autosuggestions zsh-syntax-highlighting \
    sudo build-essential procps file git openssh-server \
    python3-pip python3-venv tree bsdmainutils \
    ubuntu-server aspell \
    && rm -rf /var/lib/apt/lists/*
RUN groupadd -g $UID $USERNAME && \
    useradd -u $UID $USERNAME --create-home --shell /usr/bin/zsh $USERNAME -g $USERNAME

# Ref https://github.com/mike-matera/cloud-native-server/blob/main/containers/ubuntu-jammy/Dockerfile
RUN rm /etc/systemd/system/network-online.target.wants/systemd-networkd-wait-online.service \
    && rm /etc/systemd/system/multi-user.target.wants/systemd-resolved.service \
    && rm /lib/systemd/system/systemd-resolved.service \
    && rm /etc/resolv.conf \
    && rm /etc/systemd/system/multi-user.target.wants/snapd.* \
    && rm /etc/systemd/system/multi-user.target.wants/networkd-dispatcher.service 
