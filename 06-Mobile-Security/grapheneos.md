# GrapheneOS (Planned)

| | |
| --- | --- |
| **Layer** | 6 · Mobile Security |
| **Status** | 🧭 Planned (choosing hardware) |
| **Threats addressed** | Malicious or over-permissioned apps, OS-level telemetry, mobile exploit chains |
| **MITRE ATT&CK (Mobile)** | [T1404](https://attack.mitre.org/techniques/T1404/) Exploitation for Privilege Escalation · [T1430](https://attack.mitre.org/techniques/T1430/) Location Tracking |
| **Last reviewed** | 2026-11-20 |

## Why

**GrapheneOS** is a non-profit, open-source, security-hardened operating system based on the Android Open Source Project (AOSP). It adds exploit mitigations and privacy controls that stock Android and iOS do not offer, without requiring Google services.

## Features I care about

- **Hardened memory allocator** (`hardened_malloc`) and additional exploit mitigations, which make memory-corruption bugs harder to exploit.
- **Network permission toggle per app:** an app can be denied internet access entirely.
- **Sensors permission toggle per app:** blocks access to sensors such as the accelerometer and gyroscope, beyond the usual camera, microphone, and location permissions.
- **Sandboxed Google Play (optional):** Google Play services can be installed as ordinary sandboxed apps with no special privileges, only in the profiles where I need them.
- **User profiles** to compartmentalize apps (for example, keeping one or two apps that need Google Play in a separate profile).
- **Auto-reboot after a period without unlocking,** which returns the phone to its most secure state (data encrypted at rest, before first unlock).

## The hardware decision

| Option | Pros | Cons |
| --- | --- | --- |
| **Google Pixel (now)** | The only officially supported hardware today; strong hardware security (Titan M2); long update support | Buying from Google, the company I am trying to step away from |
| **Motorola (later)** | Motorola announced a long-term partnership with the GrapheneOS Foundation at MWC in March 2026, including a future phone with GrapheneOS preinstalled | No device announced yet; reporting points to 2027 at the earliest; timeline uncertain |

My current leaning is to wait for the Motorola device if the timeline holds, and to fall back to a Pixel if it slips too far.

## Migration plan

1. Choose and buy the hardware.
2. Install GrapheneOS with the official **web installer**, then **relock the bootloader**, which is essential for verified boot.
3. Set up profiles: main profile without Google Play; separate profile(s) only if an app truly needs it.
4. Migrate TOTP secrets (see [Mobile 2FA](./mobile-2fa.md)).
5. Apply per-app Network and Sensors permissions with a default-deny mindset.

## How I will verify it

- The boot screen shows a **locked bootloader** with GrapheneOS's verified boot key.
- GrapheneOS's **Auditor** app, paired with a second device, performs hardware-backed attestation that the OS is genuine and unmodified.
- Network permission spot check: an app with Network denied cannot load content.

## Open questions

- Which banking apps work on GrapheneOS (some apps that rely on Play Integrity checks refuse to run on non-Google-certified OSes). This feeds directly into the [SIM isolation](./sim-isolation.md) plan.

## References

- [GrapheneOS](https://grapheneos.org/)
- [GrapheneOS features overview](https://grapheneos.org/features)
- [Motorola and GrapheneOS partnership coverage (Android Authority)](https://www.androidauthority.com/grapheneos-motorola-partnership-announced-3645710/)

---

[← Layer 6 overview](./README.md) · [Stack overview](../README.md)
