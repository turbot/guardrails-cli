#!/bin/bash

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"
BUILD_PATH="$SCRIPT_PATH/config/build.sh"

#if there are no functions, exit now to avoid errors
if [ ! -d "functions" ]; then
  exit 0
fi

# Build all controls
targets=$(find functions -maxdepth 1 -mindepth 1 -type d)

for c in ${targets[@]}; do
  pushd $c
  cp $BUILD_PATH build.sh
  ./build.sh
  rm build.sh
  popd
done
