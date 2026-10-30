---
name: skill-13-electron-context-isolation-and-lexical-bidi
description: Electron preload context isolation barrier bypass, Meta Lexical multi-paragraph BiDi architecture, zero spacebar caret jumps, Shift+Enter paragraph dispatch, and multiline paste splitting.
---

# SKILL 13: Electron Context Isolation, Lexical Multi-Paragraph BiDi & Hot-Patching

> **File Path:** `D:\Projects\Iman Sheybani\software\Antigravity\02_Skills\SKILL_13_Electron_Context_Isolation_and_Lexical_BiDi.md`  
> **Trigger:** Whenever patching or extending Electron desktop applications, dealing with `preload.js` vs Main World DOM property barriers (`contextIsolation: true`), fixing BiDi / RTL mixed-direction editing in Meta Lexical or contenteditable rich text editors, preventing cursor/caret jumping on spacebar, or inspecting running apps via Chrome DevTools Protocol (CDP).  
> **Source:** `Antigravity UI` Smart BiDi & Lexical Architecture Engineering.

---

## 1. The Context Isolation Trap: Preload vs. Main World DOM Properties

### The Anti-Pattern
When developing Electron preload scripts or extensions with `contextIsolation: true` (Electron standard since v12), developers assume that having access to `document` in `preload.js` means they can access all JavaScript properties attached to DOM elements:
```javascript
// INSIDE preload.js (RUNS IN ISOLATED WORLD):
const el = document.querySelector('div[contenteditable="true"]');
const editor = el.__lexicalEditor; // ==> ALWAYS undefined!
```

### The Architectural Reality
* **DOM Nodes Are Shared:** `document.querySelector`, `classList`, `setAttribute`, and CSS injection operate on the shared underlying DOM.
* **JavaScript Objects Are Isolated:** Custom object properties, prototypes, and framework instances attached to DOM elements by React, Vue, or Meta Lexical (e.g., `el.__lexicalEditor`, `el._reactRootContainer`, CodeMirror `cmView`, Monaco instance) exist exclusively in the **Main World**.
* **Silent Failure:** In the preload isolated world, `el.__lexicalEditor` returns `undefined` without throwing an error. Any event listeners or hooks that depend on the editor silently fail to attach.

### The Standard Solution: Main World Injection Vector
To interact with framework editor instances from a preload script, you **MUST** bridge into the Main World:

```javascript
// INSIDE preload.js:
const MAIN_WORLD_SCRIPT = `
(function() {
    const el = document.querySelector('div[contenteditable="true"]');
    if (el && el.__lexicalEditor) {
        // 100% accessible here!
        const editor = el.__lexicalEditor;
        // attach commands / hooks...
    }
})();
`;

// Vector 1: Official Electron webFrame API (Preferred)
try {
    const electron = typeof electron_1 !== 'undefined' ? electron_1 : require('electron');
    if (electron && electron.webFrame) {
        electron.webFrame.executeJavaScript(MAIN_WORLD_SCRIPT);
    } else {
        throw new Error('webFrame not found');
    }
} catch (err) {
    // Vector 2: Fallback DOM <script> injection (Universal)
    const script = document.createElement('script');
    script.textContent = MAIN_WORLD_SCRIPT;
    (document.head || document.documentElement).appendChild(script);
    script.remove();
}
```

---

## 2. Meta Lexical BiDi Architecture: The Single-Paragraph Trap

### The Problem in Rich Text Inputs
In Meta Lexical (used by Antigravity, Facebook, and modern chat applications):
1. By default, pressing `Shift + Enter` triggers `INSERT_LINE_BREAK_COMMAND`, inserting `<br>` inside the **existing `<p>` element**.
2. In Chromium/Blink, an element with `dir="auto"` evaluates directionality based solely on the **First Strong Character of the block container**.
3. If Line 1 is Persian, the entire `<p>` becomes `dir="rtl"`.
4. Subsequent lines (even Windows paths like `C:\Users\...` or English code) remain inside the same RTL paragraph, causing:
   - English lines to be forced to the right margin.
   - Punctuation (colons, slashes, brackets) at line boundaries to invert or render at the wrong edge.

### The CSS Hack Trap (Why CSS `unicode-bidi: plaintext` Fails in ContentEditable)
Attempting to fix this by forcing CSS on the editor:
```css
/* DANGEROUS / FLAWED FIX: */
div[contenteditable="true"] p {
    direction: ltr !important;
    unicode-bidi: plaintext !important;
}
```
**Causes the Caret Jump Bug:**
* When typing Persian, the letters are strong RTL.
* But because the paragraph container is forced to `direction: ltr`, trailing whitespace (typing a Spacebar) is neutral (`WS`).
* With no following strong character, Blink resolves the trailing space to the container's base direction (LTR).
* **The caret instantly jumps to the far-left / beginning of the line**, making Persian typing impossible.

---

