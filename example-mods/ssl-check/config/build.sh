#!/bin/bash

set -e

# We have individual build file because we want the output to be in this directory
rm -rf node_modules
npm install
node $1 --config $2 --log-time --progress
cd dist
zip index.zip index.js
rm index.js
