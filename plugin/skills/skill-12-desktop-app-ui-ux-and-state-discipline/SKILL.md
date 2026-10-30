---
name: skill-12-desktop-app-ui-ux-and-state-discipline
description: Ergonomic UI/UX standards, Persian RTL vs LTR data isolation, click-to-record capsule controls, dynamic viewport height adaptivity, and strict manual persistence discipline for desktop apps.
---

# SKILL 12: Desktop App UI/UX Ergonomics, RTL Discipline & State Persistence Architecture

> **File Path:** `D:\Projects\Iman Sheybani\software\Antigravity\02_Skills\SKILL_12_Desktop_App_UI_UX_and_State_Discipline.md`  
> **Trigger:** Whenever designing, refining, or debugging desktop app GUIs (Electron, Tauri, WebView2), handling Persian/Arabic RTL vs LTR technical data, creating interactive hotkey/slider controls, or preventing accidental settings overwrites and window dead space.  
> **Source:** `Monitor Controller` Production Engineering & UI/UX Maturation.

---

## 1. The Core Trap: Rogue Auto-Persistence vs. Strict Manual Commit

### The Anti-Pattern
AI agents and developers frequently write reactive code that calls `saveSettings()` or dispatches `POST /api/config` automatically upon individual component interactions:
* Calling save inside a hotkey confirmation dialog.
* Calling save upon double-click editing a device/monitor name.
* Calling save when discovering hardware in a scanner.
* Calling save on every slider or switch change.

### The Catastrophic Result
When users adjust a setting to test or preview it and then close the window or discard the edit, the app has **silently written to disk (`settings.json`) behind their back**. The user's previous configuration is permanently overwritten without explicit intent.

### The Architectural Standard
```text
[User Interaction (Slider, Switch, Rename, Hotkey)]
        │
        ├──► [Real-Time Runtime Effect (RAM / Live DDC/CI / Live Preview)] ──► Live feedback in UI
        │
        └──► [Persistent Disk Storage (settings.json)] ──► BLOCKED
                                                            ▲
                                                            │ (ONLY on explicit click)
                                                   [Header Save Button (Floppy / Memory Card)]
```

> [!IMPORTANT]
> **Strict Manual Persistence Rule:**
> 1. **Live Preview != Persisted Config:** Individual widget interactions update live hardware or in-memory state only. Under **NO CIRCUMSTANCES** may a component interaction call `saveSettings()` or write to disk automatically.
> 2. **Single Point of Commit:** Only the primary Save action (the header memory card/floppy button) is permitted to persist `AppConfig` to disk.
> 3. **Unconfirmed Draft Disposal:** Any in-flight edits (e.g. typing a shortcut without clicking Confirm, switching tabs, clicking outside the control, or closing the app) must automatically revert to the baseline.
> 4. **Dual Backup Pairing:** Always pair the global Commit/Save button with an adjacent Export/Backup button (`dialog.showSaveDialog` + Blob fallback) to allow timestamped snapshots (`app-backup-YYYY-MM-DD.json`).

---

## 2. The Directionality Paradox: Semantic RTL vs. Technical LTR Controls

### The Problem
In Persian/Arabic desktop applications, setting `direction: rtl` globally across the entire container breaks technical components:
* Range sliders render backwards (0 on right, 100 on left).
* Hotkey combinations and keyboard shortcuts invert into mojibake (`Num1 + Win + Ctrl`).
* Numbers, file paths, and monospace code blocks become unreadable.
* Window management icons (`_ □ ✕`) get displaced.

### The Solution: Scoped Directional Isolation
Separate human typography from machine controls:

```html
<!-- Parent Row: Natural RTL Layout -->
<div class="inline-control-row" dir="rtl">
    <!-- Human Label (Right Edge in RTL) -->
    <span class="control-label">خاموش/روشن مانیتور اصلی:</span>
    
    <!-- Machine Capsule (Left Edge, Strictly Scoped LTR) -->
    <div class="control-capsule-bar" dir="ltr">
        <input type="text" class="key-input" readonly value="Ctrl + Win + Num1">
        <div class="capsule-actions">
            <button class="btn-cancel"><span>✕</span><span>انصراف</span></button>
            <button class="btn-confirm"><span>✓</span><span>تأیید</span></button>
        </div>
    </div>
</div>
```

### Layout Stability Rule
In an inline row (`display: flex; justify-content: space-between; align-items: center;`):
* First child (Persian Label) is anchored to the **RIGHT**.
* Second child (LTR Capsule) is anchored to the **LEFT**.
* When conditional action buttons pop into the capsule, the capsule expands **inward toward the empty center**. Neither the label on the right nor the shortcut text on the left shifts or jumps.

---

## 3. Compact Capsule Ergonomics (Click-to-Record Pattern)

