#!/usr/bin/env bash
set -euxo pipefail
OUT_DIR=`pwd`
pushd "$(dirname "$0")"
SAVE_DIR=`pwd`

helm dep update
popd

if  ! kubectl get namespace cert-manager ; then
  kubectl create namespace cert-manager \
    && kubectl label namespace cert-manager pod-security.kubernetes.io/warn=baseline
fi

# If not logged in, op read b
eval $(op signin)

if ! kubectl get secret clouddns-sa --namespace cert-manager ; then
  kubectl create secret generic clouddns-sa --namespace cert-manager \
    --from-literal=credential.json="$(op read  op://tales-secrets/cert-manager-clouddns-sa/credential.json)"
fi

helm upgrade --install --namespace cert-manager cert-manager "${SAVE_DIR}"
