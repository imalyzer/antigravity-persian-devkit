---
name: skill-14-vm-gateway-vpn-and-leak-prevention
description: VM-based transparent VPN gateway routing, physical adapter bridging loops, fail-closed kill-switch via active default route removal, WebRTC/STUN leak elimination, Windows ICS COM reset, and headless encrypted VM automation.
---

# SKILL 14: VM Gateway VPN Routing, WebRTC/STUN Leak Prevention & Hypervisor Isolation

> **File Path:** `D:\Projects\Iman Sheybani\software\Antigravity\02_Skills\SKILL_14_VM_Gateway_VPN_and_Leak_Prevention.md`  
> **Trigger:** Whenever routing a host OS transparently through a VPN running inside a virtual machine (VMware/VirtualBox/Hyper-V), preventing WebRTC/STUN IP leaks, resolving hypervisor bridge loops (Hyper-V Default Switch conflicts), automating Windows Internet Connection Sharing (ICS), hardening Windows routing table persistence (`-PolicyStore ActiveStore`), or orchestrating headless encrypted VMs via `vmrun`.  
> **Source:** `VPN VMware` Host-to-VM Gateway Engineering & Leak-Proof Architecture.

---

## 1. The Metric-Only Kill Switch Illusion & WebRTC Egress Leaks

### The Anti-Pattern
A common network engineering assumption is that pushing the physical NIC metric to a high value (e.g., 500) and setting the virtual host-only adapter gateway to a low metric (e.g., 5) guarantees that 100% of host traffic flows through the VM:
```cmd
:: INSUFFICIENT KILL-SWITCH:
netsh interface ipv4 set interface "Ethernet" metric=500
netsh interface ipv4 set interface "VMware Network Adapter VMnet1" metric=5
```

### The Architectural Reality
* **Metric Only Governs Unbound Sockets:** Routing metrics only dictate the route chosen when a socket does *not* bind to a specific local interface address.
* **The WebRTC / Explicit Binding Egress Vector:** WebRTC implementations in Chromium/Firefox, peer-to-peer applications, and STUN clients enumerate all local network interfaces and explicitly bind UDP sockets to each interface's local IP (e.g., `192.168.0.x` on the physical NIC).
* **The Leak:** When a socket binds to the physical interface IP, the OS network stack selects that interface's default gateway *regardless of how high its metric is*. In empirical testing (`stun-leak-test.ps1`), STUN queries sent from the physical NIC IP successfully reached the internet through the home router, leaking the ISP public IP in plaintext while the VPN was active!

### The Standard Solution: Active Default Route Removal
To achieve a genuine, leak-proof **fail-closed (Kill-Switch)** state, the system must actively delete all physical and Wi-Fi default routes (`0.0.0.0/0`) from the active routing table while the route is ON:

```powershell
# In vm-route-defaults.ps1 (ON phase):
# Save existing physical default routes and actively purge them:
$routes = @(Get-NetRoute -AddressFamily IPv4 -DestinationPrefix '0.0.0.0/0' |
    Where-Object { $_.InterfaceAlias -ne $KeepVirtualAdapter -and $_.NextHop -ne '0.0.0.0' })

$routes | Export-Csv -Path $StateFile -NoTypeInformation

foreach ($r in $routes) {
    Remove-NetRoute -InterfaceAlias $r.InterfaceAlias -DestinationPrefix '0.0.0.0/0' `
        -NextHop $r.NextHop -PolicyStore ActiveStore -Confirm:$false
}
```
* **Result:** With no default route existing on the physical adapter, sockets bound to that adapter receive `Destination host unreachable` / socket errors instead of egressing to the ISP. Sockets are forced to fail-closed.
* **Reversibility:** When toggling OFF, restore the saved routes strictly from `$StateFile`.

---

## 2. Windows Route Persistence Poisoning: `ActiveStore` vs. `PersistentStore`

### The Trap
When adding or restoring routes in PowerShell via `New-NetRoute` without explicitly declaring the `-PolicyStore`, Windows defaults to writing routes into **both** the active volatile table and the non-volatile registry store (`PersistentStore`):
```powershell
# DANGEROUS: Writes to registry! Survives reboot and overrides DHCP!
New-NetRoute -InterfaceAlias "Ethernet" -DestinationPrefix "0.0.0.0/0" -NextHop "192.168.0.1" -RouteMetric 500
```
### The Consequence
The modified metric or custom gateway persists across PC reboots. If the user moves to another network (different subnet/DHCP gateway), the persistent route remains stuck, breaking normal internet connectivity indefinitely.

### The Rule
Whenever dynamically manipulating routing tables in scripts or automation, **ALWAYS** specify `-PolicyStore ActiveStore`:
```powershell
# SAFE: Pure RAM operation; vanishes cleanly on reboot or network reset
New-NetRoute -InterfaceAlias $r.InterfaceAlias -DestinationPrefix '0.0.0.0/0' `
    -NextHop $r.NextHop -RouteMetric ([int]$r.RouteMetric) -PolicyStore ActiveStore -ErrorAction Stop

Remove-NetRoute -InterfaceAlias $r.InterfaceAlias -DestinationPrefix '0.0.0.0/0' `
    -NextHop $r.NextHop -PolicyStore ActiveStore -Confirm:$false
