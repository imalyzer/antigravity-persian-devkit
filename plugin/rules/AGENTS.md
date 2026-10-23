# ANTIGRAVITY MASTER SIGNBOARD & ROUTING INDEX (`SIGNBOARD.md`)

> **Backup & Staging Root:** `<Antigravity-DevKit-Root>`  
> **Role:** Central Routing Graph, Pre-Processing Gate, Response Policy, Special Governance Rules, and Skill Directory Index for AI Agents.

---

## 1. MANDATORY PRE-PROCESSING DIRECTIVE (READ BEFORE RESPONDING)

**ATTENTION AI AGENT:**  
Before processing, reasoning about, or responding to ANY user request, you **MUST** execute the following 3-step pre-flight check against this Signboard:

1. **Classify the Request Domain:** Scan the **Linear Routing Graph & Address Map (Section 2)** and the **Personal Skills Trigger Matrix (Section 5)** below.
2. **Load Targeted Context First:** If the user's request touches *any* domain, file type, error pattern, or architecture workflow listed in this Signboard, you **MUST** first read and apply the corresponding Policy or Skill file from `01_Signboard_and_Policies` or `02_Skills` before generating code, plans, or answers. Never rely on generic pretrained defaults when a specialized rule exists here.
3. **Apply the Core Response Policy:** Every response must strictly adhere to the communication, epistemic, and verification standards in **Section 3** (and detailed in `01_Signboard_and_Policies/RESPONSE_POLICY.md`).

---

## 2. DIRECTORY TREE, LINEAR ROUTING GRAPH & ADDRESS MAP

### 2.1. Hierarchical Tree Structure (`<Antigravity-DevKit-Root>`)

```text
<Antigravity-DevKit-Root>\
├── 01_Signboard_and_Policies\
│   ├── SIGNBOARD.md                                     # [PRIMARY] Master English Signboard, Router & Policy Index
│   ├── SIGNBOARD_FA.md                                  # [PERSIAN] Complete Persian translation of the Signboard for human review
│   ├── RESPONSE_POLICY.md                               # Detailed communication, epistemic, and technical response standards
│   ├── SPECIAL_RULES_AND_GOVERNANCE.md                  # Automation modularization, AGENT_GUIDE.md rule, & skill promotion rules
│   └── SYNC_AND_BACKUP_PROMPT.md                        # Automated backup extraction & synchronization protocol and trigger prompt
│
└── 02_Skills\
    ├── SKILL_01_Technical_Project_and_Architecture.md   # Specialist Swamp Filter, Mechanism vs. Goal, 5-Domain Engineering Loop
    ├── SKILL_02_Multi_Agent_Orchestration_CoALA.md      # 3-Tier AI Pipeline (Architect / Orchestrator / Executor), 4-Part Contracts
    ├── SKILL_03_Windows_Batch_and_CRLF_Encoding.md      # Mandatory Windows script rules (.bat/.cmd/.ps1), CRLF, UTF-8 no-BOM
    ├── SKILL_04_Windows_Terminal_Persian_RTL.md         # Persian/RTL console display (fixed width=70 textwrap + reshaper + bidi)
    ├── SKILL_05_VBA_Persian_Macro_Guidelines.md         # Zero-mojibake Persian VBA macros (ChrW/U() hex, NameBi, ReadingOrderRtl)
    ├── SKILL_06_Sudden_App_Error_Troubleshooting.md     # 7-step root-cause diagnostic protocol for sudden software errors
    ├── SKILL_07_Obsidian_and_CM6_Development.md         # Obsidian themes/plugins, CodeMirror 6 Decoration API, idempotent block IDs
    ├── SKILL_08_Local_LLM_Proxy_and_Translation.md      # LM Studio tuning, offline QTranslate OCR pipeline, LiteLLM/9Router & STT
    └── SKILL_09_Chromium_Electron_Data_Extraction.md     # Electron/Chromium storage, V8 Structured Clone deserialization & gotchas
```

### 2.2. Linear Routing Graph (Task Intent -> Target File Address)

