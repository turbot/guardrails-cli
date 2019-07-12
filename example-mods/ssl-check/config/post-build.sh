#!/bin/bash

set -e

rm -rf temp
mkdir temp

tar -zxvf $1 --exclude index.js -C temp
rm -f $1
tar -czvf $1 temp/
