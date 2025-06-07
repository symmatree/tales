#! /usr/bin/env bash
set -euo pipefail
OUT_DIR=`pwd`
pushd "$(dirname "$0")"
SCRIPT_DIR=`pwd`

# TODO: Refactor somewhere more general.

VAULT=tales-secrets
ITEM=jupyterhub-github-token
CURR_JSON=`op item get --vault $VAULT "$ITEM" --format json`
SECRET=`echo $CURR_JSON | jq -f $SCRIPT_DIR/image-pull-secret.jq`
op item edit --vault $VAULT "$ITEM" "\\.dockerconfigjson=$SECRET"
