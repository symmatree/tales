#!/usr/bin/env bash
set -euxo pipefail
OUT_DIR=`pwd`
pushd "$(dirname "$0")"
SAVE_DIR=`pwd`
popd

helm dep update

# Need the gateway CRDs for Cilium to fully install.
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/standard-install.yaml

# Talos installs a strict pod security policy, which we can override with namespace labels.
# `enforce` is what it actually allows you to do, but `warn` will log a warning that looks awfully fatal (at least to me) and send you off on
# a wild goose chase, so we disable both.

kubectl create namespace cilium \
  && kubectl label namespace cilium pod-security.kubernetes.io/enforce=privileged \
  && kubectl label namespace cilium pod-security.kubernetes.io/warn=privileged

helm install --namespace cilium cilium "${SAVE_DIR}"
kubectl apply -f "${SAVE_DIR}/additional-manifests.yaml"
