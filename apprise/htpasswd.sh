#! /usr/bin/env bash
set -euo pipefail
# TODO: Refactor somewhere more general.

VAULT=tales-secrets
ITEM=apprise-admin
htpasswd=$(op item get --vault $VAULT "$ITEM" --fields password |
	htpasswd -b -n -i "$(op item get --vault $VAULT "$ITEM" --fields username)")
op item edit --vault $VAULT "$ITEM" "\\.htpasswd=$htpasswd"
