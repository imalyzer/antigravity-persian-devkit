---
name: skill-04-windows-terminal-persian-rtl
description: Tested method for rendering connected, properly ordered Persian/Arabic (RTL) text in Windows Terminal, CMD, and PowerShell using fixed-width pre-wrapping before arabic_reshaper and python-bidi, plus zero-dependency standalone Node.js helper for mixed CLI tokens.
---

# SKILL 04: Displaying Persian / RTL Text in Windows Terminal & Console Apps

> **File Path:** `02_Skills/SKILL_04_Windows_Terminal_Persian_RTL.md`  
> **Trigger:** Whenever building a CLI tool, terminal UI, progress logger, Windows batch launcher, or console script that outputs Persian or Arabic (RTL) text.  
> **Source:** `سیستم پرامپت هدایت فنی پروژه.md` (§5) & Monitor Controller Production Debugging.

---

## 1. The Core Problem in Windows Consoles

In Windows console hosts (`cmd.exe`, Windows PowerShell, and Windows Terminal):
1. Characters are rendered left-to-right in isolated form unless reshaped and reordered via the Unicode Bidirectional Algorithm.
2. **The Buffer-Width Trap:** Calling `shutil.get_terminal_size()` on Windows frequently returns the console **buffer width** rather than the actual visible window width, or returns an inaccurate column count. If a reshaped/bidi-reversed Persian string exceeds the visible window width and the terminal wraps it automatically mid-sentence, the visual line order and character joining break completely (the end of the sentence appears on the first line and the beginning on the second line).
3. **The Mixed-Token & Bracket Trap:** Naive whole-line BiDi reversal flips brackets (e.g. `(` becomes `)` and `[*] ` ends up at the far right) and reverses English terms or URLs embedded inside Persian sentences.

---

## 2. The Mandatory 4-Step Implementation Standard

Always use this exact pipeline—never rely on ad-hoc string reversal or automatic terminal wrapping:

1. **Wrap First at a Conservative Fixed Width (Default: `70` chars):**  
   Before reshaping or applying BiDi, split each paragraph into lines using `textwrap.wrap(paragraph, width=70)` (never rely on `shutil.get_terminal_size()`).
2. **Reshape Connected Glyphs Per Line:**  
   Pass each wrapped line to `arabic_reshaper.reshape(line)` or use the Unicode Arabic Presentation Forms-B mapping table so Persian letters connect properly.
3. **Apply BiDi Visual Ordering Per Line (With Token Segregation):**  
   Pass the reshaped line through BiDi ordering so RTL words appear in the correct visual order while keeping LTR tokens (English words, numbers, file paths) and status prefixes (`[*]`, `[OK]`, `[ERROR]`) in their natural position.
4. **Ensure Console UTF-8 Output Codepage:**  
   Ensure UTF-8 codepage is active via `chcp 65001 >nul` in Batch, or `ctypes.windll.kernel32.SetConsoleOutputCP(65001)` in Python.

---

## 3. Implementation A: Python Helper Module (Requires `arabic_reshaper` + `python-bidi`)

Use this helper when Python with `pip` access is available:

```python
import sys
import ctypes
import textwrap
import arabic_reshaper
from bidi.algorithm import get_display

def init_windows_persian_console() -> None:
    """تنظیم کدپیج کنسول ویندوز روی UTF-8 برای نمایش صحیح حروف فارسی."""
    if sys.platform == "win32":
        try:
            ctypes.windll.kernel32.SetConsoleOutputCP(65001)
            ctypes.windll.kernel32.SetConsoleCP(65001)
        except Exception:
            pass
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

def format_persian_console(text: str, width: int = 70) -> str:
    """
    شکستن متن فارسی روی عرض ثابت و محافظه‌کارانه (پیش‌فرض ۷۰ کاراکتر)
    پیش از اعمال reshape و bidi برای جلوگیری از شکستن ناخواسته خط توسط ترمینال ویندوز.
    """
    output_lines = []
    for raw_line in text.splitlines():
        if not raw_line.strip():
            output_lines.append("")
            continue
        wrapped_segments = textwrap.wrap(raw_line, width=width) or [raw_line]
        for segment in wrapped_segments:
            reshaped = arabic_reshaper.reshape(segment)
            visual_line = get_display(reshaped)
            output_lines.append(visual_line)
    return "\n".join(output_lines)

def print_fa(text: str, width: int = 70) -> None:
    """چاپ ایمن متن فارسی در ترمینال ویندوز."""
    print(format_persian_console(text, width=width))
```

---

## 4. Implementation B: Zero-Dependency Standalone Helper (Node.js / Vanilla JS)

Use this when Python/pip is unavailable, in Batch `.bat` launchers, or in projects where external pip/npm packages cannot be installed. It includes a built-in Unicode Presentation Forms-B reshaping table, word-level RTL reversal, and prefix/bracket protection:

