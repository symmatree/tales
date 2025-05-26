ARG BASE_IMAGE=quay.io/jupyter/datascience-notebook
# https://quay.io/repository/jupyter/datascience-notebook?tab=tags&tag=latest
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

COPY systemctl3.py /usr/bin/systemctl
# RUN test -L /bin/systemctl || ln -sf /usr/bin/systemctl /bin/systemctl
RUN rm -fv /etc/ssh/sshd_not_to_be_run
RUN systemctl enable ssh
