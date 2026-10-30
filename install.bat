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

set "PLUGIN_SRC=%PROJECT_ROOT%\plugin"
set "TARGET_DIR=%USERPROFILE%\.gemini\config\plugins\antigravity-persian-devkit"
set "CONFIG_JSON=%USERPROFILE%\.gemini\config\config.json"
:: @PATH-REGISTRY-END

title Antigravity Persian DevKit Installer

echo ============================================================
echo   Antigravity Persian DevKit - 1-Click Installer
echo   Repository: github.com/imalyzer/antigravity-persian-devkit
echo ============================================================
echo.

if not exist "%PLUGIN_SRC%\plugin.json" (
    echo [ERROR] plugin folder not found at: %PLUGIN_SRC%
    echo Please make sure you are running install.bat from the repository root.
    pause
    exit /b 1
)

echo [1/3] Creating plugin directory...
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"

echo [2/3] Copying plugin files to: %TARGET_DIR% ...
xcopy "%PLUGIN_SRC%" "%TARGET_DIR%" /E /I /Y /Q >nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to copy plugin files!
    pause
    exit /b 1
)

echo [3/3] Registering plugin in Antigravity config...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$cfg = '%CONFIG_JSON%';" ^
    "if (Test-Path $cfg) {" ^
    "    $j = Get-Content -Path $cfg -Raw -Encoding UTF8 | ConvertFrom-Json;" ^
    "    if (-not $j.plugins) { $j | Add-Member -MemberType NoteProperty -Name 'plugins' -Value (New-Object PSObject) };" ^
    "    if (-not $j.plugins.'antigravity-persian-devkit') {" ^
    "        $j.plugins | Add-Member -MemberType NoteProperty -Name 'antigravity-persian-devkit' -Value (New-Object PSObject);" ^
    "        $j | ConvertTo-Json -Depth 10 | Set-Content -Path $cfg -Encoding UTF8;" ^
    "        Write-Host '  Plugin successfully registered in config.json';" ^
    "    } else {" ^
    "        Write-Host '  Plugin was already registered in config.json';" ^
    "    }" ^
    "} else {" ^
    "    Write-Host '  Warning: config.json not found, plugin directory copied.';" ^
    "}"

echo.
echo ============================================================
echo   [SUCCESS] Antigravity Persian DevKit installed successfully!
echo   All 15 skills and rules are now available in your Antigravity IDE.
echo ============================================================
echo.
pause
exit /b 0