## 3. The Multi-Paragraph Architecture (The Permanent Fix)

Instead of CSS hacks, enforce the **One-Line = One-Paragraph Rule** directly inside Lexical's command pipeline at `COMMAND_PRIORITY_CRITICAL` (4):

```text
[User Hits Shift + Enter]
          │
          ▼
[Lexical Engine fires INSERT_LINE_BREAK_COMMAND]
          │
          ├──► Hooked at Priority 4:
          │      1. Prevent <br> insertion (return true)
          │      2. Execute INSERT_PARAGRAPH_COMMAND handlers
          │
          ▼
[Lexical creates a NEW ParagraphNode (<p dir="auto">)]
          │
          ├── Line 1 (Persian) ──► <p dir="auto"> evaluates to RTL (Right aligned, spacebar stable)
          ├── Line 2 (English) ──► <p dir="auto"> evaluates to LTR (Left aligned)
          └── Empty Lines      ──► <p dir="auto"><br ...></p> retain native 24px line height
```

### Complete Lexical Hook Implementation

```javascript
function attachLexicalHooks() {
    const el = document.querySelector('div[contenteditable="true"]');
    if (!el || !el.__lexicalEditor) return false;
    const editor = el.__lexicalEditor;
    const editorKey = editor._key;

    // Guard against redundant registrations; update if editor is re-mounted by React
    if (el.getAttribute('data-antigravity-editor-key') === editorKey) return true;
    el.setAttribute('data-antigravity-editor-key', editorKey);

    let insertLineBreakCmd = null;
    let insertParagraphCmd = null;
    let pasteCmd = null;

    for (const [cmd] of editor._commands) {
        if (cmd.type === 'INSERT_LINE_BREAK_COMMAND') insertLineBreakCmd = cmd;
        if (cmd.type === 'INSERT_PARAGRAPH_COMMAND') insertParagraphCmd = cmd;
        if (cmd.type === 'PASTE_COMMAND') pasteCmd = cmd;
    }

    // 1. Shift+Enter Hook: Convert LineBreak into Paragraph
    if (insertLineBreakCmd && insertParagraphCmd) {
        editor.registerCommand(
            insertLineBreakCmd,
            () => {
                const pHandlers = editor._commands.get(insertParagraphCmd);
                if (pHandlers) {
                    for (let p = 0; p < pHandlers.length; p++) {
                        if (pHandlers[p]) {
                            for (const fn of pHandlers[p]) fn();
                        }
                    }
                }
                return true; // Cancel line break
            },
            4 // COMMAND_PRIORITY_CRITICAL
        );
    }

    // 2. Multiline Paste Hook: Split lines into separate ParagraphNodes
    if (pasteCmd) {
        editor.registerCommand(
            pasteCmd,
            (event) => {
                if (!(event instanceof ClipboardEvent)) return false;
                const text = event.clipboardData?.getData('text/plain');
                if (!text || (!text.includes('\n') && !text.includes('\r'))) {
                    return false; // Single line: allow Lexical default
                }
                event.preventDefault();
                const lines = text.split(/\r\n|\r|\n/);
                editor.update(() => {
                    const ParagraphClass = editor._nodes.get('paragraph').klass;
                    const TextClass = editor._nodes.get('text').klass;
                    const sel = editor._editorState._selection;
                    if (!sel) return;

                    const nodes = [];
                    for (let i = 0; i < lines.length; i++) {
                        const p = new ParagraphClass();
                        if (lines[i].length > 0) {
                            p.append(new TextClass(lines[i]));
                        }
                        nodes.push(p);
                    }
                    sel.insertNodes(nodes);
                });
                return true; // Paste handled
            },
            4 // COMMAND_PRIORITY_CRITICAL
        );
    }

    return true;
}

// Re-attach whenever the editor gains focus or DOM changes
document.addEventListener('focusin', attachLexicalHooks, true);
document.addEventListener('pointerdown', attachLexicalHooks, true);
attachLexicalHooks();
```

### Accompanying Minimal CSS
```css
/* Allow Lexical <p dir="auto"> to determine start edge natively */
div[contenteditable="true"] p {
    text-align: start !important;
}

/* Strictly isolate code and terminal blocks from BiDi */
pre, code, .code-block, .monaco-editor, .monaco-editor * {
    direction: ltr !important;
    text-align: left !important;
    unicode-bidi: isolate !important;
}
```

---

## 4. Live Inspection & Hot-Reloading via Chrome DevTools Protocol (CDP)

When patching running Electron apps, do not force-kill the process repeatedly. Use CDP to inspect, verify, and reload:

### 1. Locate the Dynamic CDP Port
Electron apps write their active debug port to:
`%AppData%\<AppName>\DevToolsActivePort` (Line 1 contains the port number).

