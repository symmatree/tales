#!/usr/bin/env bash
set -euo pipefail
CACHE_DIR="${RUNNER_TEMP:=/tmp}/cache/kubeconform"
mkdir -p "${CACHE_DIR}"
cat - | kubeconform \
   -cache "${CACHE_DIR}" \
  -schema-location default \
  -schema-location "https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json" \
  -schema-location "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/{{.NormalizedKubernetesVersion}}/{{.ResourceKind}}.json" \
  -output pretty -strict
