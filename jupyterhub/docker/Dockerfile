ARG BASE_IMAGE=quay.io/jupyter/datascience-notebook
ARG BASE_TAG=2025-05-24
FROM $BASE_IMAGE:$BASE_TAG

USER root
# `find` invocation from https://github.com/antmelekhin/docker-systemd/blob/main/ubuntu/24.04.Dockerfile
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    --no-install-recommends \
    apt-utils dialog \
    gosu stow curl wget zsh zsh-autosuggestions zsh-syntax-highlighting \
    sudo build-essential procps file git openssh-server \
    python3-pip python3-venv tree bsdmainutils \
    ubuntu-server aspell \
    && rm -rf /var/lib/apt/lists/* \
    && find /etc/systemd/system \
    /lib/systemd/system \
    -path '*.wants/*' \
    -not -name '*journald*' \
    -not -name '*systemd-tmpfiles*' \
    -not -name '*systemd-user-sessions*' \
    -print0 | xargs -0 rm -vf

# Ref https://github.com/mike-matera/cloud-native-server/blob/main/containers/ubuntu-jammy/Dockerfile
# RUN rm /etc/systemd/system/network-online.target.wants/systemd-networkd-wait-online.service \
#     && rm /etc/systemd/system/multi-user.target.wants/systemd-resolved.service \
#     && rm /lib/systemd/system/systemd-resolved.service \
#     && rm /etc/resolv.conf \
#     && rm /etc/systemd/system/multi-user.target.wants/snapd.* \
#     && rm /etc/systemd/system/multi-user.target.wants/networkd-dispatcher.service 
