@echo off
REM this batch file assume 7-zip is installed at the following location
SET zip="C:\Program Files\7-Zip\7z.exe"

call npm install
mkdir dist
%zip% a -tzip dist\index.zip index.js package.json node_modules

