---
name: skill-03-windows-batch-and-crlf-encoding
description: Mandatory encoding, CRLF line-ending, UTF-8 codepage, block-variable, parenthesis lexer, and .gitattributes rules for all Windows Batch (.bat, .cmd) and PowerShell (.ps1) scripts.
---

# SKILL 03: Windows Batch & Script Encoding Guidelines (.bat, .cmd, .ps1)

> **File Path:** D:\Projects\Iman Sheybani\software\Antigravity\02_Skills\SKILL_03_Windows_Batch_and_CRLF_Encoding.md  
> **Trigger:** Whenever creating, editing, or debugging any `.bat`, `.cmd`, or `.ps1` file intended to run on Windows, or preparing Windows scripts for distribution via Git/GitHub.  
> **Source:** `windows-batch-crlf-guidelines.md` and Project Technical Architecture Guidelines.

---

## 1. Why This Skill Exists (Critical Failure Modes)

AI code-generation tools write Unix line endings (LF / `\n`) by default and frequently overlook Windows `cmd.exe` parser quirks. On Windows:
1. **The LF Parser Shift:** `cmd.exe` misinterprets LF-only batch files—especially when combined with loops, labels (`:FindRootLoop`), or block structures—causing byte-offset parser shifts and cryptic "is not recognized as an internal or external command" or instant window crashes.
2. **The Parenthesis Lexer Crash:** `cmd.exe` parses parenthesized blocks `if (...) (` and `for (...) (` at the lexical level *before* executing conditions. An unescaped `)` in an echo message (e.g. `(https://nodejs.org)`) closes the block prematurely, crashing the script instantly with `<keyword> was unexpected at this time`.
3. **The GitHub ZIP Download LF Trap:** GitHub's web interface generates repository ZIP archives using Linux servers that convert all line endings to LF unless a root `.gitattributes` explicitly forces `eol=crlf`.

---

## 2. The 6 Non-Negotiable Rules for Every Windows Script

### Rule 1: Line Endings MUST Be Pure CRLF (`\r\n`), Never Lone LF (`\n`)
- Every Windows script file must be saved with explicit Windows CRLF (`\r\n`) line endings.
- Run a post-processing verification pass in PowerShell or Python to guarantee pure CRLF on disk before delivery.
- **Mandatory `.gitattributes` for Git Repositories:** When publishing to GitHub, **ALWAYS** include a root `.gitattributes` with:
  ```gitattributes
  * text=auto
  *.bat text eol=crlf
  *.cmd text eol=crlf
  *.ps1 text eol=crlf
  ```
  Without this, GitHub's "Download ZIP" feature normalizes line endings to Linux LF, causing `cmd.exe` to fail on loops and labels (`:FindRootLoop`).

### Rule 2: Encoding MUST Be UTF-8 without BOM
- Save files strictly as UTF-8 **without BOM** (never UTF-8 with BOM).
- A 3-byte UTF-8 BOM (`EF BB BF`) at the start of a `.bat` file corrupts the first command on line 1, causing cmd to fail immediately.

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

### Rule 4: The Parenthesis Lexer Rule (Preventing `<keyword> was unexpected at this time`)
`cmd.exe` parses parenthesis blocks `if (...) (` and `for (...) do (` lexically before runtime evaluation:
1. **Never write literal parentheses inside `if (...)` or `for (...)` blocks without carets:**
   - ❌ **CRITICAL BUG:** `echo Please install Node.js (https://nodejs.org) or run 1_Apply_Patch.bat`  
     *(The `)` after `nodejs.org` closes the if block prematurely; cmd treats `or run...` as an invalid command and crashes).*
   - ❌ **CRITICAL BUG:** `set /p "CHOICE=Do you want to proceed? (y/n): "` inside a block.
2. **The Safe Solutions:**
   - **Preferred: Use Square Brackets or Bare URLs:**  
     `echo Please install Node.js from https://nodejs.org`  
     `set /p "CHOICE=Do you want to proceed? [y/n]: "`
   - **If Parentheses Are Unavoidable, Strictly Escape With Carets:**  
     `echo Please install Node.js ^(https://nodejs.org^) or run 1_Apply_Patch.bat`
3. **Use Delayed Variable Expansion:** Any variable modified and read inside the same parenthesized block must use `setlocal enabledelayedexpansion` and `!var!` syntax instead of `%var%`.

```bat
@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

if exist "config.json" (
    set "status=Found [OK]"
    echo Status: !status!
)
```

### Rule 5: Non-Interactive CLI Package Execution (`npx --yes`)
In batch scripts, Node.js child processes, or background automation:
- Running `npx <package>` when the package is not pre-cached triggers an interactive prompt: `Need to install the following packages: <pkg>. Ok to proceed? (y)`.
- In non-interactive contexts, this causes the script to hang indefinitely.
- **ALWAYS use `npx --yes <package>` (or `npx -y <package>`).**

### Rule 6: Process Termination Safety (`taskkill` Discipline)
- **Never execute `taskkill /F /IM ...` blindly without operator confirmation**, especially in installer or patcher scripts.
- The user may be actively running the host application or an AI assistant session inside that process.
- **Always prompt with square brackets:**  
  `set /p "CLOSE_APP=Would you like to close AppName now? [y/n]: "`  
  and provide an offline/manual restart fallback if the user declines.

---

## 3. Mandatory Pre-Delivery Disk Verification Checklist

**NEVER assume your file-writing tool respected CRLF and no-BOM.** Before handing any `.bat`, `.cmd`, or `.ps1` file to the user, verify against this checklist:

- [ ] **Pure CRLF Check:** Every newline on disk is `\r\n` (`0D 0A`), with zero standalone `\n` (`0A`) bytes.
- [ ] **Zero BOM Check:** File does **not** start with `EF BB BF`.
- [ ] **UTF-8 Codepage Active:** `chcp 65001 >nul` is present on line 2 whenever Persian text or comments exist.
- [ ] **No Unescaped Block Parentheses:** Zero literal `(` or `)` inside `if (...)` or `for (...)` blocks; prompts use `[y/n]` instead of `(y/n)`.
- [ ] **Delayed Expansion Active:** In-block variables use `!var!` with `setlocal EnableDelayedExpansion`.
- [ ] **NPX Non-Interactive Flag:** All `npx` commands include `--yes`.
- [ ] **Root .gitattributes Present:** Repository includes `*.bat text eol=crlf` and `*.ps1 text eol=crlf`.