### 2. Connect via Node.js Native WebSocket
Node.js v22+ includes native global `WebSocket`:
```javascript
const http = require('http');
const fs = require('fs');

const portFile = fs.readFileSync('C:\\Users\\<User>\\AppData\\Roaming\\<App>\\DevToolsActivePort', 'utf-8');
const port = parseInt(portFile.trim().split('\n')[0]);

http.get(`http://127.0.0.1:${port}/json`, (res) => {
    let data = '';
    res.on('data', chunk => data += chunk);
    res.on('end', () => {
        const pages = JSON.parse(data);
        const page = pages.find(p => p.type === 'page');
        const ws = new WebSocket(page.webSocketDebuggerUrl);
        ws.onopen = () => {
            // Send CDP commands: Runtime.evaluate, Page.reload, Input.dispatchKeyEvent
        };
    });
});
```

---

## 5. Electron ASAR Repacking Safety Rules

1. **Preserve Native / Unpacked Dependencies:**
   Always inspect if the app has an `app.asar.unpacked` folder. When packing with `npx asar`, pass the exact unpack patterns:
   ```cmd
   npx asar pack "src" "build\app.asar" --unpack-dir "node_modules/chrome-devtools-mcp"
   ```
2. **Never Edit Files Inside ASAR Directly:**
   Always decompile (`npx asar extract app.asar extracted`), make discrete edits in `src`, build to `build\app.asar`, and verify byte size before copying to `resources\app.asar`.
3. **Always Keep Factory Backups:** Maintain `app.asar.original` and a 1-click restore script (`restore_original.bat`) compliant with SKILL-03 (`CRLF`, UTF-8 no BOM).

---

## 6. The In-Memory ASAR Cache Trap & Dynamic Hot-Update Protocol

### The Windows Non-Exclusive Lock Trap
On Windows, Electron's `app.asar` does **not** have an exclusive OS write lock. A script can overwrite `resources\app.asar` while the application is running without triggering `EBUSY` or permission errors.
* **The Trap:** Developers assume that because the file was replaced on disk without errors, reloading the renderer (`location.reload()` or `Page.reload` via CDP) will load the updated code.
* **The Reality:** Electron's C++ core (`atom/common/asar`) memory-maps and caches the ASAR header table and file offsets at startup. The running process continues to read from the original memory map and open file descriptors.
* **The Consequence:** Neither `Page.reload()` nor navigating to new routes will execute newly patched code inside `app.asar` until the main Electron process is terminated and relaunched.

### The Dual Live-Patching vs. Offline-Patching Protocol
1. **Offline Update Flow (`2_Smart_Update_Patch.bat` for End Users):**
   * Check if process is running: `tasklist /FI "IMAGENAME eq AppName.exe"`.
   * Terminate cleanly: `taskkill /F /IM "AppName.exe"`.
   * Extract live `app.asar`, apply patches, repack, and prompt user to launch.
2. **Live Session Hot-Patch Flow (When Agent Runs Inside Target App):**
   * **Do NOT execute `taskkill`:** Killing the host process kills the active AI agent session.
   * **Write to Disk:** Overwrite `resources\app.asar` so changes are permanent across all future launches.
   * **Live Bridge Injection via CDP:** Connect to the dynamic port from `DevToolsActivePort` and execute `Runtime.evaluate` to inject the runtime engine directly into the live Main World. This enables immediate user testing without session disruption.

---

## 7. Self-Healing Dynamic In-Place ASAR Patcher (`smart_patch.js`)

### Why Static Pre-Built ASAR Files Fail Over Time
Shipping a pre-compiled `app.asar` binary breaks when the vendor updates the application:
* Overwriting a newly updated 4.38 MB `app.asar` with an older 4.20 MB archive silently downgrades all vendor bug fixes, new features, and security patches.
* If the vendor introduces new internal dependencies, the old archive crashes at boot.

### The 6-Step Dynamic Patcher Algorithm
Instead of distributing static binary archives, distribute a dynamic Node.js engine (`smart_patch.js`):
1. **Target Validation:** Verify `%LOCALAPPDATA%\Programs\<App>\resources\app.asar` exists.
2. **Safety Backup:** Copy `app.asar` to `app.asar.backup_before_patch` if not already present.
3. **Clean Staging:** Prepare a temporary extraction sandbox (`temp_patch_stage`).
4. **Live Extraction:** Extract the vendor's newly installed `app.asar` via `npx asar extract`.
5. **Discrete AST / Regex Patching:**
   * Append self-contained `bidi_engine.js` to `dist/preload.js` (with idempotency guards to replace existing patch blocks if present).
   * Enable `devTools: true` across all versions: patch `dist/debugConsole.js` (`isDebugConsoleEnabled() -> true`) in newer releases and `dist/utils.js` (`devTools: true`) in legacy/direct releases.
   * Preserve DevTools menu items in `dist/menu.js`.
6. **Repack & In-Place Swap:** Repack with `--unpack-dir` flags and atomically replace `resources\app.asar`.
Result: 100% of vendor update features are preserved while custom patches are seamlessly merged.
