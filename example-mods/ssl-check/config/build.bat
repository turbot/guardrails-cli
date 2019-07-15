@echo off
SET zip="C:\Program Files\7-Zip\7z.exe"


REM We have individual build file because we want the output to be in this directory
rmdir node_modules /s /q
npm install
echo INSTALLED
node %1 --config %2 --log-time --progress
echo RUNNING NODE
cd dist
%zip% a -tzip index.zip index.js
del index.js
