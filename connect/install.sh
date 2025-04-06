#!/usr/bin/env bash
set -euxo pipefail
OUT_DIR=`pwd`
pushd "$(dirname "$0")"
SAVE_DIR=`pwd`

helm dep update
popd

if  ! kubectl get namespace connect ; then
    kubectl create namespace connect \
    && kubectl label namespace connect pod-security.kubernetes.io/warn=baseline
fi

eval $(op signin)

if ! kubectl get secret onepassword-token -n connect ; then
    kubectl create secret generic -n connect \
        onepassword-token \
        "--from-literal=token=$(op connect token create tales-connect-token --server tales-secrets --vault tales-secrets)"
fi

if ! kubectl get secret op-credentials -n connect ; then
    kubectl create secret generic -n connect \
        op-credentials \
        "--from-literal=1password-credentials.json=$(op read op://tales-secrets/tales-secrets-1password-credentials.json/1password-credentials.json)"
fi

helm upgrade --install --namespace connect connect "${SAVE_DIR}"
