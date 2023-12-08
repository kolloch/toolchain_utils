echo off

:: Enable Batch extensions
verify other 2>nul
setlocal EnableExtensions
if errorlevel 1 (
  echo "Failed to enable extensions"
  exit /b 120
)

:: Variables
for /f %%i in ("%0") do set "STEM=%%~ni"

:: Execute!
(
    echo.Usage: %0 %*
    echo.
    echo.This is a stub executable that is provided when the `%STEM%` binary is not found on %%PATH%%:
    echo.
    echo.    %PATH%
    echo.
    echo.It will always exit with a failure code. Either:
    echo.
    echo.- Install the required binary locally
    echo.- Setup a hermetic toolchain for the binary
) >&2

exit /b 126