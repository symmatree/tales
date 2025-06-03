#!/usr/bin/env bash

# Standalone script for bootstrapping to ansible from a fresh Ubuntu install.
# Pull these two files, run the installer, then use `gh repo clone` to
# get the rest of the repos to work with.
set -euo pipefail
cd "$(dirname "$0")"
SAVE_DIR=`pwd`

sudo apt-get update \
    && sudo apt-get dist-upgrade -y \
    && DEBIAN_FRONTEND=noninteractive sudo apt-get install -y \
    --no-install-recommends \
    ansible \
    apt-transport-https ca-certificates \
    apt-utils dialog \
    sudo procps file git \
    tree bsdmainutils \
    aspell

ansible-playbook -v ./install-tools.ansible.yaml -i localhost, --connection=local