```

---

## 3. Hyper-V Default Switch Bridge Hijacking & Routing Loops

### The Trap: Automatic Bridging Collision
When VMware Workstation is configured with `VMnet0` on **Automatic Bridging**, it scans all network interfaces on the host. If Windows Hyper-V, WSL2, or a third-party TAP adapter (e.g., Betternet) is installed, VMware frequently binds `VMnet0` to `vEthernet (Default Switch)`.

### The Catastrophic Failure: Outward Packet Loop
1. The VM's outward interface (`Ethernet0`) gets an internal IP from Hyper-V (`172.20.x.x` / `mshome.net`) instead of the physical router (`192.168.0.x`).
2. The VM's outer VPN tunnel packets are NAT'd by the host's Hyper-V virtual switch.
3. The moment the host switches its default route to point to the VM gateway (`192.168.137.1`), the VM's outward encrypted tunnel packets leaving the host stack are forwarded **back into the VM**.
4. Result: Immediate routing loop, complete loss of internet, and frozen tunnel handshakes.

### The Standard Fix: Explicit Bridge Unbinding (`fix-bridge.ps1`)
Unbind the `VMware Bridge Protocol` (`vmware_bridge`) from all virtual, TAP, and secondary adapters, pinning it strictly to the physical Ethernet NIC:
```powershell
# Disable VMware Bridge on all virtual adapters:
$virtualAdapters = @("vEthernet (Default Switch)", "Wi-Fi", "Betternet Network Adapter")
foreach ($name in $virtualAdapters) {
    Disable-NetAdapterBinding -Name $name -ComponentID vmware_bridge -ErrorAction SilentlyContinue
}
# Verify physical adapter remains bound:
Enable-NetAdapterBinding -Name "Ethernet" -ComponentID vmware_bridge
```

---

## 4. Windows ICS (Internet Connection Sharing) Fragility & Programmatic COM Reset

### The Problem
Windows Internet Connection Sharing (`SharedAccess`) is notoriously fragile:
* Whenever the upstream VPN tunnel adapter is re-created, disconnected, or changes IP, `SharedAccess` silently stops forwarding or its service enters the `Stopped` state.
* **The Silent Disconnect:** The downstream private adapter (`Ethernet1`) retains its static IP (`192.168.137.1`), creating the illusion that routing is active. However, all forwarded packets from the host receive `Destination net unreachable`.

### The Solution: Automated COM Reset (`HNetCfg.HNetShare`)
Restarting the service alone does not fix the internal bindings. You must programmatically re-bind ICS using the native Windows COM interface inside the VM:

```powershell
# vm-side-ics-reset.ps1 (Run inside Guest as Administrator)
param(
    [string]$PublicName  = 'WindscribeWireguard',
    [string]$PrivateName = 'Ethernet1'
)

regsvr32 /s hnetcfg.dll
$share = New-Object -ComObject HNetCfg.HNetShare
$all = @()
foreach ($c in $share.EnumEveryConnection) {
    $all += [pscustomobject]@{ Name = $share.NetConnectionProps($c).Name; Conn = $c }
}

