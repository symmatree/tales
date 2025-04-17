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
    # thanks to https://www.1password.community/discussions/developers/loadlocalauthv2-failed-to-credentialsdatafrombase64/84597
    # and its pointer to https://github.com/1Password/connect-helm-charts/blob/main/charts/connect/templates/connect-credentials.yaml#L14
    # where the plaintext is base64 encoded before being put in the secret (probably due to misunderstanding).
    kubectl create secret generic -n connect \
        op-credentials \
        "--from-literal=1password-credentials.json=$(op read op://tales-secrets/tales-secrets-1password-credentials.json/1password-credentials.json | base64)"
fi

helm upgrade --install --namespace connect connect "${SAVE_DIR}"
