#!/usr/bin/env bash
set -euxo pipefail
OUT_DIR=`pwd`
pushd "$(dirname "$0")"
SAVE_DIR=`pwd`

helm dep update

popd

# This needs to agree with what we install later to read them.
export VERSION=v0.81.0
kubectl apply --server-side -f "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${VERSION}/example/prometheus-operator-crd-full/monitoring.coreos.com_servicemonitors.yaml"
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/standard-install.yaml

echo "Wait for CRDs to become available"
sleep 60

# Talos installs a strict pod security policy, which we can override with namespace labels.
# `enforce` is what it actually allows you to do, but `warn` will log a warning that looks awfully fatal (at least to me) and send you off on
# a wild goose chase, so we disable both.

kubectl create namespace cilium \
  && kubectl label namespace cilium pod-security.kubernetes.io/enforce=privileged \
  && kubectl label namespace cilium pod-security.kubernetes.io/warn=privileged

# helm upgrade --install --namespace cilium cilium "${SAVE_DIR}"
helm template cilium ${SAVE_DIR} --namespace cilium > ${SAVE_DIR}/manifest.yaml
# Close to what argo itself will do.
kubectl apply -f ${SAVE_DIR}/manifest.yaml -n cilium --server-side 
rm ${SAVE_DIR}/manifest.yaml

echo "Wait for CRDs to become available"
sleep 60
kubectl apply -f "${SAVE_DIR}/additional-manifests.yaml"
