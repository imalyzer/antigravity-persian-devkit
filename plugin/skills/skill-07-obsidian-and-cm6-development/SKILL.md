---
name: skill-07-obsidian-and-cm6-development
description: Technical rules and architectural learnings for Obsidian theme development, CSS snippets, JS Engine scripts, CodeMirror 6 (CM6) virtualized rendering, and custom TypeScript plugins.
---

# SKILL 07: Obsidian Theme, Plugin & CodeMirror 6 (CM6) Development Guidelines

> **File Path:** `02_Skills/SKILL_07_Obsidian_and_CM6_Development.md`  
> **Trigger:** Whenever working on the user's bilingual (Persian RTL + English LTR) Obsidian vault, custom themes, CSS snippets, JS Engine scripts, or TypeScript Obsidian plugins.  
> **Source:** `claude-memory-2026-10-23\projects\Obsidian\learnings-and-approach.md` and `overview.md`.

---

## 1. Existing Obsidian Solutions First

Before writing any custom TypeScript plugin, JS Engine script, or complex CSS workaround:
- Search the official Obsidian Community Plugins catalog and ecosystem **based on the real functional problem**, not the user's initial implementation idea.
- Keep in mind the user's active plugin ecosystem (including `Style Settings`, `Dataview`, `JS Engine`, `Custom Note Width`, `Block Link Plus`) to avoid feature duplication or cursor-position conflicts.

---

## 2. CodeMirror 6 (CM6) Virtualized Rendering Rule (No Raw DOM Injection)

- **Critical Technical Rule:** Obsidian's Live Preview and Source editors run on **CodeMirror 6 (CM6)**, which uses **virtualized viewport rendering** (only visible lines exist in the DOM, and DOM nodes are continuously recycled and redrawn on scroll/edit).
- **What Fails:** Directly injecting raw HTML elements (such as `<mark>` tags or custom `<span>` wrappers via `innerHTML` or standard DOM manipulation) into `.cm-content` fails, gets stripped immediately by CM6, or corrupts editor state (as seen in the paste-highlight JS Engine experiment).
- **Correct Solution:** Any editor text highlighting, badge rendering, or inline visual modification in Live Preview/Source mode **must** use CodeMirror 6's native `StateField`, `StateEffect`, and `Decoration.mark` / `ViewPlugin` APIs.

---

## 3. Obsidian Theme & CSS Architecture

1. **4-Layer Styling Hierarchy:** Respect Obsidian's cascade order when debugging or authoring styles:
   - Layer 1: `app.css` (Obsidian core variables and defaults)
   - Layer 2: Active Theme (`theme.css` + `manifest.json` — e.g., Minimal or AnuPpuccin base integrated with `Style Settings`)
   - Layer 3: CSS Snippets (`.obsidian/snippets/*.css`)
   - Layer 4: Per-note `cssclasses` frontmatter property
2. **Bilingual RTL/LTR Harmony:** All theme and snippet rules must preserve clean alignment and font rendering when Persian (RTL) paragraphs and inline English (LTR) code/terms coexist in the same note.

---

## 4. Custom Obsidian Plugin Engineering Rules

1. **Mandatory Phase 0 (Green Scaffold First):**
   - Before writing any vault-scanning, regex, or UI logic for a new TypeScript plugin, set up the project scaffold and verify that `npm run build` compiles cleanly (Green Phase 0).
2. **Idempotency in Vault/Block Modifications:**
   - When a plugin scans notes and assigns block IDs (`^id`)—such as in `placeholder-entity-indexer`—it **must be strictly idempotent**: if a block already has an existing `^id`, reuse that exact ID. Never append a duplicate `^id` and never overwrite an existing ID (which would break existing embeds/backlinks across the vault).
3. **JS Engine Plugin Format Constraint:**
   - Scripts written for the Obsidian `JS Engine` plugin must follow its required **class-only / ES execution format** (do not use Node/CommonJS `module.exports`).
