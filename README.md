# Antigravity Persian DevKit 🚀

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Antigravity](https://img.shields.io/badge/Google-Antigravity%20Plugin-4285F4.svg)](https://github.com/imalyzer/antigravity-persian-devkit)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Cross--Platform-lightgrey.svg)]()
[![Persian Support](https://img.shields.io/badge/Persian%2FArabic-RTL%20Supported-success.svg)]()

> **کیت ابزار مهندسی، قوانین پاسخ‌دهی بدون تعارف، و ۸ اسکیل تخصصی حل چالش‌های زبان فارسی و ویندوز برای Google Antigravity**  
> *A production-grade developer kit for Google Antigravity featuring zero-preamble engineering response policies, RTL console formatting, zero-mojibake Office VBA macros, and Windows development standards.*

---

## فهرست مطالب (Table of Contents)
- [چرا این کیت توسعه داده شد؟ (Motivation)](#چرا-این-کیت-توسعه-داده-شد-motivation)
- [ویژگی‌های کلیدی (Key Features)](#ویژگیهای-کلیدی-key-features)
- [فهرست اسکیل‌های ۸ گانه (The 8 Battle-Tested Skills)](#فهرست-اسکیلهای-۸-گانه-the-8-battle-tested-skills)
- [راهنمای نصب سریع (Installation)](#راهنمای-نصب-سریع-installation)
- [نحوه کارکرد فنی (Architecture)](#نحوه-کارکرد-فنی-architecture)
- [مشارکت و لایسنس (License)](#مشارکت-و-لایسنس-license)

---

## چرا این کیت توسعه داده شد؟ (Motivation)

مدل‌های پیشرفته هوش مصنوعی (Gemini، Claude، GPT) در پروژه‌های فارسی و کار با سیستم‌عامل ویندوز دچار **خطاهای تکراری و پرهزینه‌ای** می‌شوند:
- متن فارسی در ترمینال ویندوز را با کتابخانه‌های عادی برعکس یا شکسته چاپ می‌کنند.
- ماکروهای VBA اکسل را با حروف فارسی ذخیره کرده و باعث تبدیل کلمات به علامت‌سوال (`???`) یا خطاهای عجیبی مثل Error 5844 می‌شوند.
- اسکریپت‌های ویندوز (`.bat`) را با خطوط یونیکس (`\n`) ذخیره کرده که باعث اجرا نشدن آن‌ها در ویندوز می‌شود.
- در چت‌ها پرگویی کرده، تعارفات بی‌مورد نثار می‌کنند و به جای تست ریشه‌ای، عیب را گردن آنتی‌ویروس می‌اندازند!

**Antigravity Persian DevKit** این تجربیات گران‌بها را در قالب یک **پلاگین رسمی، سبک و مبتنی بر Progressive Disclosure** بسته‌بندی کرده تا هوش مصنوعی شما از دور اول چت، این خطاهای تاریخی را تکرار نکند.

---

## ویژگی‌های کلیدی (Key Features)

1. **مصرف توکن صفر در حالت عادی (Progressive Disclosure):**  
   اسکیل‌ها در ابتدای چت به پنجره زمینه (Context Window) تحمیل نمی‌شوند. فقط عنوان و شرط فراخوانی آنها بارگذاری می‌شود و محتوای اصلی تنها زمانی که مستقیماً مربوط به سوال شما باشد خوانده خواهد شد.
2. **سیاست پاسخ‌گویی مهندسی و بدون تعارف (Zero-Preamble Response Policy):**  
   هوش مصنوعی بدون احوال‌پرسی یا مقدمه‌چینی، مستقیماً سراغ سازوکار فنی و پاسخ ساختاری می‌رود و فرضیات را از داده‌های اندازه‌گیری‌شده جدا می‌کند.
3. **قانون حاکمیت ابزارها (`AGENT_GUIDE.md`):**  
   هوش مصنوعی موظف است هر اسکریپت یا اتوماسیونی که برای شما می‌سازد را در پوشه اختصاصی ماژولار کند و برای ایجنت‌های آینده یک مستند فنی انگلیسی (`AGENT_GUIDE.md`) بسازد تا در آینده توکن هدر نرود.

---

## فهرست اسکیل‌های ۸ گانه (The 8 Battle-Tested Skills)

| اسکیل | شناسه فنی | معضل حل‌شده |
| :--- | :--- | :--- |
| **۱. هدایت فنی پروژه** | `skill-01-technical-project-and-architecture` | **فیلتر لجنزار تخصصی (Specialist Swamp Filter):** رد راه‌حل‌های بیش‌از‌حد پیچیده؛ اگر راه‌حل ساده بیش از ۹۰٪ نیاز را پوشش دهد، فورا انتخاب می‌شود. تفکیک مکانیزم از هدف. |
| **۲. ارکستراسیون چندعاملی CoALA** | `skill-02-multi-agent-orchestration-coala` | خط‌لوله ۳ لایه (معمار / ارکستراتور / مجری) و قرارداد ۴ بخشی برای توسعه پروژه‌های سنگین با هوش مصنوعی. |
| **۳. استاندارد بچ‌فایل‌های ویندوز** | `skill-03-windows-batch-and-crlf-encoding` | تضمین پایان خطوط `CRLF` (`\r\n`)، کدپیج `chcp 65001`، متغیر `PYTHONUTF8=1` و متغیرهای تاخیری `!var!`. |
| **۴. نمایش فارسی در ترمینال ویندوز** | `skill-04-windows-terminal-persian-rtl` | حل باگ بافر کنسول ویندوز با فرمول طلایی: **پیش‌شکست متن با `textwrap.wrap(width=70)` قبل از `reshape` و `bidi`**. |
| **۵. ماکروهای VBA فارسی در آفیس** | `skill-05-vba-persian-macro-guidelines` | جلوگیری قطعی از علامت‌سوال شدن حروف در اکسل و ورد با کدهای هگز `ChrW(&Hxxxx)` و تابع `U()`، دایرکشن `wdReadingOrderRtl` و فونت `Font.NameBi`. |
| **۶. عیب‌یابی ارورهای ناگهانی** | `skill-06-sudden-app-error-troubleshooting` | پروتکل ۷ مرحله‌ای ریشه‌یابی و ممنوعیت زدن حدس‌های فرضی و کلیشه‌ای (آنتی‌ویروس/دیفندر/وان‌درایو). |
| **۷. توسعه پلاگین ابسیدین با CM6** | `skill-07-obsidian-and-cm6-development` | رعایت معماری رندر مجازی CodeMirror 6 و جلوگیری از شکستن رندر با تزریق دستی تگ‌های HTML. |
| **۸. تنظیمات مدل‌های محلی و پراکسی** | `skill-08-local-llm-proxy-and-translation` | پارامترهای بهینه Gemma در LM Studio (`Repeat Penalty=1.0` و `Min P=0.0`)، افزونه‌های کیوتنسلیت و پایپ‌لاین STT فارسی. |

---

## راهنمای نصب سریع (Installation)

### روش ۱: نصب خودکار در ویندوز (توصیه‌شده - ۳۰ ثانیه)
1. این ریپازیتوری را دانلود کنید یا با گیت کلون نمایید:
   ```bash
   git clone https://github.com/imalyzer/antigravity-persian-devkit.git
   ```
2. وارد پوشه شده و روی فایل **`install.bat`** دابل‌کلیک کنید.  
   *(اسکریپت به صورت خودکار پوشه پلاگین را در `~/.gemini/config/plugins/` مستقر و در تنظیمات آنتی‌گرویتی ثبت می‌کند).*
3. برنامه Antigravity را باز کنید؛ تمام ۸ اسکیل و قوانین فعال هستند!

### روش ۲: نصب با پاورشل (PowerShell)
```powershell
cd antigravity-persian-devkit
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

### روش ۳: نصب دستی (Cross-Platform)
کافی است پوشه `plugin` را در آدرس زیر کپی کرده و نام آن را به `antigravity-persian-devkit` تغییر دهید:
- در ویندوز: `%USERPROFILE%\.gemini\config\plugins\antigravity-persian-devkit`
- در لینوکس / مک: `~/.gemini/config/plugins/antigravity-persian-devkit`

سپس در فایل `config.json` موجود در `~/.gemini/config/`، این مقدار را اضافه کنید:
```json
{
  "plugins": {
    "antigravity-persian-devkit": {}
  }
}
```

---

## نحوه حذف (Uninstallation)
برای حذف، کافی است فایل `uninstall.bat` را اجرا کنید.

---

## مشارکت و توسعه (Contributing)
اگر تجربه یا تکنیک ارزشمندی در زمینه تعامل با هوش مصنوعی، زبان فارسی، ویندوز یا توسعه ابزار دارید:
1. یک برنچ جدید بسازید.
2. اسکیل جدید خود را در `plugin/skills/<skill-name>/SKILL.md` اضافه کنید.
3. در تابلوی `plugin/rules/AGENTS.md` آن را ثبت کنید.
4. پول‌ریکوئست (Pull Request) ارسال نمایید!

---

## لایسنس (License)
این پروژه تحت لایسنس **MIT** به صورت کاملاً آزاد و متن‌باز برای تمام توسعه‌دهندگان ایرانی منتشر شده است.

**ساخته‌شده با ❤️ توسط [imalyzer](https://github.com/imalyzer)**
