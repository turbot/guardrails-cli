@echo off
REM this batch file assume 7-zip is installed at th efollowing location
SET zip="C:\Program Files\7-Zip\7z.exe"


rmdir node_modules /s /q
npm install
echo INSTALLED
mkdir dist
zip dist/index.zip ./*
%zip% a -tzip dist\index.zip index.js package.json node_modules

