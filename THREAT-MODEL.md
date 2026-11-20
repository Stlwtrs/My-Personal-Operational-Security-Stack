# Threat Model

**Version:** 2.0 · **Last reviewed:** 2026-11-20 · **Owner:** [@Stlwtrs](https://github.com/Stlwtrs)

This document defines **what** I am protecting, **from whom**, and **under which assumptions**. Every control in this repository traces back to a threat listed here. If a control does not map to a threat, it does not belong in the stack.

---

## 1. Scope

- **In scope:** my primary laptop, my phone, my self-hosted password vault, my Tails USB, my online accounts, and my cryptocurrency holdings.
- **Perspective:** an individual (not an organization) with a **Tier 2** threat model, meaning capable but untargeted adversaries.

## 2. Assets

| ID | Asset | Why it matters | Primary layer |
| --- | --- | --- | --- |
| A1 | Data at rest on my laptop (documents, SSH keys, vault cache) | Confidentiality if the device is lost or stolen | 01, 02 |
| A2 | Master secrets (LUKS passphrase, vault master password, phone passcode) | Each unlocks everything beneath it | 04 |
| A3 | Password vault (Vaultwarden) | Holds every other credential | 04 |
| A4 | Online accounts (email, GitHub, banking) | Account takeover means impersonation and financial loss | 04, 06 |
| A5 | Browsing and network metadata | Reveals interests, habits, and associations | 03 |
| A6 | Cryptocurrency wallet keys and transaction history | Theft is irreversible; history exposure reveals finances | 05 |
| A7 | Phone number | Recovery channel for many accounts (SIM-swap target) | 06 |
| A8 | Physical devices and their availability | Loss of availability is a security failure too | 01, 02 |

## 3. Adversaries

### In scope (Tier 2)

| ID | Adversary | Capabilities | Motivation |
| --- | --- | --- | --- |
| T1 | **ISP / passive network observer** | Sees all traffic metadata on my connection; may log and sell it | Monetization, compliance |
| T2 | **Data brokers and ad-tech** | Cross-site tracking, fingerprinting, purchasing data | Profiling, monetization |
| T3 | **Opportunistic remote attacker** | Phishing, malvertising, credential stuffing, commodity malware, malicious packages | Financial gain |
| T4 | **Opportunistic physical attacker** | Theft; a few minutes of access to an unattended device; plugging in USB devices | Resale, data theft |
| T5 | **Shoulder surfer** | Observes screen and keyboard in public | Credential theft |
| T6 | **SIM swapper** | Social-engineers a carrier into moving my number | Account takeover, crypto theft |
| T7 | **Centralized-service breach** | Breach of a cloud provider or exchange holding my data | Bulk data theft |

### Out of scope

| Adversary / attack | Why it is excluded |
| --- | --- |
| Nation-state actors targeting me specifically | Defending against them requires resources and trade-offs beyond a personal setup |
| Hardware supply-chain interdiction | Requires control over shipping or manufacturing |
| TEMPEST / electromagnetic emanations | Requires specialized equipment and proximity |
| Advanced firmware or hardware implants | Partially mitigated by open firmware, but not a design goal |
| Global passive adversary (Tor correlation) | Tor's own threat model does not claim to defend against this |
| Sustained physical coercion ("rubber-hose") | No technical control reliably addresses it; the no-biometrics policy only helps at the margin |

## 4. Assumptions

1. Hardware and firmware were **not tampered with before delivery**.
2. I do not run untrusted code as root, and I read AUR `PKGBUILD`s before building them.
3. I keep systems updated (rolling release, timely browser updates).
4. Upstream cryptographic primitives (AES-256, Argon2id, Curve25519/Ed25519, Monero's protocol) are sound.
5. My memorized secrets are not observed while being typed (see T5 mitigations).
6. Devices are **shut down**, not suspended, when they leave my control for extended periods.

If any assumption breaks, the corresponding residual risks below grow.

## 5. Threat-to-control matrix

| Threat scenario | Adversary | MITRE ATT&CK | Controls | Residual risk |
| --- | --- | --- | --- | --- |
| Laptop stolen while powered off | T4 | [T1005](https://attack.mitre.org/techniques/T1005/) | [LUKS2](./01-Physical-Security/luks-encryption.md), [passphrase strategy](./04-Identity-Credentials/passphrase-strategy.md) | Low |
| Laptop stolen while suspended | T4 | [T1005](https://attack.mitre.org/techniques/T1005/) | Screen lock; policy: shut down when leaving it unattended | **Medium:** key is in RAM |
| BadUSB keystroke injection | T4 | [T1200](https://attack.mitre.org/techniques/T1200/), [T1059](https://attack.mitre.org/techniques/T1059/) | [USBGuard](./01-Physical-Security/usbguard.md) | Low–Medium: device-ID spoofing |
| Data exfiltration to a USB drive | T4 | [T1052.001](https://attack.mitre.org/techniques/T1052/001/) | [USBGuard](./01-Physical-Security/usbguard.md), screen lock | Low |
| Boot-chain tampering (evil maid) | T4 | [T1542](https://attack.mitre.org/techniques/T1542/) | [Dasharo firmware](./01-Physical-Security/hardware-selection.md), [ME HAP](./01-Physical-Security/intel-me-hap.md) | **Medium:** verified/measured boot not yet in place |
| Passphrase observed in public | T5 | — | [Privacy screen](./01-Physical-Security/privacy-screen.md), shielding the keyboard | Low–Medium |
| Camera or microphone hijacking | T3 | [T1125](https://attack.mitre.org/techniques/T1125/), [T1123](https://attack.mitre.org/techniques/T1123/) | Hardware [physically removed](./01-Physical-Security/hardware-selection.md) | Very low |
| Local privilege escalation | T3 | [T1068](https://attack.mitre.org/techniques/T1068/) | [linux-hardened](./02-Operating-System/linux-hardened.md), [sysctl](./02-Operating-System/sysctl-hardening.md), [minimal Arch](./02-Operating-System/arch-linux.md) | Low–Medium |
| Process injection via ptrace | T3 | [T1055.008](https://attack.mitre.org/techniques/T1055/008/) | [`ptrace_scope=1`](./02-Operating-System/sysctl-hardening.md) | Low |
| Exploited app reads my keys and documents | T3 | [T1005](https://attack.mitre.org/techniques/T1005/), [T1552.004](https://attack.mitre.org/techniques/T1552/004/) | [AppArmor](./02-Operating-System/apparmor-selinux.md) | **Medium:** unprofiled apps run unconfined |
| Malicious AUR package | T3 | [T1195](https://attack.mitre.org/techniques/T1195/) | `PKGBUILD` review, official repositories preferred ([Arch](./02-Operating-System/arch-linux.md)) | Medium |
| Ransomware (unprivileged user) | T3 | [T1486](https://attack.mitre.org/techniques/T1486/) | [Btrfs snapshots](./02-Operating-System/btrfs-snapshots.md) | **Medium:** no off-device backup yet |
| Ransomware / attacker with root deletes snapshots | T3 | [T1490](https://attack.mitre.org/techniques/T1490/) | Rebuild-and-restore incident response | **High** until offline backups exist |
| ISP logs and sells browsing history | T1 | [T1040](https://attack.mitre.org/techniques/T1040/) | [Mullvad VPN](./03-Network-Privacy/vpn.md) with encrypted DNS | Low (trust moves to Mullvad) |
| Traffic analysis of encrypted tunnel | T1 | — | DAITA, Multihop ([VPN](./03-Network-Privacy/vpn.md)) | Low–Medium |
| On-path attacker on public Wi-Fi | T3 | [T1557](https://attack.mitre.org/techniques/T1557/) | VPN, HTTPS | Low |
| Cross-site tracking and fingerprinting | T2 | — | [Mullvad Browser](./03-Network-Privacy/mullvad-browser.md), [extensions](./03-Network-Privacy/privacy-extensions.md), [Tor](./03-Network-Privacy/tor-browser.md) | Medium: IceCat profile is distinctive |
| Drive-by exploit / malvertising | T3 | [T1189](https://attack.mitre.org/techniques/T1189/) | [LibreJS](./03-Network-Privacy/icecat-librejs.md), uBlock Origin, Tor *Safest* | Low–Medium |
| Credential phishing | T3 | [T1566](https://attack.mitre.org/techniques/T1566/) | Domain-matched autofill, LibreJS "broken page" tell, FIDO2 (planned) | **Medium** until FIDO2 everywhere |
| Credential stuffing | T3 | [T1110.004](https://attack.mitre.org/techniques/T1110/004/) | Unique, random password per account ([vault](./04-Identity-Credentials/password-manager.md)) | Very low |
| Offline password cracking after a breach | T3, T7 | [T1110.002](https://attack.mitre.org/techniques/T1110/002/) | 48–60 char random passwords; strong KDFs | Very low |
| Cloud password-manager breach | T7 | [T1555.005](https://attack.mitre.org/techniques/T1555/005/) | [Self-hosted, LAN-only vault](./04-Identity-Credentials/password-manager.md) | Low |
| Keylogger captures master password | T3 | [T1056.001](https://attack.mitre.org/techniques/T1056/001/) | OS hardening; wallet only on [Tails](./05-Financial-Privacy/tails-usb.md) | Medium |
| Coerced biometric unlock | T4 | [T1461](https://attack.mitre.org/techniques/T1461/) | [No biometrics](./04-Identity-Credentials/biometrics.md) | Low |
| SIM swap → SMS 2FA takeover | T6 | [T1451](https://attack.mitre.org/techniques/T1451/), [T1111](https://attack.mitre.org/techniques/T1111/) | Planned: [SIM isolation](./06-Mobile-Security/sim-isolation.md), [FIDO2/TOTP](./06-Mobile-Security/mobile-2fa.md) | **High** for SMS-only accounts |
| Blockchain analysis links funds to identity | T2, T7 | — | [Monero](./05-Financial-Privacy/crypto.md), [no-KYC acquisition](./05-Financial-Privacy/p2p-exchanges.md) | Low–Medium (behavioral leaks) |
| Exchange breach exposes KYC data | T7 | — | Avoid KYC exchanges ([P2P](./05-Financial-Privacy/p2p-exchanges.md)) | Low |
| Wallet key theft by daily-OS malware | T3 | [T1005](https://attack.mitre.org/techniques/T1005/), [T1014](https://attack.mitre.org/techniques/T1014/) | [Tails](./05-Financial-Privacy/tails-usb.md) | Low–Medium (same hardware, warm wallet) |
| Phone tracked while stored | T1, T2 | [T1430](https://attack.mitre.org/techniques/T1430/) | [Faraday bag](./01-Physical-Security/faraday-bag.md) | Low while bagged |

**Residual risk scale:** Very low → Low → Medium → High. These ratings reflect my judgment of likelihood × impact *after* controls, for my threat model.

## 6. Top residual risks (what I would fix next)

1. **No off-device backups.** Snapshots and the vault database live on single drives, which leaves them exposed to hardware failure and to root-level attackers ([T1490](https://attack.mitre.org/techniques/T1490/)). → *Offline NAS on the roadmap.*
2. **SMS 2FA on legacy financial accounts.** → *SIM isolation and FIDO2 migration (Layer 6).*
3. **Evil-maid / boot integrity.** → *Evaluate Secure Boot with my own keys, or Dasharo's Heads variant.*
4. **Unconfined applications.** → *Grow AppArmor profile coverage, tracked with `aa-unconfined`.*
5. **Suspended-laptop exposure.** → *Habit: full shutdown whenever the device leaves my control.*

## 7. Review cadence

This model is reviewed:

- when a new control is added or removed,
- when my circumstances change (new device, new job, travel),
- after any security incident or near miss,
- and at least once per semester.

---

[← Stack overview](./README.md)