```text
[Incoming User Request]
   │
   ├─► [General Q&A / Technical Advice / Tool Selection]
   │      └──► APPLY: 01_Signboard_and_Policies\RESPONSE_POLICY.md
   │
   ├─► [Building a Script, Utility, or Automation Tool]
   │      ├──► APPLY RULE 4.1: 01_Signboard_and_Policies\SPECIAL_RULES_AND_GOVERNANCE.md (Modularize + English AGENT_GUIDE.md)
   │      └──► APPLY SKILL:    02_Skills\SKILL_01_Technical_Project_and_Architecture.md
   │
   ├─► [Designing System Architecture or Multi-Model Execution Plan]
   │      ├──► APPLY SKILL:    02_Skills\SKILL_01_Technical_Project_and_Architecture.md
   │      └──► APPLY SKILL:    02_Skills\SKILL_02_Multi_Agent_Orchestration_CoALA.md
   │
   ├─► [Writing Windows Scripts (.bat / .cmd / .ps1)]
   │      └──► APPLY SKILL:    02_Skills\SKILL_03_Windows_Batch_and_CRLF_Encoding.md
   │
   ├─► [Displaying Persian / Arabic RTL Text in Windows Terminal / Console]
   │      └──► APPLY SKILL:    02_Skills\SKILL_04_Windows_Terminal_Persian_RTL.md
   │
   ├─► [Writing or Debugging Office VBA Macros (Word / Excel / Access)]
   │      └──► APPLY SKILL:    02_Skills\SKILL_05_VBA_Persian_Macro_Guidelines.md
   │
   ├─► [Troubleshooting Sudden / Unprecedented Application Errors or Screenshots]
   │      └──► APPLY SKILL:    02_Skills\SKILL_06_Sudden_App_Error_Troubleshooting.md
   │
   ├─► [Developing Obsidian Plugins, Themes, CSS Snippets, or CM6 Scripts]
   │      └──► APPLY SKILL:    02_Skills\SKILL_07_Obsidian_and_CM6_Development.md
   │
   ├─► [Configuring Local LLMs (LM Studio), LiteLLM/9Router Proxy, QTranslate, or Persian STT]
   │      └──► APPLY SKILL:    02_Skills\SKILL_08_Local_LLM_Proxy_and_Translation.md
   │
   ├─► [Extracting Accounts/Storage from Electron/Chromium Apps (IndexedDB, LevelDB)]
   │      └──► APPLY SKILL:    02_Skills\SKILL_09_Chromium_Electron_Data_Extraction.md
   │
   └─► [Command: "Update Signboard, Data, and Backup Files"]
          └──► EXECUTE:        01_Signboard_and_Policies\SYNC_AND_BACKUP_PROMPT.md
```

---

## 3. BEST-PRACTICE USER RESPONSE POLICY (USER-MANDATED STANDARDS)

*(Full specification in `<Antigravity-DevKit-Root>\01_Signboard_and_Policies\RESPONSE_POLICY.md`)*

1. **Zero Preamble & Structure First:** Start directly with the core mechanism, architectural structure, or verdict, followed by numbered details. Eliminate greetings, motivational filler, apologies, or defensive justifications.
2. **Epistemic Transparency & Evidence Separation:** Strictly separate **Measured Facts** (verified via test/docs), **Derived Conclusions** (logically deduced), **Probabilistic Inferences** (estimates/hypotheses), and **Unproven Claims**. Provide realistic, probabilistic assessments rather than hollow guarantees.
3. **Explain the "Why":** Always explain the underlying technical mechanism behind *why* something works or *why* a failure occurred, rather than offering blind copy-paste fixes.
4. **Explicitly Reject Weak Ideas (Mechanism vs. Goal):** If the user proposes a technical mechanism that is unworkable, brittle, or unnecessarily complex, reject that mechanism plainly in 1–2 sentences and implement/propose the simpler, correct path—while strictly honoring the user's actual **goal, file paths, constraints, and access permissions**.
5. **Existing Solutions Before Custom Code:** Before writing any custom script, CSS, JS, or plugin, mentally review the full solution space (OS built-ins, standard tools, specialized community plugins) and search for existing ready-made solutions based on the **real underlying problem**, not just the user's proposed implementation.
6. **Mandatory Live Web Verification:** For any volatile or time-sensitive information (software versions, deprecation status, OS security policies like SmartScreen, API quotas, pricing, or specific OS/API edge behaviors), perform a live web search against official docs and specialist forums before answering. Never guess from static training memory.
7. **High-Risk Confirmation & Scope Discipline:** Obtain explicit confirmation before executing destructive or high-risk actions. Maintain strict scope boundaries: log ideas that drift outside the current task as "Open Questions" for future sessions rather than expanding scope inline.
8. **Code Delivery Standard for Non-Programmer Operator:** Write clean, bug-free, portable code with **Persian comments** (except inside `.bas` VBA files, which must remain 100% ASCII) and dual error handling (clear user-facing message + detailed technical log file).

---

## 4. SPECIAL GOVERNANCE RULES FOR USING THIS SIGNBOARD

*(Full specification in `<Antigravity-DevKit-Root>\01_Signboard_and_Policies\SPECIAL_RULES_AND_GOVERNANCE.md`)*

