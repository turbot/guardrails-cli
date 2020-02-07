#!/usr/bin/env bash
# variables and functions
export TURBOT_MODS_DIR="../example-mods/turbot"
export TURBOT_WORKSPACE_PROFILE="acceptance"
export USER="acceptance"
export PASS="Xsnjdfe"

if [ -z "$TURBOT_MODS_DIR" ]; then
  echo "TURBOT_MOD_ROOT environment variable must be set to run acceptance tests"
  exit 1
fi

if [ -z "TURBOT_WORKSPACE_PROFILE" ]; then
  echo "TURBOT_WORKSPACE_PROFILE environment variable must be set to run acceptance tests"
  exit 1
fi

if [ -z "USER" ]; then
  echo "USER environment variable must be set to run acceptance tests"
  exit 1
fi

if [ -z "PASS" ]; then
  echo "USER environment variable must be set to run acceptance tests"
  exit 1
fi