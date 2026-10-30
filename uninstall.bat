@echo off
chcp 65001 >nul
setlocal

:: @PATH-REGISTRY-START
set "TARGET_DIR=%USERPROFILE%\.gemini\config\plugins\antigravity-persian-devkit"
set "CONFIG_JSON=%USERPROFILE%\.gemini\config\config.json"
:: @PATH-REGISTRY-END

title Antigravity Persian DevKit Uninstaller

echo ============================================================
echo   Antigravity Persian DevKit - Uninstaller
echo ============================================================
echo.

if exist "%TARGET_DIR%" (
    echo Removing plugin directory: %TARGET_DIR% ...
    rmdir /S /Q "%TARGET_DIR%"
    echo [SUCCESS] Plugin files removed.
) else (
    echo Plugin directory not found.
)

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$cfg = '%CONFIG_JSON%';" ^
    "if (Test-Path $cfg) {" ^
    "    $j = Get-Content -Path $cfg -Raw -Encoding UTF8 | ConvertFrom-Json;" ^
    "    if ($j.plugins.'antigravity-persian-devkit') {" ^
    "        $j.plugins.PSObject.Properties.Remove('antigravity-persian-devkit');" ^
    "        $j | ConvertTo-Json -Depth 10 | Set-Content -Path $cfg -Encoding UTF8;" ^
    "        Write-Host '  Plugin unregistered from config.json';" ^
    "    }" ^
    "}"

echo.
echo ============================================================
echo   [SUCCESS] Uninstallation completed.
echo ============================================================
echo.
pause
exit /b 0
