#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")" >/dev/null
CI_TOOLS=$(pwd)
WORKSPACE=$(dirname "$CI_TOOLS")
echo "WORKSPACE: $WORKSPACE"

WORK_DIR=/tmp/rules
REPORT_DIR="$HOME/pint-report"
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
mkdir -p "$REPORT_DIR"
mimirtool rules print \
	--address=https://mimir.local.symmatree.com --id=anonymous \
	--output-dir="$WORK_DIR"
# Move to work_dir so we can use "find ." to generate relative paths for input and output.
cd "$WORK_DIR"
# NOTE: pint doesn't write to stdout, we need stderr
# 1 worker to keep from melting mimir.
# shellcheck disable=SC2156
find . -name "*.yaml" \
	-exec bash -c 'mkdir -p "$(dirname /home/jovyan/pint-report/{})"' \; \
	-exec pint --workers 1 --config "$WORKSPACE/.pint.hcl" --log-level info lint --json "$REPORT_DIR/{}.json" --min-severity warning "{}" \;
