#!/usr/bin/env bash
set -euo pipefail
# Most templates are fine but any with structural templating will fail.
# Use .helm.yaml naming to avoid them.
# The charts/ dir is vendor helm and we don't want to do anything to it.
time find . \( -name "*.helm.yaml" -o -type d -name charts \) -prune -o -name "*.yaml" -exec yq -i -P "{}" ';'
time find . \( -type d -name charts \) -prune -o -name "*.yml" -exec yq -i -P "{}" ';'
