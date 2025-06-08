#!/usr/bin/env bash
set -euo pipefail

urls=( $(find . -name "Chart.yaml" -exec yq ".dependencies[] | .repository" "{}" ';' | sort | uniq) )
repo_num=1
for url in "${urls[@]}"; do
  if ! helm repo list | grep -q "$url"; then
    echo "Adding Helm repository: $url"
    helm repo add "$(basename "$url")-${repo_num}" "$url"
    let repo_num=$((repo_num + 1))
  else
    echo "Helm repository already exists: $url"
  fi
done
