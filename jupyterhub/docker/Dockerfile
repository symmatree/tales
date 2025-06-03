ARG BASE_IMAGE=quay.io/jupyter/datascience-notebook
# https://quay.io/repository/jupyter/datascience-notebook?tab=tags&tag=latest
ARG BASE_TAG=2025-05-24
FROM $BASE_IMAGE:$BASE_TAG

USER root

RUN apt-get update \
    && apt-get dist-upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    --no-install-recommends \
    ansible \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

COPY install-tools.yaml /tmp/install-tools.yaml
# Fix linuxbrew permissions because we're running as root.
RUN ansible-playbook -v /tmp/install-tools.yaml -i localhost, --connection=local \
    && rm -rf /var/lib/apt/lists/* \
    && chown -R 1000:100 /home/linuxbrew

COPY systemctl3.py /usr/bin/systemctl
COPY sshd_config /etc/ssh/sshd_config
RUN rm -fv /etc/ssh/sshd_not_to_be_run
RUN systemctl enable ssh
