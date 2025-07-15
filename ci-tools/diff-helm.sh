#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")" >/dev/null
CI_TOOLS=$(pwd)
WORKSPACE=$(dirname "$CI_TOOLS")
echo "WORKSPACE: $WORKSPACE"

cd "${WORKSPACE}"
CHARTS=("$@")
if [[ ${#CHARTS[@]} == 0 ]]; then
	mapfile -t CHARTS < <(find . -name vendor -prune -o -name Chart.yaml -exec dirname "$(realpath {})" \;)
fi

for chart in "${CHARTS[@]}"; do
	NAMESPACE=$(basename "$chart")
	echo "Namespace: ${NAMESPACE} (${chart})"
	cd "$chart"
	DIFFS=$("${WORKSPACE}/ci-tools/helm.sh" template --is-upgrade --no-hooks --skip-crds "$NAMESPACE" -n "$NAMESPACE" . |
		kubectl diff -n "${NAMESPACE}" --server-side=true -f - --force-conflicts=true) || true
	if [ -n "$DIFFS" ]; then
		echo "::notice file=${chart},title=${NAMESPACE}-Diffs::${DIFFS}"
		# echo "::group::Diffs for $NAMESPACE"
		# echo "Differences found in $chart:"
		# echo "$DIFFS"
		# echo "::endgroup::"
	else
		echo "No differences found in $chart."
	fi
	echo "end $chart"
done
echo "All Helm charts diffed successfully."
