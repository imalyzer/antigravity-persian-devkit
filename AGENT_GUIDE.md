# AGENT GUIDE: Antigravity Persian DevKit

> **Target:** Future AI Agents (Antigravity, Cursor, Claude Code, GitHub Copilot)  
> **Repository:** `imalyzer/antigravity-persian-devkit`  
> **Language:** English (Strict Token-Efficiency Standard)

---

## 1. Project Purpose
This repository provides a modular, zero-token-overhead plugin for Google Antigravity tailored for Persian-speaking developers and Windows environments. It bundles:
1. **Always-on Response Policy & Signboard (`plugin/rules/AGENTS.md`)**: Enforces zero-preamble, causal explanations, epistemic discipline, and the mandatory `AGENT_GUIDE.md` rule.
2. **13 Specialized On-Demand Skills (`plugin/skills/<skill-name>/SKILL.md`)**: Progressive disclosure skills loaded only when triggered by relevant tasks.

---

## 2. Directory Architecture
```text
antigravity-persian-devkit/
├── plugin/                                  # Pure deployable Antigravity plugin
│   ├── plugin.json                          # Plugin metadata
│   ├── rules/AGENTS.md                      # Always-on rule (<24KB cap)
│   └── skills/                              # 13 on-demand skills with YAML frontmatter
├── install.bat                              # 1-Click Windows installer (CRLF, UTF-8 no BOM)
├── install.ps1                              # PowerShell installer
├── uninstall.bat                            # Uninstaller
├── README.md                                # Bilingual documentation (FA / EN)
└── AGENT_GUIDE.md                           # This technical specification
```

---

## 3. Maintenance Guardrails for AI Agents
1. **Rule File Cap (24,000 bytes):**
   `plugin/rules/AGENTS.md` MUST remain below 24KB. Never inline large scripts into rules; place detailed runbooks in `plugin/skills/<skill-name>/SKILL.md`.
2. **Windows Batch Line Endings (CRLF):**
   Any `.bat` or `.cmd` file in this repository must strictly use `CRLF` (`\r\n`) and UTF-8 without BOM.
3. **No Hardcoded Machine Paths:**
   Never commit absolute local paths (e.g. `C:\Users\...` or `D:\Projects\...`). Always use relative paths or `%USERPROFILE%`.
