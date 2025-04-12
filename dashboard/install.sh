#!/usr/bin/env bash
set -euxo pipefail
OUT_DIR=`pwd`
pushd "$(dirname "$0")"
SAVE_DIR=`pwd`

helm dep update
popd

if  ! kubectl get namespace dashboard ; then
    kubectl create namespace dashboard \
    && kubectl label namespace dashboard pod-security.kubernetes.io/warn=baseline
fi

helm upgrade --install --namespace dashboard dashboard "${SAVE_DIR}"
