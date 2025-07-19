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

	for env in environments/*; do
		echo "Validating environment: $env"

		NAMESPACE=$(jq -r ".spec.namespace" <"$env/spec.json")
		if [[ -z $NAMESPACE ]]; then
			echo "No namespace found in $env/spec.json"
			exit 1
		fi
		echo "Namespace: ${NAMESPACE} (${dir}/${env})"
		kubectl config set-context --current --namespace="$NAMESPACE"
		DIFFS=$(tk show --dangerous-allow-redirect "$env" |
			kubectl diff -n "${NAMESPACE}" --server-side=true -f - --force-conflicts=true) || true
		if [ -n "$DIFFS" ]; then
			# echo "::notice file=${dir},env=${env},title=${NAMESPACE}-Diffs::${DIFFS}"
			echo "::group::FOUND DIFFS ${dir} ${env} title=${NAMESPACE}"
			echo "$DIFFS"
			echo "::endgroup::"
		else
			echo "No differences found in $env."
		fi
	done

	echo "end $dir"
done
echo "All Tanka environments diffed successfully."
