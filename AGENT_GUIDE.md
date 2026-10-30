# AGENT GUIDE: Antigravity Persian DevKit

> **Target:** Future AI Agents (Antigravity, Cursor, Claude Code, GitHub Copilot)  
> **Repository:** `imalyzer/antigravity-persian-devkit`  
> **Version:** `1.2.1`  
> **Language:** English (Strict Token-Efficiency Standard)

---

## 1. Project Purpose
This repository provides a production-grade, modular, zero-token-overhead plugin for Google Antigravity tailored for Persian-speaking developers and Windows environments. It bundles:
1. **Master Response Policy & Signboard (`plugin/rules/AGENTS.md`)**: Enforces zero-preamble, causal explanations, epistemic transparency, dual-mapping routing, and the mandatory `AGENT_GUIDE.md` rule.
2. **15 Specialized On-Demand Skills (`plugin/skills/<skill-name>/SKILL.md`)**: Progressive disclosure skills loaded only when triggered by relevant user requests.
3. **Resilient Workspace & Binary Hygiene Tooling (SKILL-15)**: Dynamic root anchor resolution, header path registries, and a sub-2-second automated workspace audit.

---

## 2. Directory Architecture
```text
antigravity-persian-devkit/
├── .gitattributes                           # Enforces CRLF for scripts in GitHub ZIP downloads
├── .project-root                            # Dynamic root anchor marker (Pattern A)
├── audit.bat                                # 1-Click fast workspace audit shim
├── tools/
│   └── Invoke-WorkspaceAudit.ps1            # Automated binary hygiene & standards audit (< 2.0s)
├── plugin/                                  # Pure deployable Antigravity plugin
│   ├── plugin.json                          # Plugin manifest (v1.2.1)
│   ├── rules/
│   │   └── AGENTS.md                        # Master Signboard & Router (<24KB cap)
│   └── skills/                              # 15 on-demand skills with YAML frontmatter
│       ├── skill-01-technical-project-and-architecture/SKILL.md
│       ├── skill-02-multi-agent-orchestration-coala/SKILL.md
│       ├── skill-03-windows-batch-and-crlf-encoding/SKILL.md
│       ├── skill-04-windows-terminal-persian-rtl/SKILL.md
│       ├── skill-05-vba-persian-macro-guidelines/SKILL.md
│       ├── skill-06-sudden-app-error-troubleshooting/SKILL.md
│       ├── skill-07-obsidian-and-cm6-development/SKILL.md
│       ├── skill-08-local-llm-proxy-and-translation/SKILL.md
│       ├── skill-09-chromium-electron-data-extraction/SKILL.md
│       ├── skill-10-ddc-ci-display-automation-and-power-safety/SKILL.md
│       ├── skill-11-windows-desktop-glassmorphism-and-shell/SKILL.md
│       ├── skill-12-desktop-app-ui-ux-and-state-discipline/SKILL.md
│       ├── skill-13-electron-context-isolation-and-lexical-bidi/SKILL.md
│       ├── skill-14-vm-gateway-vpn-and-leak-prevention/SKILL.md
│       └── skill-15-workspace-crystallization-and-refactoring/SKILL.md
├── install.bat                              # 1-Click Windows installer (CRLF, UTF-8 no BOM)
├── install.ps1                              # PowerShell installer
├── uninstall.bat                            # Uninstaller
├── README.md                                # Bilingual documentation (FA / EN)
└── AGENT_GUIDE.md                           # This technical specification
```

---

## 3. Core Architecture Standards (SKILL-15 Integration)

### Pattern A: Dynamic Root Anchor Walk-Up (`.project-root`)
All entry scripts (`install.bat`, `install.ps1`, `audit.bat`, `Invoke-WorkspaceAudit.ps1`) dynamically discover their workspace root by walking upward until `.project-root` is encountered. Moving or calling scripts from arbitrary working directories will never break relative resolution.

### Pattern B: Header Path-Registry Block (`# @PATH-REGISTRY`)
Every external file or directory dependency is explicitly declared within the first 35 lines between `# @PATH-REGISTRY-START` and `# @PATH-REGISTRY-END`. Future AI agents modifying paths must update the header block without altering core execution logic.

### Dual-Mapping Routing Architecture
- **Source Staging:** Master skills live in `02_Skills/SKILL_XX_*.md` and policies in `01_Signboard_and_Policies/`.
- **Plugin Runtime:** `sync_to_antigravity.py` transforms source references into canonical Antigravity skill IDs (`skills/<skill-id>/SKILL.md`), inlines policies directly into `AGENTS.md`, and replaces local machine paths with `<Antigravity-DevKit-Root>`.

### Fast Workspace Audit Tool (`audit.bat` & `tools/Invoke-WorkspaceAudit.ps1`)
Runs in `< 2.0 seconds` (typically ~300ms) to verify:
1. Presence of `.project-root` and `.gitattributes`.
2. Binary hygiene: 100% CRLF line endings (`\r\n`), Zero-BOM, and zero null bytes across `.bat`, `.cmd`, `.ps1`, `.json`, and `.md` files.
3. Signboard file size cap (< 24,000 bytes for `AGENTS.md`).
4. Absence of naked unescaped parentheses in batch blocks.

---

## 4. Maintenance Guardrails for AI Agents

1. **Rule File Cap (24,000 bytes):**
   `plugin/rules/AGENTS.md` MUST strictly remain under 24KB (currently ~20.7KB with >3KB headroom). Never bloat this file with large inline scripts.
2. **Windows Batch & Script Hygiene:**
   - Mandatory `CRLF` (`\r\n`) on all `.bat`, `.cmd`, and `.ps1` files.
   - Mandatory UTF-8 without BOM.
   - Batch parenthesis lexer rule: Zero unescaped parentheses `()` inside `if (...) (` and `for` blocks.
3. **GitHub Identity & Privacy (Rule 4.4):**
   - Credit user strictly as `imalyzer`.
   - Use masked commit email: `imalyzer@users.noreply.github.com`.
   - Never commit local machine paths (`D:\Projects\...`, `C:\Users\...`).
