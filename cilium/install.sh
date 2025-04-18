#!/usr/bin/env bash
set -euxo pipefail
OUT_DIR=`pwd`
pushd "$(dirname "$0")"
SAVE_DIR=`pwd`

helm dep update

popd

# Need the gateway CRDs for Cilium to fully install.
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/standard-install.yaml

# Talos installs a strict pod security policy, which we can override with namespace labels.
# `enforce` is what it actually allows you to do, but `warn` will log a warning that looks awfully fatal (at least to me) and send you off on
# a wild goose chase, so we disable both.

if  ! kubectl get namespace cilium ; then
  kubectl create namespace cilium \
    && kubectl label namespace cilium pod-security.kubernetes.io/enforce=privileged \
    && kubectl label namespace cilium pod-security.kubernetes.io/warn=privileged
fi

# helm upgrade --install --namespace cilium cilium "${SAVE_DIR}"
helm template --namespace cilium cilium "${SAVE_DIR}" > ${SAVE_DIR}/manifest.yaml
kubectl apply -f ${SAVE_DIR}/manifest.yaml --server-side
rm ${SAVE_DIR}/manifest.yaml
echo "Wait for CRDs to become available"
sleep 60
kubectl apply -f "${SAVE_DIR}/additional-manifests.yaml" --server-side
