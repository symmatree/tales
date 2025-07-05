#!/usr/bin/env bash
set -euo pipefail

mapfile -t urls < <(find . -name "Chart.yaml" -exec yq ".dependencies[] | .repository" "{}" ';' | sort | uniq)
repo_num=1
for url in "${urls[@]}"; do
	if ! helm repo list | grep -q "$url"; then
		echo "Adding Helm repository: $url"
		helm repo add "$(basename "$url")-${repo_num}" "$url"
		((++repo_num))
	else
		echo "Helm repository already exists: $url"
	fi
done
