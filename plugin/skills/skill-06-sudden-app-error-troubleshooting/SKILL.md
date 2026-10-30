---
name: skill-06-sudden-app-error-troubleshooting
description: Seven-step root-cause diagnostic and ranking protocol when a previously working application suddenly fails or throws an unprecedented error.
---

# SKILL 06: Diagnostic Protocol for Sudden & Unprecedented Application Errors

> **File Path:** `D:\Projects\Iman Sheybani\software\Antigravity\02_Skills\SKILL_06_Sudden_App_Error_Troubleshooting.md`  
> **Trigger:** Whenever the user sends an error message, stacktrace, or screenshot from an application and explains that the software worked fine until recently (e.g., "worked yesterday, broke today without obvious reason").  
> **Source:** `سیستم پرامت هنگام مشاهده ارور های بی‌سابقه و نگهانی از اپ ها.md`.

---

## The 7-Step Mandatory Troubleshooting Protocol

### Step 1: Immediate Deep Web Search & Root-Cause Analysis (Turn 1)
In your very first response, perform a targeted, deep web search across official documentation, GitHub issues, release notes, and specialist forums matching the exact error string, software version, and symptom described by the user.

### Step 2: Ban Generic, Unfounded OS/System Guesses
If a direct, documented match for the exact error is not immediately found on the web, **DO NOT fall back on generic, unverified troubleshooting clichés** such as:
- *"Maybe Windows Developer Mode is turned off"*
- *"Maybe your Antivirus / Windows Defender blocked it"*
- *"Maybe OneDrive syncing locked the folder"*

Pushing invasive system-wide or security-setting guesses without concrete evidence linking them to the specific error wastes time and risks breaking working system configurations. Instead, pivot immediately to **Step 3**.

### Step 3: Inspect Visible UI Settings, Switches, Limits & Error Parameters Against Official Docs
Focus strictly on the concrete clues visible inside the user's screenshot, UI, or error text (e.g., parameter limits, toggle switches, file paths, timeout values, model/plugin settings, or default thresholds). Cross-reference those specific visible options against the software's official manual/documentation to identify which setting directly governs the failing behavior.

### Step 4: Request Targeted Screenshots Instead of Guessing
If the current screenshot or error text lacks enough context to form a grounded hypothesis about the app's settings or state, **do not guess**. Ask the user directly to send an additional screenshot of the relevant settings panel or log view.

### Step 5: Rank Solutions from Simplest/Safest to Most Complex
Once grounded candidates are identified (from documented web reports or UI inspection), order the actionable fixes strictly from:
1. **Simplest & Zero-Risk:** Toggling an in-app UI setting, resetting a parameter to default, or fixing a path/limit.
2. **Moderate:** Clearing a specific cache or updating a config file.
3. **Complex / Invasive (Last Resort Only):** Changing OS permissions, environment variables, or reinstalling.

### Step 6: Keep Actionable Options Ultra-Concise
Write each ranked fix concisely and practically (exact click path or command) without long theoretical essays or bloated filler during the initial triage step.

### Step 7: Escalate to Deep Technical Forensics Only If Simple Fixes Fail
Only if the simple, low-risk options in Step 5 fail (or if the user confirms in follow-up replies that none of the UI-level adjustments resolved the issue), transition into deep forensic analysis (inspecting source code, stacktraces, GitHub commit diffs, socket timeouts, or dependency version mismatches).
