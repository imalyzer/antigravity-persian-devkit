---
name: skill-15-workspace-crystallization-and-refactoring
description: Post-project structural refactoring, folder taxonomy organization, cross-file path re-wiring (.ps1, .bat, .md, .db), root shim generation, and CRLF/Zero-BOM verification. Trigger when the user asks to clean up, organize, categorize, or finalize a messy or completed project directory without breaking links or scripts.
---

# SKILL 15: Workspace Crystallization, Taxonomy Organization & Resilient Addressing

> **File Path:** `02_Skills/SKILL_15_Workspace_Crystallization_and_Refactoring.md`  
> **Trigger:** Whenever finalizing, organizing, categorizing, or refactoring an ad-hoc, cluttered, or completed project workspace (e.g., "پروژه را مرتب کن", "پروژه را نهایی کن", "داده‌های پروژه را سر و سامان بده"), reorganizing folder taxonomies, rewiring cross-file script/document paths without breaking existing links, injecting transparent forwarder shims, or verifying CRLF/Zero-BOM script hygiene and path integrity via fast automated audit.  
> **Source:** `VPN VMware` Workspace Re-engineering & `A-W-G-A-R` (Agentic Workspace Governance & Refactoring Kit).

---

## 1. The Two-Phase Agentic Lifecycle (Explore-First, Crystallize-Later)

### The Anti-Pattern: Premature Hierarchical Nesting
During active feature development, forcing deep, rigid folder hierarchies (`src/modules/subdomain/adapters/controllers/...`) creates massive cognitive and tool-call friction:
* Relative imports and script paths change constantly as ideas evolve.
* AI agents waste 80% of their tool calls and context windows navigating deep directories or re-calculating fragile relative paths (`../../..`).
* Ad-hoc scripts end up with arbitrary `$PSScriptRoot` or `%~dp0` cross-references scattered randomly through lines 50 to 500 of executable code.

### The Standard Architecture: EFCL Lifecycle
1. **Phase 1: Active Prototyping (Explore-First):**
   * Keep directories flat or shallow (e.g., all runnable scripts in `scripts/`, documentation in `docs/` or root).
   * Focus 100% of effort on functional verification, rapid iteration, and non-destructive testing.
   * Enforce only one structural invariant: scripts declare external paths in a `# @PATH-REGISTRY` header block rather than hardcoding them inside business logic.
2. **Phase 2: Structural Crystallization (Crystallize-Later):**
   * Triggered once features work and are verified.
   * Execute an automated, 5-stage transformation that moves files into an enterprise-grade taxonomy, creates transparent backward-compatibility shims, re-wires all links, and verifies integrity in under 2 minutes.

---

## 2. Golden Rule: Batch Discovery Over Sequential Reading

> [!CRITICAL]
> **NEVER inspect 20–50 scripts and Markdown files one-by-one using separate `read_file` tool calls to discover file paths.**

Sequential inspection wastes hundreds of seconds and burns the model context window. Instead:
1. Run a **single batch discovery script or command** in Phase 1 that scans all files (`.ps1`, `.bat`, `.cmd`, `.py`, `.json`, `.md`) using regex.
2. Build an in-memory Dependency & Reference Graph in **one single turn**.
3. Identify all internal cross-file dependencies (`.ps1`, `.bat`, `.md`, `.txt`, `.log`, `.db`, Windows Scheduled Tasks, and markdown links `[...](...)`).

---

## 3. Resilient, Location-Independent Addressing Standards

To ensure scripts never break when moved into deeper subfolders (e.g., `scripts/` -> `scripts/core/` or `scripts/testing/`):

### Pattern A: Dynamic Root Anchor Walk-Up (`.project-root`)
Standard `$PSScriptRoot` (PowerShell) and `%~dp0` (Batch) only describe where the script itself lives. Moving a script breaks every relative child path.

**The Fix:** Place an empty marker file named `.project-root` at the workspace root. Scripts walk upward dynamically until `.project-root` is found:

