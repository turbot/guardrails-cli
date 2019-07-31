
@echo off

SET SCRIPT_PATH=%cd%
SET BUILD_PATH="%SCRIPT_PATH%\config\build.bat"

@echo off
pushd functions
for /f "delims=" %%D in ('dir /a:d /b') do (
  cd %%D
  xcopy %BUILD_PATH% /Y
  build.bat
  del build.bat
  cd ..
)
popd
cd

