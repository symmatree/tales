#!/usr/bin/env bash
set -euo pipefail
# Exclude "templates" because they are not valid YAML (or sometimes they are but get mangled!)
# find . -type d -name templates -prune -o -name "*.helm.yaml" -prune -o -name "*.yaml" -exec yq -i -P "{}" ';'
find . -name "*.helm.yaml" -prune -o -name "*.yaml" -exec yq -i -P "{}" ';'
find . -name "*.yml" -exec yq -i -P "{}" ';'
