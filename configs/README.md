# Reference Configurations

Sanitized configuration files that back up the documentation. They are **references, not drop-in installers**: read each file and adapt it to your own hardware and threat model before using it.

| File | Installs to | Documented in |
| --- | --- | --- |
| [`sysctl/total-hardening.conf`](./sysctl/total-hardening.conf) | `/etc/sysctl.d/total-hardening.conf` | [Sysctl Kernel Hardening](../02-Operating-System/sysctl-hardening.md) |
| [`usbguard/usbguard-daemon.conf.excerpt`](./usbguard/usbguard-daemon.conf.excerpt) | Merge into `/etc/usbguard/usbguard-daemon.conf` | [USBGuard](../01-Physical-Security/usbguard.md) |
| [`usbguard/rules.conf.example`](./usbguard/rules.conf.example) | Structure example only (generate your own) | [USBGuard](../01-Physical-Security/usbguard.md) |
| [`xmrig/config.example.json`](./xmrig/config.example.json) | XMRig's `config.json` (relevant keys only) | [P2P Exchanges and Self-Mining](../05-Financial-Privacy/p2p-exchanges.md) |

## What has been removed

Device serial numbers, USB device hashes, wallet addresses, pool credentials, and anything else that could identify my hardware or me have been replaced with placeholders such as `<VENDOR_ID>` or `YOUR_XMR_ADDRESS`.

## Conventions

- Settings that are **active** on my system are uncommented.
- Settings that are **not applied** are commented out and labeled as reference only.

---

[← Stack overview](../README.md)