```javascript
// print_fa.js - Zero-Dependency Persian Console Formatter
const CHAR_MAP = {
  '\u0622': ['\uFE81', '\uFE81', '\uFE82', '\uFE82'], // آ
  '\u0627': ['\uFE8D', '\uFE8D', '\uFE8E', '\uFE8E'], // ا
  '\u0628': ['\uFE8F', '\uFE91', '\uFE92', '\uFE90'], // ب
  '\u067E': ['\uFB56', '\uFB58', '\uFB59', '\uFB57'], // پ
  '\u062A': ['\uFE95', '\uFE97', '\uFE98', '\uFE96'], // ت
  '\u062B': ['\uFE99', '\uFE9B', '\uFE9C', '\uFE9A'], // ث
  '\u062C': ['\uFE9D', '\uFE9F', '\uFEA0', '\uFE9E'], // ج
  '\u0686': ['\uFB7A', '\uFB7C', '\uFB7D', '\uFB7B'], // چ
  '\u062D': ['\uFEA1', '\uFEA3', '\uFEA4', '\uFEA2'], // ح
  '\u062E': ['\uFEA5', '\uFEA7', '\uFEA8', '\uFEA6'], // خ
  '\u062F': ['\uFEA9', '\uFEA9', '\uFEAA', '\uFEAA'], // د
  '\u0630': ['\uFEAB', '\uFEAB', '\uFEAC', '\uFEAC'], // ذ
  '\u0631': ['\uFEAD', '\uFEAD', '\uFEAE', '\uFEAE'], // ر
  '\u0632': ['\uFEAF', '\uFEAF', '\uFEB0', '\uFEB0'], // ز
  '\u0688': ['\uFB8A', '\uFB8A', '\uFB8B', '\uFB8B'], // ژ
  '\u0633': ['\uFEB1', '\uFEB3', '\uFEB4', '\uFEB2'], // س
  '\u0634': ['\uFEB5', '\uFEB7', '\uFEB8', '\uFEB6'], // ش
  '\u0635': ['\uFEB9', '\uFEBB', '\uFEBC', '\uFEBA'], // ص
  '\u0636': ['\uFEBD', '\uFEBF', '\uFEC0', '\uFEBE'], // ض
  '\u0637': ['\uFEC1', '\uFEC3', '\uFEC4', '\uFEC2'], // ط
  '\u0638': ['\uFEC5', '\uFEC7', '\uFEC8', '\uFEC6'], // ظ
  '\u0639': ['\uFEC9', '\uFECB', '\uFECC', '\uFECA'], // ع
  '\u063A': ['\uFECD', '\uFECF', '\uFED0', '\uFECE'], // غ
  '\u0641': ['\uFED1', '\uFED3', '\uFED4', '\uFED2'], // ف
  '\u0642': ['\uFED5', '\uFED7', '\uFED8', '\uFED6'], // ق
  '\u06A9': ['\uFB8E', '\uFB90', '\uFB91', '\uFB8F'], // ک
  '\u0643': ['\uFED9', '\uFEDB', '\uFEDC', '\uFEDA'], // ك
  '\u06AF': ['\uFB92', '\uFB94', '\uFB95', '\uFB93'], // گ
  '\u0644': ['\uFEDD', '\uFEDF', '\uFEE0', '\uFEDE'], // ل
  '\u0645': ['\uFEE1', '\uFEE3', '\uFEE4', '\uFEE2'], // م
  '\u0646': ['\uFEE5', '\uFEE7', '\uFEE8', '\uFEE6'], // ن
  '\u0648': ['\uFEED', '\uFEED', '\uFEEE', '\uFEEE'], // و
  '\u0647': ['\uFEE9', '\uFEEB', '\uFEEC', '\uFEEA'], // ه
  '\u06CC': ['\uFBFC', '\uFBFE', '\uFBFF', '\uFBFD'], // ی
  '\u064A': ['\uFEF1', '\uFEF3', '\uFEF4', '\uFEF2'], // ي
  '\u0626': ['\uFE89', '\uFE8B', '\uFE8C', '\uFE8A'], // ئ
  '\u0629': ['\uFE93', '\uFE93', '\uFE94', '\uFE94'], // ة
};

const NON_CONNECTING = new Set(['\u0622', '\u0627', '\u062F', '\u0630', '\u0631', '\u0632', '\u0688', '\u0648']);

function isArabic(ch) { return CHAR_MAP.hasOwnProperty(ch); }

function reshapeWord(word) {
  let result = '';
  for (let i = 0; i < word.length; i++) {
    const ch = word[i];
    if (!isArabic(ch)) { result += ch; continue; }
    const prev = i > 0 ? word[i - 1] : null;
    const next = i < word.length - 1 ? word[i + 1] : null;
    const connectsPrev = prev && isArabic(prev) && !NON_CONNECTING.has(prev);
    const connectsNext = next && isArabic(next);
    const forms = CHAR_MAP[ch];
    let formIdx = 0;
    if (connectsPrev && connectsNext) formIdx = 2;
    else if (connectsPrev) formIdx = 3;
    else if (connectsNext) formIdx = 1;
    result += forms[formIdx];
  }
  return result;
}

function formatPersianForConsole(text) {
  let prefix = '';
  let body = text;
  // Preserve CLI indicator prefixes on the left
  const prefixMatch = body.match(/^(\[[*!+x\-]\]\s*|->\s*)/);
  if (prefixMatch) {
    prefix = prefixMatch[0];
    body = body.slice(prefix.length);
  }

  const words = body.split(' ');
  const shapedWords = [];

  for (const w of words) {
    if ((w.startsWith('(') && w.endsWith(')')) || /[a-zA-Z0-9_\-:\/.]/.test(w)) {
      shapedWords.push(w); // Keep LTR tokens intact
    } else {
      const shaped = reshapeWord(w);
      shapedWords.push(Array.from(shaped).reverse().join(''));
    }
  }

  shapedWords.reverse();
  return prefix + shapedWords.join(' ');
}

// CLI Execution: node print_fa.js "متن فارسی"
const input = process.argv.slice(2).join(' ');
if (input) process.stdout.write(formatPersianForConsole(input) + '\n');
```

### Usage in Windows Batch Scripts (`.bat` / `.cmd`):
```bat
@echo off
chcp 65001 >nul
set "PRINT_FA=node "tools\print_fa.js""

%PRINT_FA% "[*] بررسی و راه‌اندازی سرور داخلی رابط کاربری..."
%PRINT_FA% "[*] راه‌اندازی موتور هوشمند مانیتورها (MonitorEngine)..."
```
