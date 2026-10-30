@echo off
chcp 65001 >nul
set "PYTHONUTF8=1"
setlocal

:: @PATH-REGISTRY-START
set "CURR_DIR=%~dp0"
:FindRootLoop
if exist "%CURR_DIR%.project-root" (
    set "PROJECT_ROOT=%CURR_DIR:~0,-1%"
    goto :RootFound
)
for %%I in ("%CURR_DIR%..") do set "PARENT_DIR=%%~fI\"
if "%PARENT_DIR%"=="%CURR_DIR%" (
    set "PROJECT_ROOT=%~dp0"
    if "%PROJECT_ROOT:~-1%"=="\" set "PROJECT_ROOT=%PROJECT_ROOT:~0,-1%"
    goto :RootFound
)
set "CURR_DIR=%PARENT_DIR%"
goto :FindRootLoop
:RootFound

set "AUDIT_PS1=%PROJECT_ROOT%\tools\Invoke-WorkspaceAudit.ps1"
:: @PATH-REGISTRY-END

powershell -NoProfile -ExecutionPolicy Bypass -File "%AUDIT_PS1%" %*
set "EXIT_CODE=%ERRORLEVEL%"

echo.
pause
exit /b %EXIT_CODE%