### The Anti-Pattern
Adding bloated auxiliary buttons such as `"کلیدها را بزنید..."` (Press keys to record) or stacking labels vertically above input fields. This wastes 60% of vertical space and creates clumsy multi-step workflows.

### The Solution: The Input IS the Trigger
```javascript
// Click-to-record on the input field itself
input.addEventListener('click', () => {
    input.focus();
    input.select();
});

input.addEventListener('focus', () => {
    bar.classList.add('recording'); // Cyan glow
});

input.addEventListener('keydown', (e) => {
    e.preventDefault();
    if (e.key === 'Escape') { cancelEdit(target); return; }
    if (e.key === 'Enter')  { confirmEdit(target); return; }
    
    const combo = recordKeys(e);
    input.value = combo;
    
    // Reveal action buttons ONLY when a real change from baseline occurs
    if (combo !== baseline[target]) {
        bar.classList.add('has-changes');
    }
});
```

### CSS Capsule Pop-In Architecture
```css
.capsule-actions {
    display: none; /* Hidden by default */
    align-items: center;
    gap: 6px;
}

.control-capsule-bar.has-changes .capsule-actions {
    display: inline-flex;
    animation: capsulePopIn 0.2s cubic-bezier(0.16, 1, 0.3, 1) forwards;
}

@keyframes capsulePopIn {
    from { opacity: 0; transform: scale(0.92); }
    to   { opacity: 1; transform: scale(1); }
}
```

---

## 4. Viewport Height Adaptivity & Anti-Bloat Layout Discipline

### 1. Dynamic Window Height Adaptation (No Black Voids)
Desktop apps must not behave like static web frames with huge empty dead space under short content:
```javascript
// In Renderer:
function adaptWindowHeight() {
    requestAnimationFrame(() => {
        const contentHeight = document.querySelector('.active-tab').scrollHeight;
        const targetHeight = Math.round(contentHeight + 110); // Header + padding
        if (window.require) {
            const { ipcRenderer } = window.require('electron');
            ipcRenderer.invoke('fit-content-height', targetHeight);
        }
    });
}

// In Electron Main (main.js):
ipcMain.handle('fit-content-height', (event, targetHeight) => {
    if (!mainWindow || mainWindow.isMaximized()) return;
    const [width] = mainWindow.getSize();
    const clampedHeight = Math.max(520, Math.min(1080, targetHeight));
    mainWindow.setSize(width, clampedHeight, true); // true = smooth animation
});
```

### 2. Ultra-Wide Optical Bounding
Never let content cards stretch unconstrained across the full width of multi-monitor or 4K/ultrawide displays:
* Cap card widths: `max-width: 580px; margin: 0 auto;`
* Compact numeric inputs: `width: 68px; text-align: center;`
* Dense settings grid: Halve margins and gaps (e.g., `gap: 10px;` instead of `20px`).

---

## 5. Direct Scrubbing & Dynamic Peripheral Feedback on Sliders

### 1. Dynamic Track Fill (`--fill-pct`)
Standard HTML range sliders look dead without track fill. Dynamically drive fill percentage via CSS variable:
```javascript
function onSliderInput(slider, val) {
    slider.style.setProperty('--fill-pct', `${val}%`);
}
```
```css
.range-slider {
    background: linear-gradient(
        to right,
        var(--accent-color) var(--fill-pct),
        rgba(255, 255, 255, 0.1) var(--fill-pct)
    );
}
```

### 2. Direct Mouse Wheel Scrubbing
Eliminate thumb click fatigue by binding wheel increments directly to slider and input rows:
```javascript
row.addEventListener('wheel', (e) => {
    e.preventDefault(); // Stop window scroll
    const delta = e.deltaY < 0 ? 2 : -2;
    slider.value = Math.max(0, Math.min(100, parseInt(slider.value, 10) + delta));
    slider.dispatchEvent(new Event('input'));
}, { passive: false });
```

---

## 6. Frameless Shell Window Ergonomics Checklist

| Feature | Technical Implementation | Failure Mode if Missing |
| :--- | :--- | :--- |
| **Rounded Corners** | `.app-container { border-radius: 14px; }` windowed, `0px` maximized. | Window looks like an unstyled raw rectangle. |
| **Titlebar Drag** | `-webkit-app-region: drag;` on bar, `no-drag;` on controls. | User cannot move the window or click buttons. |
| **Double-Click Maximize** | `ipcRenderer.send('window-toggle-maximize')` on dblclick. | Fails standard Windows desktop behavior. |
| **Maximized Drag Restore** | `ipcRenderer.send('unmaximize-to-drag', { screenX, screenY })`. | Dragging maximized window moves a giant full-screen box. |
| **Header Action Slot** | Emerald Save (`#10b981`) + Cyan Export (`#06b6d4`) at fixed optical slot. | Buried save actions, lost configurations. |
