#!/usr/bin/env bash
set -euxo pipefail
OUT_DIR=`pwd`
pushd "$(dirname "$0")"
SAVE_DIR=`pwd`
popd

talosctl gen config \
  --with-secrets ~/secrets.yaml \
 --config-patch "@${SAVE_DIR}/talos-patch-all.yaml" \
 --config-patch-control-plane "@${SAVE_DIR}/talos-patch-control.yaml" \
 --config-patch-worker "@${SAVE_DIR}/talos-patch-worker.yaml" \
  tales https://talos-control.local.symmatree.com:6443
