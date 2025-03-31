#!/usr/bin/env bash
set -euxo pipefail
OUT_DIR=`pwd`
pushd "$(dirname "$0")"
SAVE_DIR=`pwd`
popd

helm install --namespace cilium cilium "${SAVE_DIR}"
