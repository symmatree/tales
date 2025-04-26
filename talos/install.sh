#!/usr/bin/env bash
set -euo pipefail
OUT_DIR=`pwd`
pushd "$(dirname "$0")"
SAVE_DIR=`pwd`

op read op://tales-secrets/talos-secrets.yaml/notesPlain > ./secrets.yaml
echo "talosctl gen config"
# endpoint seems to be mandatory but 
talosctl gen config \
  --with-secrets ./secrets.yaml \
  --config-patch "@${SAVE_DIR}/talos-patch-all.yaml" \
  --config-patch-control-plane "@${SAVE_DIR}/talos-patch-control.yaml" \
  --config-patch-worker "@${SAVE_DIR}/talos-patch-worker.yaml" \
  tales https://talos-control.local.symmatree.com:6443
rm secrets.yaml

TALOSCONFIG=./talosconfig talosctl config endpoint talos-control.local.symmatree.com
TALOSCONFIG=./talosconfig talosctl config node talos-control.local.symmatree.com

echo "Writing generated files to 1password"
op item edit --vault tales-secrets "talos-worker.yaml" "notesPlain=$(cat worker.yaml)" > /dev/null
op item edit --vault tales-secrets "talos-talosconfig" "notesPlain=$(cat talosconfig)" > /dev/null
op item edit --vault tales-secrets "talos-controlplane.yaml" "notesPlain=$(cat controlplane.yaml)" > /dev/null

echo "Copying talosconfig to ~/.talos/config"
cp talosconfig ~/.talos/config
rm talosconfig
