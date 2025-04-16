#!/usr/bin/env bash
set -euxo pipefail
OUT_DIR=`pwd`
pushd "$(dirname "$0")"
SAVE_DIR=`pwd`

helm dep update
popd

if  ! kubectl get namespace external-dns ; then
    kubectl create namespace external-dns \
    && kubectl label namespace external-dns pod-security.kubernetes.io/warn=baseline
fi
# kubectl apply -n external-dns -f ${SAVE_DIR}/external-dns-secret.yaml
# helm upgrade --install --namespace external-dns external-dns "${SAVE_DIR}"
