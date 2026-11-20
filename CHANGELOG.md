# Changelog

All notable changes to this documentation are recorded here. Dates are in `YYYY-MM-DD` format.

## [2.0.0] - 2026-11-20

A full professional revision of the repository.

### Added

- `THREAT-MODEL.md`: assets, in-scope and out-of-scope adversaries, assumptions, a threat-to-control matrix mapped to MITRE ATT&CK, and a ranked list of residual risks.
- `GLOSSARY.md`: definitions for the terms used across the docs.
- `scripts/verify-stack.sh`: a read-only audit script that checks the documented controls on a live system.
- `scripts/check_links.py` and GitHub Actions CI (ShellCheck, markdownlint, internal link check, JSON validation).
- `configs/`: sanitized reference configs for sysctl, USBGuard, and XMRig.
- A consistent template for every control page: header table, verification, trade-offs, **limitations and residual risk**, and references.
- Layer 6 (Mobile) planning documents for GrapheneOS, SIM isolation, and mobile 2FA, which were previously empty.
- Mermaid architecture diagrams in the main README and each layer README.

### Changed (technical corrections)

- **linux-hardened** is in Arch's official repositories, not the AUR.
- **lm_sensors** is in the official repositories, not the AUR.
- **Coreboot** is described as firmware, not a bootloader; noted that Dasharo still includes some Intel binary components.
- **Intel ME** is described as part of the chipset (PCH) and as "Ring -3"; `me_cleaner` described as firmware modification; verification steps corrected for Dasharo, which hides the MEI interface when the ME is disabled.
- **LUKS:** clarified the volume-key/keyslot design and Argon2id; corrected the quantum-computing note (AES-256 stays secure); documented suspend and evil-maid limitations; reconciled "memorized only" with the sealed paper backup.
- **USBGuard:** described as a userspace daemon using kernel USB authorization; fixed the broken recovery rule syntax; warned that the HID recovery rule re-opens BadUSB; added a GRUB-based recovery path; corrected `allow-device` scope.
- **Btrfs:** "copy-on-write," not "copy-to-write"; subvolume separation is about rollback scope, not least privilege; replaced "roll back after root compromise" with a correct incident-response approach.
- **AppArmor:** documented that unprofiled applications run unconfined; added `aa-unconfined`.
- **Sysctl:** corrected `ptrace_scope` debugging trade-offs; warned about overriding stricter kernel defaults.
- **Tor:** "obfs4" (not "obs4") and Snowflake described correctly; updated window-size advice for letterboxing.
- **Extensions:** Privacy Badger's local learning has been off by default since 2020; JShelter uses farbling, not uniformity; Port Authority blocks port scans and ThreatMetrix rather than acting as an IDS; Privacy Redirect is unmaintained (LibRedirect is its successor).
- **Vaultwarden:** "LAN-only" rather than "air-gapped," which removes a contradiction with LAN syncing; documented that snapshots are not off-device backups.
- **Passphrase math:** corrected the 60-character "heat death of the universe" claim (≈10¹⁸ years, not longer than heat death); added offline/online and KDF context; noted that uniqueness, not length, is what defeats credential stuffing.
- **Biometrics:** updated with the 2024–2025 circuit split (*Payne*, 9th Cir. vs. *Brown*, D.C. Cir.); added a not-legal-advice note.
- **Monero:** a ring of 16 is 1 real output and 15 decoys; Bulletproofs+; key images; FCMP++ status updated to November 2026; added delisting and regulatory trade-offs.
- **XMRig:** HTTP API is disabled and localhost-bound by default; huge pages need root-reserved memory when running unprivileged; P2Pool mentioned; US tax note added.
- **Tails:** described as isolation and a "warm wallet" rather than an air gap or cold storage; noted the 2024 merger with the Tor Project.
- **Faraday bag:** reframed around phones (Find My while powered off) and RF isolation vs. air gap; periodic re-testing.
- Removed informal asides and fixed grammar and spelling throughout; fixed broken relative links (for example `tor-browser.d/`).

## [1.0.0] - 2026-10-30

- Initial publication: six layers (Physical, Operating System, Network, Identity, Financial, Mobile), with Mobile as a work in progress.
