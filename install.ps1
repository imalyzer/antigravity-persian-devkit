# Antigravity Persian DevKit PowerShell Installer
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Antigravity Persian DevKit - Installer" -ForegroundColor Cyan
Write-Host "  Repository: github.com/imalyzer/antigravity-persian-devkit" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PluginSrc = Join-Path $ScriptDir "plugin"
$TargetDir = Join-Path $HOME ".gemini\config\pluginsntigravity-persian-devkit"
$ConfigJson = Join-Path $HOME ".gemini\config\config.json"

if (-not (Test-Path (Join-Path $PluginSrc "plugin.json"))) {
    Write-Host "[ERROR] plugin folder not found!" -ForegroundColor Red
    exit 1
}

Write-Host "[1/3] Preparing target directory..." -ForegroundColor Yellow
if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}

Write-Host "[2/3] Copying plugin files..." -ForegroundColor Yellow
Copy-Item -Path "$PluginSrc\*" -Destination $TargetDir -Recurse -Force

Write-Host "[3/3] Registering plugin in Antigravity config..." -ForegroundColor Yellow
if (Test-Path $ConfigJson) {
    $cfg = Get-Content -Path $ConfigJson -Raw -Encoding UTF8 | ConvertFrom-Json
    if (-not $cfg.plugins) {
        $cfg | Add-Member -MemberType NoteProperty -Name "plugins" -Value (New-Object PSObject)
    }
    if (-not $cfg.plugins."antigravity-persian-devkit") {
        $cfg.plugins | Add-Member -MemberType NoteProperty -Name "antigravity-persian-devkit" -Value (New-Object PSObject)
        $cfg | ConvertTo-Json -Depth 10 | Set-Content -Path $ConfigJson -Encoding UTF8
        Write-Host "  Registered in config.json" -ForegroundColor Green
    } else {
        Write-Host "  Already registered in config.json" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "  [SUCCESS] Antigravity Persian DevKit installed successfully!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
