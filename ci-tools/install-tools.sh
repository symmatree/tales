#!/usr/bin/env bash

set -euo pipefail
TOOLDIR="${TOOLDIR:-/usr/local/bin}"
DEFAULT_EGET="curl https://zyedidia.github.io/eget.sh | sh"
# Overridden in CI to point to vendored version.
GET_EGET="${GET_EGET:-$DEFAULT_EGET}"

echo "GET_EGIT=${GET_EGET}"
mkdir -p "${TOOLDIR}"
pushd "${TOOLDIR}" >/dev/null
if ! [ -f ./eget ]; then
	bash -c "$GET_EGET"
fi
if ! [ -f ./kubeconform ]; then
	if ! command -v kubeconform >/dev/null 2>&1; then
		./eget --upgrade-only yannh/kubeconform
	fi
fi
if ! [ -f ./tk ]; then
	if ! command -v tk >/dev/null 2>&1; then
		./eget --upgrade-only grafana/tanka
		mv tanka tk
	fi
fi
if ! [ -f ./jb ]; then
	if ! command -v jb >/dev/null 2>&1; then
		./eget --upgrade-only jsonnet-bundler/jsonnet-bundler
		mv jsonnet-bundler jb
	fi
fi
if ! [ -f ./helm ]; then
	if ! command -v helm >/dev/null 2>&1; then
		./eget --upgrade-only https://get.helm.sh/helm-v3.18.2-linux-amd64.tar.gz --file helm
	fi
fi
popd >/dev/null
