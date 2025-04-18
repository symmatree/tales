#!/usr/bin/env bash
set -euxo pipefail
OUT_DIR=`pwd`
pushd "$(dirname "$0")"
SAVE_DIR=`pwd`

helm dep update
popd

if  ! kubectl get namespace argocd ; then
  kubectl create namespace argocd \
    && kubectl label namespace argocd pod-security.kubernetes.io/warn=baseline
fi
# eval $(op signin)

# helm upgrade --install --namespace argocd argocd "${SAVE_DIR}"
# kubectl apply -f "${SAVE_DIR}/issuers.yaml"

helm template argocd ${SAVE_DIR} --namespace argocd > ${SAVE_DIR}/manifest.yaml
kubectl apply -f ${SAVE_DIR}/manifest.yaml -n argocd --server-side 
rm ${SAVE_DIR}/manifest.yaml
