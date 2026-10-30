---
name: skill-08-local-llm-proxy-and-translation
description: Hard-won technical configurations for LM Studio parameters (Gemma), offline QTranslate + Tesseract OCR Kotlin/Gradle plugins, LiteLLM / 9Router proxy setup, and Persian STT/TTS transcription pipelines.
---

# SKILL 08: Local LLMs, API Proxies, Offline Translation & Persian Transcription

> **File Path:** `D:\Projects\Iman Sheybani\software\Antigravity\02_Skills\SKILL_08_Local_LLM_Proxy_and_Translation.md`  
> **Trigger:** Whenever configuring LM Studio parameters, working on the QTranslate offline pipeline, editing Kotlin/Gradle plugins, configuring LiteLLM / 9Router / Free Claude Code, or working on the Persian transcription tool.  
> **Source:** `claude-memory-2026-10-23` (`projects\Qtranslate\*`, `areas\litellm-proxy.md`, `areas\persian-transcription-skill.md`, `topics\tools.md`).

---

## 1. Local LLM Tuning & Specialized Translation Rules (LM Studio / Gemma)

1. **Strict Parameter Defaults for Rule Consistency:**
   - Non-default sampling tweaks in LM Studio (`Repeat Penalty = 1.1`, `Min P = 0.05`) caused Gemma models (`gemma-4-e4b`) to inconsistently drop technical term annotations (Rule 6: appending the original English technical term in parentheses after the Persian translation).
   - **Mandatory Rule:** Keep `Repeat Penalty = 1.0` and `Min P = 0.0` (official Gemma defaults) for deterministic instruction following in specialized translation tasks.
2. **Thinking Mode Term Enumeration:**
   - Instruct the model in its system prompt to explicitly **enumerate all domain/technical terms during the `<think>` / Thinking phase** before outputting the final Persian translation. This substantially improves bilingual terminology accuracy.
3. **Evaluate on Real Domain Text:**
   - Always benchmark translation or local LLM changes against real specialized text (e.g., audio engineering, studio acoustics, mixing/mastering specs) rather than synthetic examples.

---

## 2. QTranslate Offline Pipeline & Kotlin/Gradle Plugin Rules

- **Architecture:** Modular VST-style pipeline: `ahatem/QTranslate` (open-source rewrite) + Local `LM Studio` HTTP server + `Tesseract OCR` via local Python Flask (`tesseract_ocr_server.py` on `127.0.0.1:8765`) + Custom Kotlin plugin (`qtranslate-tesseract-ocr-1.0.0.jar`).
- **Build & Dependency Rules (Costly to Relearn):**
  1. **Never rely on JitPack for `qtranslate-api`:** JitPack returns HTTP `401`. Always reference the local `QTranslate.jar` via `compileOnly(files(...))` in Gradle.
  2. **Strict JDK & Kotlin Version Matching:** JDK 25 + Kotlin 2.0.0 fails. Use **JDK 17 (Eclipse Adoptium)** pinned via `org.gradle.java.home` in `gradle.properties`, paired with **Kotlin 2.3.0** to match QTranslate's compiled bytecode.
  3. **Explicit ServiceLoader Registration:** Always verify that `META-INF/services/com.github.ahatem.qtranslate.api.plugin.Plugin` is present and accurate, or QTranslate will silently ignore the JAR.
  4. **Explicit Serialization Plugin:** Include `kotlin("plugin.serialization")` in `build.gradle.kts`—omitting it causes silent JSON parsing failures with no clear stacktrace.
  5. **AI Services Timeout Awareness:** Long chains in Thinking mode can exceed hardcoded socket timeouts (e.g., `socket_timeout=15000ms` in the AI Services plugin); account for reasoning latency when configuring client timeouts.

---

## 3. API Proxy Infrastructure (LiteLLM / 9Router / Free Claude Code)

1. **Minimal Proxy Hops:** Keep the local proxy chain between client tools (`Cursor`, `Claude Desktop`, `Free Claude Code` at `D:\Projects\Iman Sheybani\software\free_claude_code`) and `9Router` (`localhost:20128`) or `LiteLLM` (WSL2/Ubuntu) as short and direct as possible—no redundant proxy layers.
2. **Claude Desktop Model-Name Quirk:** When routing custom/free-tier endpoints to Claude Desktop via LiteLLM, `model_name` must resemble an Anthropic model identifier (e.g., `claude-opus-5`) to avoid client-side rejection.
3. **Gemini API Quota Reality:** Rate limits apply **per Google Cloud Project**, not per API key. Combining multiple keys only scales quota when each key belongs to a separate Google Cloud Project.
4. **Cursor Free Plan BYOK Caveat:** Account-wide quota pauses on Cursor's Free tier cannot be bypassed simply by entering a BYOK key.

---

## 4. Persian Live Transcription & Linear Notation Architecture

When working on the trilingual (Persian / English / French) live transcription and editing tool:
- **Validated Open-Source Stack:**
  - **STT (Speech-to-Text):** `faster-whisper`
  - **Persian Text Normalization:** `Virastar` / `Parsivar`
  - **Local TTS (Text-to-Speech):** `Piper`
  - **LLM Post-Processing:** Routed via local LiteLLM / 9Router proxy (requires a model **>4B parameters** to reliably execute the custom linear notation rules).
- **Known Ecosystem Gap:** There is currently no reliable, ready-made off-the-shelf tool for automatic Persian diacritization (اعراب‌گذاری); do not promise a plug-and-play library for that sub-step without empirical verification.
