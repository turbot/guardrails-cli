
@echo off

SET SCRIPT_PATH=%cd%
SET BUILD_PATH="%SCRIPT_PATH%\config\build.bat"

@echo off
cd functions
for /f "delims=" %%D in ('dir /a:d /b') do (
  cd %%D
  xcopy %BUILD_PATH% /Y
  call build.bat
  del build.bat
  cd ..
)
cd ..
