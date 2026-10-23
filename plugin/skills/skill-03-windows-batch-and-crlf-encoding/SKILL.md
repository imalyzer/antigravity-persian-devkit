---
name: skill-03-windows-batch-and-crlf-encoding
description: Mandatory encoding, CRLF line-ending, UTF-8 codepage, and block-variable rules for all Windows Batch (.bat, .cmd) and PowerShell (.ps1) scripts.
---

# SKILL 03: Windows Batch & Script Encoding Guidelines (`.bat`, `.cmd`, `.ps1`)

> **File Path:** `skills/SKILL_03_Windows_Batch_and_CRLF_Encoding.md`  
> **Trigger:** Whenever creating, editing, or debugging any `.bat`, `.cmd`, or `.ps1` file intended to run on Windows.  
> **Source:** `windows-batch-crlf-guidelines.md` and `سیستم پرامپت هدایت فنی پروژه.md` (§4).

---

## 1. Why This Skill Exists (Critical Failure Mode)

AI code-generation tools write Unix line endings (`LF` / `
`) by default. On Windows, `cmd.exe` misinterprets `LF`-only batch files—especially when combined with UTF-8 multi-byte Persian characters or byte-order marks (BOM)—causing byte-offset parser shifts and cryptic `"is not recognized as an internal or external command"` failures (as experienced in the *Roftgar* project).

---

## 2. The 4 Non-Negotiable Rules for Every `.bat` / `.cmd` / `.ps1` File

### Rule 1: Line Endings MUST Be `CRLF` (`
`), Never `LF` (`
`)
- Every Windows script file must be written and saved with explicit Windows `CRLF` (`
`) line endings.
- If your file-writing tool outputs `
` by default, run a post-processing pass in Python (`content.replace(b'\r\n', b'\n').replace(b'\n', b'\r\n')`) to guarantee pure `CRLF`.

### Rule 2: Encoding MUST Be `UTF-8 without BOM`
- Save the file strictly as `UTF-8` **without BOM** (`utf-8` in Python, never `utf-8-sig`).
- A 3-byte UTF-8 BOM (`EF BB BF`) at the start of a `.bat` file corrupts the first command on line 1 and causes it to fail on execution.

### Rule 3: Mandatory Header Lines for Scripts with Persian Text/Comments or Python Calls
The first two lines of any `.bat` / `.cmd` file containing Persian messages or comments **must always be**:

```bat
@echo off
chcp 65001 >nul
```

If the script invokes Python, immediately include:

```bat
set "PYTHONUTF8=1"
```

### Rule 4: Safe Parentheses & Delayed Expansion Inside `if (...)` and `for (...)` Blocks
1. **Escape Literal Parentheses in `echo`:** Any literal parentheses inside an `if (...)` or `for (...)` block must be escaped with carets (`^(` and `^)`), otherwise `cmd.exe` prematurely closes the block.
2. **Use Delayed Variable Expansion:** Any variable modified and read inside the same parenthesized block must use `setlocal enabledelayedexpansion` and `!var!` syntax instead of `%var%`.

```bat
@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
set "PYTHONUTF8=1"

if exist "config.json" (
    set "status=Found ^(OK^)"
    echo Status: !status!
)
```

---

## 3. Mandatory Pre-Delivery Disk Verification Checklist

**NEVER assume your file-writing tool respected `CRLF` and `no-BOM`.** Before handing any `.bat`, `.cmd`, or `.ps1` file to the user, read the raw bytes back from disk and verify:

- [ ] **Pure `CRLF` Check:** Every newline on disk is `
` (`0D 0A`), with zero standalone `
` bytes.
- [ ] **Zero BOM Check:** File does **not** start with `ï»¿`.
- [ ] **UTF-8 Codepage Active:** `chcp 65001 >nul` is present on line 2 whenever Persian text or comments exist.
- [ ] **Escaped Block Parentheses:** All `(` and `)` inside `echo` statements within blocks are escaped as `^(` and `^)`.
- [ ] **Delayed Expansion:** In-block variables use `!var!` with `setlocal enabledelayedexpansion`.