```powershell
# --- DYNAMIC PROJECT ROOT ANCHOR (PowerShell) ---
$curr = $PSScriptRoot
while ($curr -and -not (Test-Path (Join-Path $curr ".project-root"))) {
    $curr = Split-Path $curr -Parent
}
$ProjectRoot = if ($curr) { $curr } else { $PSScriptRoot }
```

```bat
:: --- DYNAMIC PROJECT ROOT ANCHOR (Windows Batch) ---
@echo off
set "CURR_DIR=%~dp0"
:FindRootLoop
if exist "%CURR_DIR%.project-root" (
    set "PROJECT_ROOT=%CURR_DIR:~0,-1%"
    goto :RootFound
)
for %%I in ("%CURR_DIR%..") do set "PARENT_DIR=%%~fI"
if "%PARENT_DIR%"=="%CURR_DIR%" (
    set "PROJECT_ROOT=%~dp0"
    goto :RootFound
)
set "CURR_DIR=%PARENT_DIR%"
goto :FindRootLoop
:RootFound
```

### Pattern B: Header Path-Registry Block (`# @PATH-REGISTRY`)
Every external file or directory dependency MUST be declared between `# @PATH-REGISTRY-START` and `# @PATH-REGISTRY-END` within the first 25 lines of the script:

```powershell
# @PATH-REGISTRY-START
$curr = $PSScriptRoot
while ($curr -and -not (Test-Path (Join-Path $curr ".project-root"))) { $curr = Split-Path $curr -Parent }
$ProjectRoot = if ($curr) { $curr } else { $PSScriptRoot }

$CoreDir    = Join-Path $ProjectRoot "scripts\core"
$GuestDir   = Join-Path $ProjectRoot "scripts\guest"
$TestingDir = Join-Path $ProjectRoot "scripts\testing"
$LogsDir    = Join-Path $ProjectRoot "docs\logs"
# @PATH-REGISTRY-END
```

* **Why it matters:** Future AI refactorings and moves only touch the header block. Core execution logic below line 25 remains completely untouched and safe from regressions.

### Pattern C: Central Path Manifest (`paths.manifest.json`)
For large systems with dozens of cooperating scripts, define logical IDs in `paths.manifest.json` at the project root:
```json
{
  "dirs": {
    "logs": "docs/logs",
    "core": "scripts/core",
    "guest": "scripts/guest"
  },
  "files": {
    "route_on": "scripts/core/vm-route-on.bat",
    "ics_reset": "scripts/guest/vm-side-ics-reset.ps1"
  }
}
```
Scripts resolve logical keys dynamically: `Join-Path $ProjectRoot ($Manifest.files.route_on -replace '/', '\')`. Reorganizing folders only requires editing `paths.manifest.json` in one place.

### Pattern D: Markdown Reference Link Footers
Avoid scattering relative paths like `[Guide](../../docs/guides/02-setup.md)` across paragraphs. Use Markdown Reference Links and group all paths at the end of the file:
```markdown
Read the [Setup Guide][doc-setup] before running [Preflight Check][script-preflight].

<!-- @LINK-REGISTRY-START -->
[doc-setup]: ../guides/02-setup-step-by-step.md
[script-preflight]: ../../scripts/testing/preflight-debug.ps1
<!-- @LINK-REGISTRY-END -->
```

### Pattern E: Databases & Config Files
* **Never store absolute drive paths (`D:\...`) in SQLite tables or JSON configs.**
* Store root-relative POSIX paths (`docs/logs/output.txt`) or replace tokens at load time (`"db_path": "${PROJECT_ROOT}/data/state.db"`).

---

## 4. Frictionless Entry-Point Forwarders (The Shim Pattern)

Operators, shortcuts, batch wrappers, and Windows Task Scheduler tasks often point to original script locations (e.g., `scripts\vm-route-on.bat`).
When moving the real implementation to `scripts\core\vm-route-on.bat`, **always** place a transparent 1-line shim at the original location:

```bat
@echo off
call "%~dp0core\vm-route-on.bat" %*
exit /b %ERRORLEVEL%
```

* `%~dp0` ensures resolution works even if called from `C:\Windows\System32` by an elevated service or Task Scheduler.
* `%*` forwards all command-line arguments verbatim.
* `exit /b %ERRORLEVEL%` propagates the exact exit code to the caller.

