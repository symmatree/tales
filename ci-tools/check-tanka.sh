#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")" >/dev/null
CI_TOOLS=$(pwd)
WORKSPACE=$(dirname "$CI_TOOLS")
echo "WORKSPACE: $WORKSPACE"
TANKA=("$@")
if [[ ${#TANKA[@]} == 0 ]]; then
	cd "${WORKSPACE}"
	mapfile -t TANKA < <(find "$(pwd)" -name vendor -prune -o -name jsonnetfile.json -exec dirname "{}" \;)
fi
for dir in "${TANKA[@]}"; do
	echo "$dir"
	cd "$dir"
	if [[ -n ${UPDATE:-true} ]]; then
		jb update
	fi
	for env in environments/*; do
		echo "Validating environment: $env"
		tk show --dangerous-allow-redirect "$env" |
			"$WORKSPACE/ci-tools/kubeconform.sh"
		echo "Environment $env done."
	done
	echo "end $dir"
done
echo "All Tanka environments validated successfully."
