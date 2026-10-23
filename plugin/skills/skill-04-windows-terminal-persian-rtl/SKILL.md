---
name: skill-04-windows-terminal-persian-rtl
description: Tested method for rendering connected, properly ordered Persian/Arabic (RTL) text in Windows Terminal, CMD, and PowerShell using fixed-width pre-wrapping before arabic_reshaper and python-bidi.
---

# SKILL 04: Displaying Persian / RTL Text in Windows Terminal & Console Apps

> **File Path:** `skills/SKILL_04_Windows_Terminal_Persian_RTL.md`  
> **Trigger:** Whenever building a CLI tool, terminal UI, progress logger, or console script on Windows that outputs Persian or Arabic (RTL) text.  
> **Source:** `سیستم پرامپت هدایت فنی پروژه.md` (§5).

---

## 1. The Core Problem in Windows Consoles

In Windows console hosts (`cmd.exe`, Windows PowerShell, and even Windows Terminal):
1. Characters are rendered left-to-right in isolated form unless reshaped and reordered via the Unicode Bidirectional Algorithm.
2. **The Buffer-Width Trap:** Calling `shutil.get_terminal_size()` on Windows frequently returns the console **buffer width** rather than the actual visible window width, or returns an inaccurate column count. If a reshaped/bidi-reversed Persian string exceeds the visible window width and the terminal wraps it automatically mid-sentence, the visual line order and character joining break completely (the end of the sentence appears on the first line and the beginning on the second line).

---

## 2. The Mandatory 4-Step Implementation Standard

Always use this exact pipeline—never rely on ad-hoc string reversal or automatic terminal wrapping:

1. **Wrap First at a Conservative Fixed Width (Default: `70` chars):**  
   Before reshaping or applying BiDi, split each paragraph into lines using `textwrap.wrap(paragraph, width=70)` (never rely on `shutil.get_terminal_size()`).
2. **Reshape Connected Glyphs Per Line:**  
   Pass each wrapped line to `arabic_reshaper.reshape(line)` so Persian letters connect properly.
3. **Apply BiDi Visual Ordering Per Line:**  
   Pass the reshaped line to `bidi.algorithm.get_display(reshaped_line)` so RTL words and embedded LTR numbers/English terms appear in the correct visual order.
4. **Ensure Console UTF-8 Output Codepage:**  
   When launching from Python (including `.pyz` zipapps), ensure UTF-8 output is active via `ctypes.windll.kernel32.SetConsoleOutputCP(65001)` and `sys.stdout.reconfigure(encoding='utf-8')`.

---

## 3. Ready-to-Use Python Helper Module

Include this helper in any Windows CLI script that prints Persian text:

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
        # گام ۱: شکستن خط پیش از reshape بر اساس عرض ثابت
        wrapped_segments = textwrap.wrap(raw_line, width=width) or [raw_line]
        for segment in wrapped_segments:
            # گام ۲ و ۳: چسباندن حروف و اصلاح جهت نمایش برای هر خط جداگانه
            reshaped = arabic_reshaper.reshape(segment)
            visual_line = get_display(reshaped)
            output_lines.append(visual_line)
    return "\n".join(output_lines)

def print_fa(text: str, width: int = 70) -> None:
    """چاپ ایمن متن فارسی در ترمینال ویندوز."""
    print(format_persian_console(text, width=width))
```
