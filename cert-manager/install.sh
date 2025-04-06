#!/usr/bin/env bash
set -euxo pipefail
OUT_DIR=`pwd`
pushd "$(dirname "$0")"
SAVE_DIR=`pwd`
popd

kubectl create namespace cert-manager
  && kubectl label namespace cert-manager pod-security.kubernetes.io/warn=baseline
kubectl create secret generic clouddns-sa --namespace cert-manager \
   --from-literal=key.json="$(op read  op://tales-secrets/cert-manager/clouddns-sa/notesPlain)"
helm install --namespace cert-manager cert-manager "${SAVE_DIR}/cert-manager"
kubectl apply -f "${SAVE_DIR}/issuers.yaml"