---

## 5. The 5-Stage Crystallization Workflow

```text
[Ad-Hoc / Messy Project Root]
       │
       ▼
[Stage 1: Batch Reference & Dependency Discovery]
       │  (Single-pass regex scan: scripts, docs, configs, OS tasks)
       ▼
[Stage 2: Taxonomy Blueprint & In-Memory Move Map]
       │  (docs/guides, docs/testing, docs/logs, scripts/core, scripts/testing...)
       ▼
[Stage 3: Anchor Injection, File Moves & Forwarder Shims]
       │  (Create .project-root, move files, generate transparent .bat shims)
       ▼
[Stage 4: Automated Path Re-Wiring]
       │  (Update # @PATH-REGISTRY blocks, Markdown link footers, OS tasks)
       ▼
[Stage 5: Binary Hygiene & Fast Automated Audit]
       │  (Enforce CRLF & Zero-BOM, execute Invoke-WorkspaceAudit.ps1 in < 2s)
       ▼
[Crystallized, Enterprise-Grade Repository]
```

### Taxonomy Blueprint Reference
```text
ProjectRoot/
├── .project-root                                 # Root anchor marker file
├── README.md                                     # Clean project overview & entry points
├── docs/
│   ├── README.md                                 # Documentation index & navigation table
│   ├── guides/                                   # Architectural specifications, setup guides
│   ├── testing/                                  # Test reports, fault injection results
│   ├── logs/                                     # Output logs, status dumps (.txt, .log)
│   └── archive/                                  # Deprecated drafts & historical backups
└── scripts/
    ├── AGENT_GUIDE.md                            # Machine-readable technical architecture
    ├── <entry-forwarders>.bat                    # Transparent 1-line shims for desktop/shortcuts
    ├── core/                                     # Primary production execution engines
    ├── testing/                                  # Diagnostic, fault-test & verification scripts
    ├── guest/ (or workers/)                      # VM, remote, or worker-side payloads
    ├── setup/                                    # Installation, task registration, audit tools
    └── archive/                                  # Superseded script backups
```

---

## 6. Windows Script Hygiene & Parser Gotchas

### A. CRLF & UTF-8 Zero-BOM Standard
* Every `.bat`, `.cmd`, and `.ps1` file on Windows **MUST** have pure CRLF (`0D 0A`) line endings. Lone `LF` (`0A`) causes `cmd.exe` to fail inside `()` blocks or jump over labels.
* Every `.bat` and `.ps1` file **MUST** be UTF-8 without BOM. A BOM (`EF BB BF`) corrupts `@echo off` on line 1 in `cmd.exe`.

### B. PowerShell Colon in String Interpolation Gotcha
In PowerShell strings, `$var:something` causes PowerShell to interpret `:something` as a drive-qualified variable name (e.g., `$env:TEMP` or `$script:var`), throwing:
`ParserError: InvalidVariableReferenceWithDrive`.

**Never write:**
```powershell
$bad = "$relSource:$lineNum"   # FAILS if $relSource looks like variable:path
```
**Always write:**
```powershell
$safe = ("{0}:{1}" -f $relSource, $lineNum)
# OR
$safe = "$($relSource):$lineNum"
```

---

## 7. Fast Workspace Audit Tool Specification (`Invoke-WorkspaceAudit.ps1`)

To guarantee immediate verification, every crystallized project should include a fast audit utility in `scripts\setup\Invoke-WorkspaceAudit.ps1`:

* **Execution Time:** Must run in `< 2.0 seconds` across the entire workspace.
* **Scan Scope:**
  1. **Binary Hygiene:** Verifies 100% of `.ps1` and `.bat` files are pure CRLF (zero lone LF) and Zero-BOM (no `EF BB BF`).
  2. **Cross-File References:** Scans scripts and documentation for relative path references (`.ps1`, `.bat`, `.md`, `.txt`, `.db`), resolves each against `$ProjectRoot`, and checks `Test-Path`.
  3. **Output:** Clean, colored summary of scanned scripts, verified links, and any broken references.
