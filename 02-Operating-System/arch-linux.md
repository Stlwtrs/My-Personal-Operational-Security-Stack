# Arch Linux

| | |
| --- | --- |
| **Layer** | 2 · Operating System |
| **Status** | ✅ Implemented |
| **Threats mitigated** | Unnecessary services and packages (attack surface), bundled telemetry, slow security patching |
| **MITRE ATT&CK** | [T1068](https://attack.mitre.org/techniques/T1068/) Exploitation for Privilege Escalation (fewer vulnerable components) · [T1195](https://attack.mitre.org/techniques/T1195/) Supply Chain Compromise (see limitations) |
| **Last reviewed** | 2026-11-20 |

## Why this control exists

Many mainstream distributions ship with hundreds of preinstalled packages and enabled background services that a given user may never touch. Every one of them is potential attack surface: if a vulnerability is found in a service you did not even know was running, you are exposed without realizing it.

I chose **Arch Linux** because it follows a "nothing you did not ask for" philosophy. A base install is deliberately minimal, and you build the system up yourself.

## How it works

- **Reduced attack surface.** If I do not need a Bluetooth daemon, a print server, or a mail agent, they are never installed in the first place.
- **Full visibility.** I know what is on the system because I put it there.
- **No telemetry by default.** Arch ships no data collection. The only usage-statistics tool, `pkgstats`, is opt-in.
- **Rolling release.** Security fixes and new kernels usually reach me within days of an upstream release, instead of waiting for the next point release of a fixed-release distribution.
- **The AUR.** The Arch User Repository gives me build scripts (`PKGBUILD`s) for niche security tools I use in school and in my own projects. I can read a `PKGBUILD` before building it.

## My implementation

- Minimal base install, built up package by package.
- Official repositories by default; AUR packages only when there is no alternative, and only after reading the `PKGBUILD`.
- Arch News is checked before every full system upgrade (`sudo pacman -Syu`).

## Verification

```bash
# Count explicitly installed packages (keep this number small and explainable)
pacman -Qe | wc -l

# List foreign (AUR / manually installed) packages, which are the ones to scrutinize
pacman -Qm

# Services enabled at boot
systemctl list-unit-files --state=enabled

# Anything listening on the network
sudo ss -tulpn

# Installed packages with known published vulnerabilities (package: arch-audit)
arch-audit
```

## Trade-offs

- **Maintenance.** Arch expects attention. Some updates need manual steps, which are announced on Arch News, so I read it before upgrading.
- **Regressions.** Rolling release means I get new bugs as quickly as I get new fixes.
- **The learning curve.** With root access to everything, it is easy to break the system. My first install is a good example: I messed up the partition table and ended up with 64 GB usable out of a 4 TB SSD. Arch is not a beginner distribution, and you will make mistakes the first time. Treat them as part of the learning.

## Limitations and residual risk

- **The AUR is not vetted.** AUR packages are user-submitted, and "you can audit it" only helps if you actually do. This risk is real: in July 2025, malicious AUR packages named to look like legitimate browser packages (for example `firefox-patch-bin` and `librewolf-fix-bin`) installed the CHAOS remote access trojan and stayed up for about two days before Arch removed them. My rules: read every `PKGBUILD` and `.install` script, be suspicious of new or renamed `-bin` packages, and prefer official repository packages.
- **Minimal is not the same as hardened.** A minimal install reduces what can go wrong; the rest of this layer covers hardening what remains.

## Verdict

Arch is not for Linux beginners, but for anyone who wants a transparent, minimal, and fast-patching operating system, it is hard to beat (short of suffering through Linux From Scratch).

## References

- [Arch Linux](https://archlinux.org/)
- [ArchWiki: Security](https://wiki.archlinux.org/title/Security)
- [ArchWiki: Arch User Repository](https://wiki.archlinux.org/title/Arch_User_Repository)
- [aur-general: malicious packages announcement (July 2025)](https://lists.archlinux.org/archives/list/aur-general@lists.archlinux.org/thread/7EZTJXLIAQLARQNTMEW2HBWZYE626IFJ)

---

[← Layer 2 overview](./README.md) · [Stack overview](../README.md)
