---
name: skill-09-chromium-electron-data-extraction
description: Rules, performance guardrails, and V8 Structured Clone deserialization techniques for extracting accounts, tokens, and storage data from Chromium and Electron applications (IndexedDB, LevelDB, Local Storage).
---

# SKILL 09: Chromium & Electron Data Extraction & V8 Serialization Gotchas

> **File Path:** `02_Skills/SKILL_09_Chromium_Electron_Data_Extraction.md`  
> **Trigger:** Whenever extracting accounts, auth tokens, session data, or chat histories from Chromium or Electron applications (Claude Desktop, VS Code, Discord, Slack, Spotify, Obsidian, Notion, Chrome, Edge).  
> **Origin:** Hard-won technical debugging of V8 Structured Clone string compression in Claude Desktop multi-instance accounts.

---

## 1. Electron / Chromium Storage Architecture

Desktop applications built on Chromium/Electron store application state across several distinct subsystems in their profile directory (`%APPDATA%\<AppName>`):

1. **`Network\Cookies`**: SQLite database containing encrypted session cookies (DPAPI on Windows, Keychain on macOS).
2. **`Local Storage\leveldb\`**: Fast key-value store for web tokens, flags, and UI states.
3. **`IndexedDB\*.indexeddb.blob\` & `*.indexeddb.leveldb\`**: Primary client-side database for rich objects, conversation trees, and full account profiles.
4. **`Partitions\<partition-name>\`**: Isolated webview partitions (e.g. `cowork-file-preview`, `launch-preview`) containing independent `Local Storage` and `IndexedDB` instances.

---

## 2. The Core Gotcha: V8 Structured Clone Compression

Chromium's V8 JavaScript engine does **NOT** serialize objects to plain JSON or raw UTF-8 text inside IndexedDB. Instead, it uses the **V8 Structured Clone Algorithm (`v8::ValueSerializer`)**.

### The Failure Mode (Why Naive Regex Fails):
When V8 writes repeated strings or common domain substrings (such as `mail` in `gmail.com`), it applies internal dictionary compression and inserts binary token control bytes:

```text
Actual on-disk bytes:
b'email_address"\x16wandad.music@g\x01\x1c\x90.com"'
```
- `\x16`: String length (22 decimal = len("wandad.music@gmail.com")).
- `\x01\x1c\x90`: 3-byte internal V8 dictionary token referencing the string `mail`.

> [!CAUTION]
> **The Naive Regex Trap:**  
> A standard regex like `[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+` will **silently fail** because `\x01\x1c\x90` are non-ASCII characters.

### The Fallback Trap (Garbage Token Extraction):
When an agent's regex fails on the primary profile blob, naive fallback logic often scans `Session Storage` or temporary LevelDB files. It will inevitably encounter random binary tokens or hash fragments (such as `g2@K.F`) that happen to match `X@Y.Z` syntax, resulting in **false-positive account reporting**.

---

## 3. The 3-Rule Extraction Protocol

### Rule 1: Targeted Key-First Discovery (Never Blindly Regex Whole Files)
Rather than searching for arbitrary email or token regexes across megabytes of binary data, first locate the **explicit schema key** (e.g., `b'email_address"'`, `b'"account"'`, `b'"user_id"'`):

```python
import re

def extract_v8_email_from_blob(data: bytes) -> str | None:
    idx = 0
    while True:
        idx = data.find(b'email_address', idx)
        if idx == -1:
            break
        # Grab the immediate chunk following the key
        chunk = data[idx:idx + 80]
        m = re.search(rb'([a-zA-Z0-9_.+-]+)@([^\x22\x09\r\n]+)', chunk)
        if m:
            user = m.group(1).decode('utf-8', errors='ignore')
            domain_raw = m.group(2)
            
            # Resolve V8 compressed domain tokens
            if b'com' in domain_raw and domain_raw.startswith(b'g'):
                return f"{user}@gmail.com"
            elif b'com' in domain_raw and domain_raw.startswith(b'o'):
                return f"{user}@outlook.com"
            elif b'me' in domain_raw and domain_raw.startswith(b'p'):
                return f"{user}@proton.me"
            else:
                domain_clean = re.sub(rb'[^a-zA-Z0-9.-]', b'', domain_raw).decode('utf-8', errors='ignore')
                candidate = f"{user}@{domain_clean}"
                if is_strict_valid_email(candidate):
                    return candidate
        idx += 1
    return None
```

### Rule 2: Strict Email Validation Guardrails
Never accept a candidate string as an email unless it passes strict structural validation:
1. **TLD Length:** The Top-Level Domain (after the last dot) must be at least 2 **pure alphabetical** characters (e.g., `.com`, `.org`, `.me`, `.ir`). Single-character TLDs like `.F` are 100% binary noise.
2. **SLD Length:** The Second-Level Domain must be at least 2 characters (e.g., `gmail`, `outlook`). Single-letter domains like `K.` in `g2@K.F` are binary noise.

```python
def is_strict_valid_email(email_str: str) -> bool:
    if not email_str or '@' not in email_str:
        return False
    parts = email_str.split('@')
    if len(parts) != 2:
        return False
    user, domain = parts
    if len(user) < 2 or len(domain) < 4 or '.' not in domain:
        return False
    
    tld = domain.split('.')[-1]
    if len(tld) < 2 or not tld.isalpha():
        return False
        
    sld = domain.split('.')[0]
    if len(sld) < 2:
        return False
        
    return True
```

### Rule 3: Mandatory Directory Exclusion List
Chromium profiles accumulate tens of thousands of binary blocks in caches. **NEVER** recursively scan these directories:
* `Cache` / `Cache_Data`
* `Code Cache` (Compiled JS and WASM blocks)
* `GPUCache` / `DawnGraphiteCache` / `DawnWebGPUCache`
* `node_modules`
* `blob_storage`

Target **only**:
* `IndexedDB\*.indexeddb.blob\` (Highest fidelity for structured state)
* `IndexedDB\*.indexeddb.leveldb\` (Metadata and log deltas)
* `Local Storage\leveldb\` (Fast web storage)
* `Partitions\*\IndexedDB\` and `Partitions\*\Local Storage\`
