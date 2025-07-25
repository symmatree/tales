#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")" >/dev/null
CI_TOOLS=$(pwd)
WORKSPACE=$(dirname "$CI_TOOLS")
echo "WORKSPACE: $WORKSPACE"

TOKEN=$(op read op://tales-secrets/grafana-prom-metrics-check-token/TOKEN)
GRAFANA=https://borgmon.local.symmatree.com
WORK_DIR=/tmp/rules
REPORT_DIR="$HOME/pint-report"
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
mkdir -p "$REPORT_DIR"
python "$WORKSPACE/../dashpint/extract.py" "--grafana-token=$TOKEN" "--grafana-url=$GRAFANA" "--out-dir=$WORK_DIR"
# Move to work_dir so we can use "find ." to generate relative paths for input and output.
cd "$WORK_DIR"
# NOTE: pint doesn't write to stdout, we need stderr
find . -name "*.yaml" -exec \
	pint --no-color --config "$WORKSPACE/.pint.hcl" --log-level info lint --json "$REPORT_DIR/$(basename "{}" .yaml).json" --min-severity warning "{}" \;
