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

	NAMESPACE=$(basename "$dir")
	echo "Namespace: ${NAMESPACE} (${dir})"
	kubectl config set-context --current --namespace="$NAMESPACE"
	DIFFS=$(tk show --dangerous-allow-redirect \
		environments/default |
		kubectl diff -n "${NAMESPACE}" --server-side=true -f - --force-conflicts=true) || true
	if [ -n "$DIFFS" ]; then
		echo "::notice file=${dir},title=${NAMESPACE}-Diffs::${DIFFS}"
		#echo "Differences found in $dir:"
		#echo "$DIFFS"
		# echo "::endgroup::"
	else
		echo "No differences found in $dir."
	fi
	echo "end $dir"
done
echo "All Tanka environments diffed successfully."
