#!/bin/bash

set -e

# We have individual build file because we want the output to be in this directory
rm -rf node_modules
rm -rf dist
npm install
mkdir dist
zip -r dist/index.zip index.js package.json node_modules
