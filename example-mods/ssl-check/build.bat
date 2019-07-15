
@echo off

SET SCRIPT_PATH=%cd%
SET BUILD_PATH="%SCRIPT_PATH%\config\build.bat"
SET CONFIG_PATH="%SCRIPT_PATH%\config\webpack.config.js"
SET WEBPACK_PATH="%SCRIPT_PATH%/node_modules/webpack/bin/webpack.js"

@echo off
pushd functions
for /f "delims=" %%D in ('dir /a:d /b') do (
  cd %%D
  xcopy %BUILD_PATH% /Y
  build.bat  %WEBPACK_PATH% %CONFIG_PATH%
  del build.bat
  cd ..
)
popd
cd

