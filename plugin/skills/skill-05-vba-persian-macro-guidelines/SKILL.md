---
name: skill-05-vba-persian-macro-guidelines
description: Mandatory rules for writing, editing, and debugging Microsoft Office VBA macros (Word, Excel, Access, PowerPoint) with Persian/Arabic text—preventing VBE mojibake, compile errors on .Bidi, and runtime error 5844 on Font.NameFarEast.
---

# SKILL 05: Office VBA Macro Guidelines for Persian / RTL Users

> **File Path:** `skills/SKILL_05_VBA_Persian_Macro_Guidelines.md`  
> **Trigger:** Whenever writing, modifying, or debugging any VBA macro (`.bas`, `.vba`, Word, Excel, Access, PowerPoint) involving Persian/Arabic text, RTL layout, or Persian fonts.  
> **Source:** `vba-persian-macro-guidelines.md`.

---

## Rule 1 (Most Important): NEVER Type Raw Persian/Arabic Characters Inside VBA Source Code

- **Scope:** All VBA hosts (Word, Excel, Access, PowerPoint).
- **Why:** The VBA Editor (VBE) does **not** support Unicode; it interprets source files using the Windows ANSI System Locale codepage. Any Persian string or comment typed directly inside `""` or after `'` can turn into unreadable mojibake, even if the `.bas` file was saved as UTF-8.
- **Mandatory Solution:**
  1. Keep **100% of `.bas` source code and comments in plain ASCII / English** (this is the sole exception to the general Persian-comments rule).
  2. Construct all Persian/Arabic runtime strings using `ChrW(&Hxxxx)` or the `U(hexCodes)` helper function below:

```vb
' Helper function: converts space-separated hex codes into a Unicode string at runtime
Function U(hexCodes As String) As String
    Dim parts() As String, i As Long
    parts = Split(Trim(hexCodes), " ")
    For i = 0 To UBound(parts)
        If parts(i) <> "" Then U = U & ChrW("&H" & parts(i))
    Next i
End Function

' Example usage ("سلام دنیا"):
Dim s As String
s = U("633 644 627 645") & " " & U("62F 646 6CC 627")
```

### Ready Reference Table: Persian Unicode Hex Codes (Without `&H`)

| Char | Hex | Char | Hex | Char | Hex | Char | Hex |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| آ | `622` | د | `62F` | ط | `637` | گ | `6AF` |
| ا | `627` | ذ | `630` | ظ | `638` | ل | `644` |
| ب | `628` | ر | `631` | ع | `639` | م | `645` |
| پ | `67E` | ز | `632` | غ | `63A` | ن | `646` |
| ت | `62A` | ژ | `698` | ف | `641` | و | `648` |
| ث | `62B` | س | `633` | ق | `642` | ه | `647` |
| ج | `62C` | ش | `634` | ک | `6A9` | ی | `6CC` |
| چ | `686` | ص | `635` | ہ / ة | `6C1` / `629` | ئ / ء | `626` / `621` |
| ح | `62D` | ض | `636` | خ | `62E` | نیم‌فاصله (ZWNJ) | `200C` |

- **Persian Digits (`۰`–`۹`):** `6F0` to `6F9` (in order).
- **Arabic-Indic Digits (`٠`–`٩`):** `660` to `669`.
- **Persian Punctuation:** Guillemets `«` = `AB`, `»` = `BB` | Question `؟` = `61F` | Comma `،` = `60C` | Semicolon `؛` = `61B`.

---

## Rule 2: Word RTL Direction — NEVER Use `.Bidi`

- **Scope:** Microsoft Word VBA.
- **Why:** `ParagraphFormat.Bidi` does **not** exist in the Word VBA object model and throws Compile Error: `"Method or data member not found"`.
- **Mandatory Solution:** Use `ReadingOrder` and `Alignment`:

```vb
rng.ParagraphFormat.ReadingOrder = wdReadingOrderRtl   ' (or wdReadingOrderLtr)
rng.ParagraphFormat.Alignment = wdAlignParagraphRight  ' (or wdAlignParagraphLeft)
```

---

## Rule 3: Word Persian Font Assignment — Set `Font.NameBi`, NEVER `Font.NameFarEast`

- **Scope:** Microsoft Word VBA.
- **Why:** Word's `Font` object separates scripts into `.Name` (Latin), `.NameFarEast` (East Asian CJK), and `.NameBi` (Bidirectional RTL: Persian/Arabic/Hebrew). Assigning certain fonts to `.NameFarEast` throws **Runtime Error 5844** (`"One of the values passed to this method or property is incorrect"`) and fails to change the visible Persian font.
- **Mandatory Solution:** Always set both `.Name` and `.NameBi`:

```vb
rng.Font.Name = fontName
rng.Font.NameBi = fontName
```

---

## Rule 4: Guard `FontNames` Loops with Per-Item Error Handling

Not every installed font in `Application.FontNames` accepts every property cleanly. Wrap font assignments inside loops so one problematic font does not abort the macro, and count skipped items to report at completion:

```vb
On Error Resume Next
rng.Font.Name = fontName
rng.Font.NameBi = fontName
If Err.Number <> 0 Then
    skippedCount = skippedCount + 1
    Err.Clear
End If
On Error GoTo 0
```

---

## Rule 5: Normalize Persian/Arabic Digits Before Validating `InputBox` Numbers

Because the user's keyboard locale is often Persian, typing `۱۲۳` into an `InputBox` can cause `IsNumeric` or `CInt` to misbehave. Always normalize digits to Latin ASCII (`0`–`9`) before checking `IsNumeric` and range bounds:

```vb
Function NormalizeDigits(s As String) As String
    Dim i As Long, c As Long
    For i = 1 To Len(s)
        c = AscW(Mid(s, i, 1))
        If c >= &H6F0 And c <= &H6F9 Then
            NormalizeDigits = NormalizeDigits & Chr(48 + (c - &H6F0))
        ElseIf c >= &H660 And c <= &H669 Then
            NormalizeDigits = NormalizeDigits & Chr(48 + (c - &H660))
        Else
            NormalizeDigits = NormalizeDigits & Mid(s, i, 1)
        End If
    Next i
End Function
```

---

## Rule 6: General VBA Delivery Hygiene

1. **Output Complete `Sub`/`Function` Blocks on Edits:** VBE has no convenient partial diff patching; always provide the complete updated `Sub` or module.
2. **Protect Existing Document Content:** Never include `doc.Content.Delete` unless the user explicitly asked to wipe the active document.
3. **Visual Verification:** After any RTL/font macro change, verify the rendered output via screenshot or PDF export rather than assuming code inspection suffices.
