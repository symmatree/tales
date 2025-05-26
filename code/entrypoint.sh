#!/bin/bash
set -euo pipefail

if [ "$(id -u)" = '0' ]
then
    # We're root, do privileged setup.
    chown -R $USER_ID:$GROUP_ID /home/$USERNAME
    exec gosu $USERNAME "$0" "$@"
else
    exec "$@"
fi
