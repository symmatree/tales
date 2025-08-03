#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")" >/dev/null
CI_TOOLS=$(pwd)
WORKSPACE=$(dirname "$CI_TOOLS")
echo "WORKSPACE: $WORKSPACE"

cd "${WORKSPACE}"
if [[ ${UPDATE:-1} == 1 ]]; then
	"$WORKSPACE/ci-tools/helm-add-repos.sh"
	helm repo update
fi

CHARTS=("$@")
if [[ ${#CHARTS[@]} == 0 ]]; then
	mapfile -t CHARTS < <(find "$(pwd)" -name vendor -prune -o -name Chart.yaml -exec dirname "{}" \;)
fi
for chart in "${CHARTS[@]}"; do
	echo "$chart"
	cd "$chart"
	if [[ ${UPDATE:-1} == 1 ]]; then
		helm dep build --skip-refresh
	fi
	helm lint .
	"$WORKSPACE/ci-tools/helm.sh" template --dry-run=client . |
		"$WORKSPACE/ci-tools/kubeconform.sh"
	echo "end $chart"
done
echo "All Helm charts validated successfully."
