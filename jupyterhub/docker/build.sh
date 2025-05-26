#! /usr/bin/env bash
set -euo pipefail
OUT_DIR=`pwd`
pushd "$(dirname "$0")"
SAVE_DIR=`pwd`

TOKEN=`op read op://tales-secrets/jupyterhub-github-token/password`
REPOUSER=`op read op://tales-secrets/jupyterhub-github-token/username`
IMAGE=ghcr.io/symmatree/internal/datascience-notebook-ssh
TAG=$(date +%Y-%m-%d)
buildah build --network=host \
  --layers \
  --disable-compression=false \
  --creds "$REPOUSER:$TOKEN" \
  --cache-from ${IMAGE}-cache \
  --cache-to ${IMAGE}-cache \
  --tag $IMAGE:$TAG $SAVE_DIR

buildah push \
  --creds "$REPOUSER:$TOKEN" \
  --compression-format=zstd \
  $IMAGE:$TAG
