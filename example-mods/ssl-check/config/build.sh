#!/bin/bash

set -e

# We have individual build file because we want the output to be in this directory
rm -rf node_modules
npm install
mkdir dist
zip dist/index.zip index.js package.json node_modules
