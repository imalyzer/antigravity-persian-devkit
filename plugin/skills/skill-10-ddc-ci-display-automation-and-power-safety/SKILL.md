---
name: skill-10-ddc-ci-display-automation-and-power-safety
description: DDC/CI hardware display control, I2C bus timing debouncing, Windows session shutdown hooks (WM_ENDSESSION), pre-login boot rescue tasks, and WASAPI non-admin video/media keep-awake.
---

# SKILL 10: DDC/CI Display Automation, I2C Bus Timing & OS Power State Safety

> **File Path:** `02_Skills/SKILL_10_DDC_CI_Display_Automation_and_Power_Safety.md`  
> **Trigger:** Whenever automating physical monitors via software/DDC/CI, controlling brightness/contrast/power via VCP, preventing monitor sleep during video/audio without fragile title matching, or solving dark screens on reboot/crash.  
> **Source:** `Monitor Controller` Production Engineering & Architecture.

---

## 1. The Core Architecture & DDC/CI VCP Standards

Controlling physical monitors programmatically uses the **DDC/CI (Display Data Channel Command Interface)** protocol over the display cable's I2C bus (VGA, DVI, HDMI, DisplayPort).

### Standard VCP Control Codes
- **Power State (`VCP 0xD6`):**
  - `1`: Power On (Full active panel)
  - `5`: Power Off / Deep Standby (Panel dark, logic in ultra-low power)
- **Contrast (`VCP 0x12`):** Range `0` to `100` (Used for instant blackout before standby).
- **Brightness (`VCP 0x10`):** Range `0` to `100`.

---

## 2. Hard-Won Technical Gotchas & Critical Rules

### Gotcha 1: The I2C Bus Timing & Standby Lockup Trap
* **The Symptom:** After putting a monitor into sleep (`D6 5`), sending an immediate wake command (`D6 1`) fails, or the monitor completely ignores software commands until physically unplugged or power-cycled.
* **The Root Cause:** When a monitor panel enters deep standby, its onboard scaler/DDC microcontroller powers down or drops its I2C clock rate. Attempting to communicate before the internal power state settles causes an I2C bus lockup.
* **The Mandatory Rule:**
  1. **Enforce Wake Debounce Delay (`WakeMinWaitSec`):** Never send a wake command within `3` to `12` seconds of sending a sleep command. If activity occurs within this window, buffer it as `WakePending` and execute once the timer expires.
  2. **Multi-Pulse Wake Strategy:** Always send wake pulses in a burst of `3` retries with `1000ms` intervals (`D6 1` -> wait 1000ms -> `D6 1` -> wait 1000ms -> `D6 1`).
  3. **Contrast Restoration Timing:** Send the default contrast restore command `400ms - 500ms` *after* the first `D6 1` pulse, followed by a final ensure pulse after the wake burst finishes.

---

### Gotcha 2: The Reboot / Power Cut Dark Screen Trap (Pre-Login Lockout)
* **The Symptom:** If monitors are put to sleep via software (`D6 5`), and the PC subsequently restarts, crashes, or suffers a sudden power cut, upon powering back on the monitors remain completely dark. The user cannot see the Windows login screen or enter their password.
* **The Root Cause:** Software automation scripts located in the user's Startup folder (`shell:startup`) only execute **after the user logs in**. At the Windows Lock / Login screen (Session 0), user-level scripts are not running yet!
* **The Dual Fail-Safe Standard:**
  1. **Graceful Shutdown Intercept:** In the automation engine, register Windows session messages `0x11` (`WM_QUERYENDSESSION`) and `0x16` (`WM_ENDSESSION`). Prior to Windows shutting down, restarting, or logging off, synchronously issue `D6 1` and restore default contrast to all monitors before processes terminate.
  2. **Pre-Login Task Scheduler Fallback (`At system startup`):** Create a Windows Scheduled Task with:
     - Principal: `NT AUTHORITY\SYSTEM` (Runs in Session 0 before any user logon).
     - Trigger: `At startup` (`<BootTrigger>`).
     - Action: Fires `ControlMyMonitor.exe /SetValue Primary D6 1` and `Secondary D6 1`.
     - *Result:* Even after an abrupt power outage, Windows executes this task immediately upon kernel initialization, ensuring the password/login screen is visible.

---

### Gotcha 3: The Video & Media Detection Trap (Title Matching Failure)
* **The Symptom:** Users watching movies, educational courses, Twitch, or web streams find their monitors going to sleep because title keywords don't match or the video player is embedded.
* **The Solution — Triple-Layered Protection Pipeline:**
  1. **WASAPI Audio Session Peak Meter (Primary):** Query Windows Core Audio (`IMMDeviceEnumerator` -> `IAudioMeterInformation::GetPeakValue()`). If peak >= `0.001`, active audio is rendering on the default endpoint. This works without admin rights, consumes 0% CPU, and catches 100% of audible video playback regardless of browser or app.
  2. **Whitelisted Fullscreen Detection (For Silent/Muted Media):** Check if any window on that specific monitor matches the monitor's coordinate bounding box borderless AND belongs to a user-configured whitelist (`vlc.exe`, `chrome.exe`, `mpv.exe`, `potplayer.exe`). If active, pause idle timers for that display.
  3. **Process & Title Keyword Fallback:** Retain as an auxiliary safeguard for known media editors (e.g. Cubase, OBS) or background players.

---

## 3. Dynamic Multi-Monitor Discovery (PowerShell Standard)

Never hardcode monitor geometries into source code. Use this discovery pipeline to extract EDID model names, display indices, and virtual desktop coordinates into JSON:

```powershell
Add-Type -AssemblyName System.Windows.Forms
$screens = [System.Windows.Forms.Screen]::AllScreens

$wmiMonitors = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorID -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject]@{
        Model = (($_.UserFriendlyName | Where-Object { $_ -ne 0 }) | ForEach-Object { [char]$_ }) -join ""
    }
}

$results = foreach ($s in $screens) {
    [PSCustomObject]@{
        Name    = $s.DeviceName
        Primary = $s.Primary
        Target  = if ($s.Primary) { "Primary" } else { "Secondary" }
        Bounds  = @{
            Left   = $s.Bounds.X
            Top    = $s.Bounds.Y
            Right  = $s.Bounds.X + $s.Bounds.Width - 1
            Bottom = $s.Bounds.Y + $s.Bounds.Height - 1
        }
    }
}
$results | ConvertTo-Json -Depth 4
```