# 1. Disable sharing everywhere first
foreach ($e in $all) {
    try { $share.INetSharingConfigurationForINetConnection($e.Conn).DisableSharing() } catch { }
}
Start-Sleep -Seconds 1

# 2. Re-enable: 0 = Public (Internet Egress), 1 = Private (Shared Subnet)
$pub = $all | Where-Object { $_.Name -eq $PublicName } | Select-Object -First 1
$prv = $all | Where-Object { $_.Name -eq $PrivateName } | Select-Object -First 1

$share.INetSharingConfigurationForINetConnection($pub.Conn).EnableSharing(0)
$share.INetSharingConfigurationForINetConnection($prv.Conn).EnableSharing(1)
```

---

## 5. Timing Hazards, Duplicate Address Detection (DAD) & ICMP Traps

### Asynchronous Adapter Initialization
When enabling a network interface (`netsh interface set interface ... admin=enabled`), Windows requires 3–10 seconds for Duplicate Address Detection (DAD). During this window, the IP state is `Tentative`. Firing connection probes immediately causes false negatives.
* **Fix:** Poll `Get-NetIPAddress` until `AddressState -eq 'Preferred'` before attempting routing:
```powershell
$timeout = 25
while ($timeout -gt 0) {
    $ip = Get-NetIPAddress -InterfaceAlias $AdapterName -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object { $_.IPAddress -eq $HostIP -and $_.AddressState -eq 'Preferred' }
    if ($ip) { break }
    Start-Sleep -Seconds 1
    $timeout--
}
```

### The ICMP Echo False Negative Trap
* Windows ICS drops inbound ICMP echo (ping) requests by default.
* Testing whether the VM gateway is alive with `ping 192.168.137.1` will show 100% packet loss even when HTTP/TCP forwarding is working flawlessly!
* **Rule:** Never validate gateway forwarding with `ping`. Use HTTP probes (`curl.exe -s -o nul -w "%{http_code}" --max-time 8 http://1.1.1.1`) via a temporary static route.

---

## 6. Headless Encrypted VM Automation via `vmrun`

When orchestrating background VMs (`nogui`) with VMware Workstation:

1. **Encrypted VM Password Parameter:** If the VM is encrypted, any `vmrun` invocation without `-vp <password>` will hang indefinitely waiting for interactive console input.
2. **Explicit Stdin Closure:** Scripts calling `vmrun.exe` programmatically must close Standard Input (`$psi.RedirectStandardInput = $true; $p.StandardInput.Close()`) and enforce hard process timeouts (`$p.WaitForExit(40000)`).
3. **Non-Empty Guest Password Requirement:** VMware Tools explicitly rejects empty guest passwords (`"The guest OS does not support empty passwords"`). Guest automation accounts must have a non-empty password, combined with Windows `AutoAdminLogon` in the guest registry.
4. **Session 0 vs. Console Session 1 Barrier:** Commands executed via `vmrun ... runProgramInGuest` run in **Session 0 (Non-Interactive)**. Any CLI tool that interacts with a running user GUI app (such as `windscribe-cli`) will hang or fail because the GUI runs in Console Session 1.
   * **Rule:** Do not attempt to toggle GUI VPNs via CLI across session boundaries. Configure the GUI to **Auto-Connect on Startup** in Session 1, and monitor its state from Session 0 by inspecting log files (`client.log`) and virtual adapter states (`Get-NetAdapter`).

---

## 7. DPI Handshake Filtering & Protocol Junk Packets (Iran Censorship)

* **The Problem:** Standard WireGuard and OpenVPN handshakes have fixed, well-known packet signatures. In highly filtered network environments (e.g., Iranian national internet gateways), DPI firewalls drop WireGuard handshake packets on all standard ports (53, 443, 51820).
* **The Solution:** Use Amnezia WireGuard protocol obfuscation (Protocol Tweaks) with randomized prefix junk packets (e.g., `J - Iran Junk Packets`) routed over UDP Port 53.
* **Telemetry Verification:** Do not rely on third-party IP reflection APIs like `api.ipify.org` (which return HTTP 520/403 or CDN edge IPs under Iranian ISP routing). Always verify public IP telemetry using Cloudflare trace:
```cmd
curl.exe -4 -s --max-time 10 https://www.cloudflare.com/cdn-cgi/trace | findstr /b "ip="
```
