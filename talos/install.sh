#!/usr/bin/env bash
set -euxo pipefail
OUT_DIR=`pwd`
pushd "$(dirname "$0")"
SAVE_DIR=`pwd`

op item read op://tales-secrets/talos/secrets.yaml/notesPlain > ./secrets.yaml
talosctl gen config \
  --with-secrets ./secrets.yaml \
 --config-patch "@${SAVE_DIR}/talos-patch-all.yaml" \
 --config-patch-control-plane "@${SAVE_DIR}/talos-patch-control.yaml" \
 --config-patch-worker "@${SAVE_DIR}/talos-patch-worker.yaml" \
  tales https://talos-control.local.symmatree.com:6443
rm secrets.yaml

TALOSCONFIG=./talosconfig talosctl config endpoint talos-control.local.symmatree.com

op item edit --vault tales-secrets "talos/worker.yaml" "notesPlain=$(cat worker.yaml)"
op item edit --vault tales-secrets "talos/talosconfig" "notesPlain=$(cat talosconfig)"
op item edit --vault tales-secrets "talos/controlplane.yaml" "notesPlain=$(cat controlplane.yaml)"

cp talosconfig ~/.talos/config
talosctl config endpoint 
rm talosconfig
