#! /usr/bin/env bash
set -euo pipefail
OUT_DIR=`pwd`
pushd "$(dirname "$0")"
SAVE_DIR=`pwd`

TOKEN=`op read op://tales-secrets/jupyterhub-github-token/password`
REPOUSER=`op read op://tales-secrets/jupyterhub-github-token/username`
IMAGE=ghcr.io/symmatree/internal/datascience-notebook-ssh
TAG=$(date +%Y-%m-%d)

BASE_IMAGE=quay.io/jupyter/datascience-notebook
# https://quay.io/repository/jupyter/datascience-notebook?tab=tags&tag=latest
BASE_TAG=2025-05-24

# Pull first to avoid collision on creds.
buildah pull $BASE_IMAGE:$BASE_TAG
buildah build --network=host \
  --layers=true \
  --disable-compression=false \
  --creds "$REPOUSER:$TOKEN" \
  --build-arg BASE_IMAGE=$BASE_IMAGE \
  --build-arg BASE_TAG=$BASE_TAG \
  --cache-from ${IMAGE}-cache \
  --cache-to ${IMAGE}-cache \
  --force-rm=true \
  --rm=true \
  --tag $IMAGE:$TAG $SAVE_DIR

buildah push \
  --creds "$REPOUSER:$TOKEN" \
  --compression-format=zstd \
  $IMAGE:$TAG

# Stop any lingering containers
buildah rm --all
# Clean potentially large cache folders
buildah prune --all
