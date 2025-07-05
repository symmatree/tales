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
	./eget --upgrade-only yannh/kubeconform
fi
if ! [ -f ./tk ]; then
	./eget --upgrade-only grafana/tanka
	mv tanka tk
fi
if ! [ -f ./jb ]; then
	./eget --upgrade-only jsonnet-bundler/jsonnet-bundler
	mv jsonnet-bundler jb
fi
if ! [ -f ./helm ]; then
	./eget --upgrade-only https://get.helm.sh/helm-v3.18.2-linux-amd64.tar.gz --file helm
fi
popd >/dev/null
