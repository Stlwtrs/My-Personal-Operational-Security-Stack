# USBGuard

| | |
| --- | --- |
| **Layer** | 1 · Physical Security |
| **Status** | ✅ Implemented |
| **Threats mitigated** | BadUSB keystroke injection, malicious USB hardware, unauthorized data exfiltration over USB |
| **MITRE ATT&CK** | [T1200](https://attack.mitre.org/techniques/T1200/) Hardware Additions · [T1059](https://attack.mitre.org/techniques/T1059/) Command and Scripting Interpreter · [T1052.001](https://attack.mitre.org/techniques/T1052/001/) Exfiltration over USB |
| **Last reviewed** | 2026-11-20 |

## Why this control exists

By default, Linux, Windows, and macOS trust any USB device that is plugged in. An attacker with a few seconds of physical access to an **unlocked** machine can plug in a device that looks like a flash drive but identifies itself as a keyboard (a **BadUSB** or "rubber ducky" device). It then types a pre-written script at superhuman speed: open a terminal, download a payload, execute it.

**USBGuard** stops this by enforcing a USB allow list. It is a userspace daemon that uses the Linux kernel's USB device authorization feature: new devices start out *unauthorized*, so their drivers do not bind, until USBGuard checks them against its policy. If a device's attributes (vendor ID, product ID, serial number, interface types, port, and so on) do not match an allow rule, it stays blocked.

## My implementation

| Setting | Value |
| --- | --- |
| Default policy | Block (`ImplicitPolicyTarget=block`) |
| Allow list | My keyboard, touchpad, mouse, and hardware security key only |
| Rules file | `/etc/usbguard/rules.conf`, owned by root, mode `0600` |
| Reference config | [`configs/usbguard/`](../configs/usbguard/) (sanitized example) |

The baseline policy was generated from the devices I trust, and anything that does not match it is blocked. Only `root` can read or change the rules, so an intruder who learns where the rules live still has to escalate privileges before they can tamper with them.

## Setting it up safely

**Warning:** if you enable USBGuard before generating a baseline policy, it will block everything, including a USB keyboard and mouse, and you can lock yourself out at the login screen.

```bash
# 1. Generate a policy from the devices currently connected (plug in everything you trust first)
sudo sh -c 'usbguard generate-policy > /etc/usbguard/rules.conf'
sudo chmod 0600 /etc/usbguard/rules.conf

# 2. Review the generated rules before enabling anything
sudo cat /etc/usbguard/rules.conf

# 3. Enable and start the daemon
sudo systemctl enable --now usbguard.service
```

## Daily usage

When I plug in a new device, such as my Tails USB or an external SSD, it is silently blocked. To use it:

```bash
# Find the blocked device and its ID
sudo usbguard list-devices --blocked

# Allow it for this connection only (re-blocked when unplugged or when the daemon restarts)
sudo usbguard allow-device <id>

# Or allow it permanently by appending a rule to the policy
sudo usbguard allow-device -p <id>
```

## Recovery if you lock yourself out

On many laptops the built-in keyboard and touchpad are connected over PS/2 (i8042) or I²C rather than USB, and USBGuard only governs USB. Check with `lsusb`: if your built-in keyboard is not listed there, USBGuard cannot lock it out.

If you do get locked out:

1. **Fastest option:** at the GRUB menu (GRUB runs before Linux, so USBGuard is not active yet), press `e` on the boot entry and add `systemd.mask=usbguard.service` to the kernel command line. Boot, fix the policy, and reboot normally.
2. **Fallback:** boot a live USB (Arch, Ubuntu, etc.), unlock and mount the root filesystem, and edit `/etc/usbguard/rules.conf`.

A temporary rule that allows any keyboard or mouse looks like this:

```text
allow with-interface one-of { 03:00:01 03:01:01 03:00:02 03:01:02 }
```

These values are USB **interface** codes in the form `class:subclass:protocol`. Class `03` is HID (Human Interface Device), and protocols `01` and `02` are keyboard and mouse.

**Remove this rule as soon as you have regenerated a proper policy.** A rule that allows any keyboard also allows a BadUSB device, because to the computer a BadUSB device *is* a keyboard. Leaving it in place silently defeats the whole control.

## Verification

```bash
systemctl is-active usbguard              # should print "active"
sudo usbguard list-rules                  # the allow list currently loaded
sudo usbguard list-devices                # every device and whether it is allowed or blocked
stat -c '%a %U' /etc/usbguard/rules.conf  # should print "600 root"
```

## Trade-offs

- **Friction.** If a friend hands me a flash drive, it does not just work. I have to open a terminal, find the device ID, and authorize it. Since I rarely plug in unknown devices, this is not a real hassle for me.

## Limitations and residual risk

- **Device identity can be spoofed.** A sophisticated malicious device can copy the vendor ID, product ID, and even the serial number of a device on my allow list. Rules that also match `via-port` (the physical port) and `with-interface` make impersonation harder, but no USB allow list is absolute.
- **USB is not the only peripheral path.** Thunderbolt/USB4 devices are capable of DMA and are governed separately (by the IOMMU and `bolt` on Linux).
- **An unlocked, unattended machine is still a compromise.** USBGuard narrows one path; locking the screen every time I walk away is still mandatory.

## Verdict

Ten seconds of friction to authorize a new device is infinitely better than the risk of someone plugging a BadUSB into my laptop and injecting a payload. It is a rare attack, but the control costs me almost nothing day to day.

## References

- [USBGuard project](https://usbguard.github.io/)
- [USBGuard rule language](https://usbguard.github.io/documentation/rule-language.html)
- [ArchWiki: USBGuard](https://wiki.archlinux.org/title/USBGuard)

---

[← Layer 1 overview](./README.md) · [Stack overview](../README.md)