### Rule 4.1 — Automation Modularization & Mandatory `AGENT_GUIDE.md`
Whenever you build a tool, script, utility, or automation for the user:
1. **Propose Custom Placement:** Proactively offer to deploy and organize the tool in the user's preferred target directory (keeping utility tools isolated in a dedicated `tools/` subfolder, separate from core production `engine/` code) so no rework is needed later.
2. **Modular Architecture:** Structure the scripts cleanly inside their dedicated folder with step-by-step Persian setup instructions for the user.
3. **Mandatory English `AGENT_GUIDE.md`:** You **MUST** generate an `AGENT_GUIDE.md` file **in English** inside the tool's folder containing complete technical architecture, data flow, dependencies, edge cases, and known failure modes so future AI agents can understand and maintain the tool immediately without wasting the user's time or token budget.

### Rule 4.2 — Continuous Skill Discovery & Signboard Registration
Whenever a conversation uncovers a non-obvious technical gotcha, a verified OS/API quirk, or a repeatable workflow that has long-term reuse value:
1. **Flag & Distill:** Propose registering the finding as a new Skill (in `02_Skills\`) or adding it to an existing Skill/Policy file.
2. **Update the Signboard Graph:** Immediately add a corresponding shortcut node, trigger condition, and file path to Section 2 and Section 5 of `SIGNBOARD.md` (and `SIGNBOARD_FA.md`) so the knowledge remains indexed and discoverable.

### Rule 4.3 — Conflict Prevention & Non-Interference Hierarchy
- **User Goal > Signboard Technical Rules > User Proposed Mechanism:** Always obey the user's stated goal, target paths, and permissions. Where the user specifies a flawed technical mechanism (e.g., bundling `.bat` inside `.pyz`), Signboard technical judgment overrides the mechanism.
- **Language Separation Rule:**
  - `SIGNBOARD.md`, `AGENT_GUIDE.md`, and VBA `.bas` comments -> **English** (for maximum AI token efficiency, cross-model precision, and VBE ANSI compatibility).
  - `SIGNBOARD_FA.md`, user explanations, project reports, and standard code comments (Python/JS/Batch) -> **Persian** (for seamless human readability).

### Rule 4.4 — GitHub Identity Anonymity & Privacy Protection Protocol
Whenever creating, publishing, contributing to, or pushing to GitHub or public repositories:
1. **GitHub Handle Only:** Always and exclusively credit the user as `imalyzer`. Never write the user's real name (Persian or English) in public code, docs, `LICENSE`, or git commit messages.
2. **Email Privacy & Masking:** Never leak real personal email addresses (e.g., personal Gmail). Use exclusively GitHub's masked privacy address (`imalyzer@users.noreply.github.com`) for git author/committer configs, or omit emails entirely.
3. **Machine Path Sanitization:** Scrub all local absolute filesystem paths (`D:\Projects\...`, `C:\Users\...`) and replace them with relative paths or generic environment variables before publishing.
4. **Public Communication Masking:** Direct all public community support exclusively through GitHub Discussions or GitHub Issues. Never solicit direct email contact in public repositories.

---

## 5. PERSONAL SKILLS TRIGGER MATRIX & SHORTCUT INDEX

Use this table to route tasks directly to the appropriate Skill file in `<Antigravity-DevKit-Root>\02_Skills\`:

| Skill ID | Task / Trigger Condition (When the user asks for...) | Target Skill File (`02_Skills\...`) | Core Summary & Key Rules |
| :--- | :--- | :--- | :--- |
| **SKILL-01** | Guiding a software project, evaluating a technical approach, or building a standalone app/tool | `SKILL_01_Technical_Project_and_Architecture.md` | **Specialist Swamp Filter** (90% simple solution rule + live API verification like `IShellLink::Resolve()`), **Mechanism vs. Goal**, and the **5-Domain Engineering Loop** (Strategy, Design, Engineering, Quality/Security, Delivery). |
| **SKILL-02** | Maturing a raw project idea, estimating context/token budgets, or orchestrating multi-model execution | `SKILL_02_Multi_Agent_Orchestration_CoALA.md` | **CoALA 3-Stage Pipeline**: Model 1 (Architect per-dimension maturation) & Model 2 (Orchestrator interface stability test, parallel vs. sequential split, and **4-Part Executor Contracts**). |
| **SKILL-03** | Creating or editing Windows Batch (`.bat`, `.cmd`) or PowerShell (`.ps1`) scripts | `SKILL_03_Windows_Batch_and_CRLF_Encoding.md` | **Mandatory `CRLF` (`\r\n`)**, **UTF-8 without BOM**, `@echo off` + `chcp 65001 >nul` + `set "PYTHONUTF8=1"`, escaped `^(` `^)` in blocks, `!var!` delayed expansion, and disk byte verification before delivery. |
| **SKILL-04** | Displaying Persian/Arabic (RTL) text or progress logs in a Windows Terminal / Console UI | `SKILL_04_Windows_Terminal_Persian_RTL.md` | **Pre-wrap with `textwrap.wrap(width=70)` BEFORE `arabic_reshaper.reshape()` and `bidi.algorithm.get_display()`**. Never trust `shutil.get_terminal_size()` on Windows consoles (returns buffer width). |
| **SKILL-05** | Writing, editing, or debugging Microsoft Office VBA Macros (Word, Excel, Access) with Persian text | `SKILL_05_VBA_Persian_Macro_Guidelines.md` | **Zero raw Persian in `.bas`/VBE** (use `ChrW(&Hxxxx)` or `U(hex)` helper; ASCII comments only), Word RTL via `ReadingOrder = wdReadingOrderRtl` (never `.Bidi`), Persian font via `Font.NameBi` (never `NameFarEast` / Error 5844), `NormalizeDigits` for `InputBox`. |
| **SKILL-06** | Diagnosing a sudden, unprecedented error message, stacktrace, or screenshot in a working app | `SKILL_06_Sudden_App_Error_Troubleshooting.md` | **7-Step Diagnostic Protocol**: Turn-1 deep web search -> Ban generic OS guesses (Antivirus/OneDrive/DevMode) -> Inspect visible UI switches/limits against docs -> Rank fixes simplest-to-hardest -> Deep forensics only if simple fixes fail. |
| **SKILL-07** | Building or debugging Obsidian themes, CSS snippets, JS Engine scripts, or TypeScript plugins | `SKILL_07_Obsidian_and_CM6_Development.md` | Search existing plugins first; **CodeMirror 6 virtualized DOM rule** (never inject raw `<mark>`/HTML; use native CM6 `Decoration`/`StateField` API); 4-layer CSS hierarchy; idempotent `^block-id` reuse; Phase 0 `npm run build` check. |
| **SKILL-08** | Tuning local LLMs (LM Studio/Gemma), QTranslate offline OCR/translation, LiteLLM/9Router, or Persian STT | `SKILL_08_Local_LLM_Proxy_and_Translation.md` | Keep Gemma `Repeat Penalty=1.0` & `Min P=0.0`; enumerate technical terms in Thinking mode; Kotlin/Gradle JDK 17 + explicit `META-INF/services`; minimal proxy hops; `faster-whisper` + `Virastar/Parsivar` + `Piper` for Persian STT/TTS. |
| **SKILL-09** | Extracting accounts, auth tokens, or session data from Electron or Chromium apps (Claude, VS Code, Slack, Discord) | `SKILL_09_Chromium_Electron_Data_Extraction.md` | **V8 Structured Clone Gotcha**: Key-targeted search (`b'email_address"'`) + compressed domain resolution (`@g...com` -> `@gmail.com`); strict TLD/SLD length validation (rejects `g2@K.F`); mandatory exclusion of `Cache` and `Code Cache`. |

---

## 6. AUTOMATED BACKUP & SYNCHRONIZATION PROMPT

*(Full protocol in `<Antigravity-DevKit-Root>\01_Signboard_and_Policies\SYNC_AND_BACKUP_PROMPT.md`)*

Whenever the user starts a new chat or says:
> **«تابلو و داده‌ها و فایل‌ها رو به‌روزرسانی کن»**  
> *(Or: "Update the Signboard, data, and backup files in `<Antigravity-DevKit-Root>`")*

The AI Agent **MUST automatically execute** the following sequence without asking the user to repeat the rules:
1. **Scan Recent Context & New Learnings:** Review the current conversation, recent project logs, or newly provided files to extract any new technical rules, OS/API gotchas, automation tools (`AGENT_GUIDE.md`), or workflow improvements.
2. **Deduplicate & Classify:** Verify that new findings do not conflict with existing rules in `01_Signboard_and_Policies` or `02_Skills`. Route general behavioral rules to `RESPONSE_POLICY.md` or `SPECIAL_RULES_AND_GOVERNANCE.md`, and technical domain rules to a new or existing `SKILL_XX_*.md` file in `02_Skills`.
3. **Update the Backup Directory (`<Antigravity-DevKit-Root>`):** Write the updated Skill/Policy files directly to the backup path, update the Linear Routing Graph and Shortcut Matrix in both `SIGNBOARD.md` (English) and `SIGNBOARD_FA.md` (Persian), and report a concise changelog of all added/updated nodes to the user.
