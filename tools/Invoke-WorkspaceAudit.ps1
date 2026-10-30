# ============================================================
# Antigravity Workspace Fast Audit Tool (Invoke-WorkspaceAudit.ps1)
# Adheres to SKILL-15 Section 7 and SKILL-03 Binary Hygiene
# ============================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

# @PATH-REGISTRY-START
$curr = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
while ($curr -and -not (Test-Path (Join-Path $curr ".project-root"))) {
    $curr = Split-Path $curr -Parent
}
$ProjectRoot = if ($curr) { $curr } else { if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path } }
# @PATH-REGISTRY-END

$Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Antigravity Fast Workspace Audit Tool (SKILL-15)" -ForegroundColor Cyan
Write-Host "  Project Root: $ProjectRoot" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$TotalFilesChecked = 0
$FailedChecks = 0
$Warnings = 0
$Issues = [System.Collections.Generic.List[string]]::new()

# 1. Root Anchor Check
$RootAnchor = Join-Path $ProjectRoot ".project-root"
if (Test-Path $RootAnchor) {
    Write-Host "  [PASS] Root Anchor (.project-root) detected." -ForegroundColor Green
} else {
    Write-Host "  [FAIL] Missing .project-root anchor at workspace root!" -ForegroundColor Red
    $Issues.Add("Missing .project-root anchor at $ProjectRoot")
    $FailedChecks++
}

# 2. Gitattributes Check
$GitAttributes = Join-Path $ProjectRoot ".gitattributes"
if (Test-Path $GitAttributes) {
    Write-Host "  [PASS] .gitattributes detected (protects against GitHub ZIP LF normalization)." -ForegroundColor Green
} else {
    Write-Host "  [WARN] Missing .gitattributes at workspace root." -ForegroundColor Yellow
    $Warnings++
}

# 3. Scan Files for Binary Hygiene & File Cap
$Extensions = @("*.bat", "*.cmd", "*.ps1", "*.md", "*.json", "*.py")
$FilesToScan = Get-ChildItem -Path $ProjectRoot -Recurse -File -Include $Extensions | Where-Object {
    $_.FullName -notmatch '\\\.git\\' -and $_.FullName -notmatch '\\node_modules\\'
}

Write-Host "  Scanning $($FilesToScan.Count) workspace files..." -ForegroundColor Gray

foreach ($file in $FilesToScan) {
    $TotalFilesChecked++
    $relPath = $file.FullName.Substring($ProjectRoot.Length).TrimStart('\', '/')
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    $hasIssue = $false

    # A. Check UTF-8 BOM
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $Issues.Add("BOM Detected: $($relPath)")
        $hasIssue = $true
    }

    # B. Check Null Bytes (0x00)
    for ($i = 0; $i -lt $bytes.Length; $i++) {
        if ($bytes[$i] -eq 0x00) {
            $Issues.Add("Null byte (0x00) detected at offset $($i): $($relPath)")
            $hasIssue = $true
            break
        }
    }

    # C. Check Line Endings (CRLF vs Lone LF) for text scripts & markdown
    if ($file.Extension -in @(".bat", ".cmd", ".ps1", ".md", ".json")) {
        for ($i = 0; $i -lt $bytes.Length; $i++) {
            if ($bytes[$i] -eq 0x0A) {
                if ($i -eq 0 -or $bytes[$i - 1] -ne 0x0D) {
                    $Issues.Add("Lone LF line ending detected: $($relPath)")
                    $hasIssue = $true
                    break
                }
            }
        }
    }

    # D. Signboard Rule Size Cap (< 24,000 bytes)
    if ($file.Name -in @("AGENTS.md", "SIGNBOARD.md")) {
        if ($bytes.Length -gt 24000) {
            $Issues.Add("Size cap exceeded: $($relPath) has $($bytes.Length) bytes (Limit: 24,000)")
            $hasIssue = $true
        }
    }

    if ($hasIssue) {
        $FailedChecks++
    }
}

# 4. Check Parenthesis Lexer in Batch Scripts
$BatFiles = $FilesToScan | Where-Object { $_.Extension -in @(".bat", ".cmd") }
foreach ($bat in $BatFiles) {
    $relPath = $bat.FullName.Substring($ProjectRoot.Length).TrimStart('\', '/')
    $lines = [System.IO.File]::ReadAllLines($bat.FullName)
    $inBlock = 0
    for ($l = 0; $l -lt $lines.Length; $l++) {
        $line = $lines[$l].Trim()
        if ($line -match '\(\s*$') { $inBlock++ }
        if ($line -match '^\s*\)') { if ($inBlock -gt 0) { $inBlock-- } }

        if ($inBlock -gt 0) {
            if ($line -match 'echo.*[^\^]\)' -or $line -match 'echo.*[^\^]\(') {
                $Issues.Add("Potential naked parenthesis in batch block: $($relPath):$($l+1)")
                $Warnings++
            }
        }
    }
}

$Stopwatch.Stop()
$ElapsedMs = $Stopwatch.ElapsedMilliseconds

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  AUDIT SUMMARY" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Execution Time : $($ElapsedMs) ms (Target: < 2000 ms)" -ForegroundColor $(if ($ElapsedMs -lt 2000) { "Green" } else { "Yellow" })
Write-Host "  Files Checked  : $($TotalFilesChecked)" -ForegroundColor Gray
Write-Host "  Failed Checks  : $($FailedChecks)" -ForegroundColor $(if ($FailedChecks -eq 0) { "Green" } else { "Red" })
Write-Host "  Warnings       : $($Warnings)" -ForegroundColor $(if ($Warnings -eq 0) { "Green" } else { "Yellow" })

if ($Issues.Count -gt 0) {
    Write-Host "`n  Audit Findings:" -ForegroundColor Yellow
    foreach ($issue in $Issues) {
        Write-Host "    - $issue" -ForegroundColor $(if ($issue -match 'Warning|naked') { "Yellow" } else { "Red" })
    }
}

Write-Host ""
if ($FailedChecks -eq 0) {
    Write-Host "  [VERDICT: PASSED] Workspace binary hygiene and standards are 100% compliant!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "  [VERDICT: FAILED] Workspace contains $($FailedChecks) compliance failure(s)!" -ForegroundColor Red
    exit 1
}
