# Glossary

Terms used across this repository, defined the way they are used here.

| Term | Definition |
| --- | --- |
| **Air gap** | A system with **no** network connection of any kind (wired, wireless, or Bluetooth). Data moves only on physical media. Not the same as "LAN-only" or "RF-shielded while stored." |
| **AMT (Active Management Technology)** | Intel's out-of-band remote-management feature, hosted on the Management Engine. Present on vPro platforms. |
| **AppArmor** | A Linux Security Module that enforces per-program, path-based access-control profiles (a form of MAC). |
| **Argon2id** | A memory-hard key derivation function; the default PBKDF for LUKS2 keyslots. It makes each password guess expensive. |
| **Attack surface** | The sum of all points where an attacker could try to get in or extract data. Smaller is better. |
| **BadUSB** | A malicious USB device that impersonates a trusted device class, typically a keyboard, to inject commands. |
| **Compartmentalization** | Separating activities, identities, or data so that a compromise of one does not spread to the others. |
| **Copy-on-write (CoW)** | A filesystem technique that writes modified data to new blocks instead of overwriting old ones; it enables cheap snapshots in Btrfs. |
| **coreboot / Dasharo** | Open-source firmware that initializes hardware and hands off to a payload. Dasharo is a coreboot-based firmware distribution with a UEFI payload, used by NovaCustom. |
| **DAC / MAC** | Discretionary vs. Mandatory Access Control. DAC lets owners set permissions; MAC enforces a system-wide policy that programs cannot override. |
| **DAITA** | Mullvad's *Defense Against AI-guided Traffic Analysis:* constant packet sizes, cover traffic, and pattern distortion. |
| **Dandelion++** | Monero's transaction-propagation protocol, which hides the originating node's IP address. |
| **Defense in depth** | Layering independent controls so that no single failure leads to compromise. |
| **Evil-maid attack** | Tampering with an unattended device (typically the boot chain) so that it captures secrets the next time it is used. |
| **FCMP++** | *Full-Chain Membership Proofs:* a planned Monero upgrade that replaces 16-member rings with the entire output set as the anonymity set. Not on mainnet as of November 2026. |
| **FIDO2 / WebAuthn** | Phishing-resistant authentication using public-key cryptography bound to the site's origin (hardware keys, passkeys). |
| **Fingerprinting** | Identifying a browser or device by combining many observable attributes, without cookies. |
| **Farbling** | Anti-fingerprinting by randomizing values slightly per site and per session (used by Brave and JShelter). |
| **HAP (High Assurance Platform) bit** | A firmware flag that halts the Intel ME shortly after platform initialization. |
| **Key derivation function (KDF)** | Turns a password into a cryptographic key, usually slowly on purpose (PBKDF2, Argon2id). |
| **KYC (Know Your Customer)** | Identity-verification requirements imposed on regulated financial services and exchanges. |
| **LUKS2** | Linux Unified Key Setup, version 2: the standard on-disk format for Linux full-disk encryption. |
| **Multihop** | Routing VPN traffic through two servers so that no single server sees both the source and the destination. |
| **Pedersen commitment** | A cryptographic commitment that hides a value while still allowing the network to verify sums; used for Monero amounts. |
| **Residual risk** | The risk that remains after controls are applied. |
| **Ring -3** | Informal name for the privilege level of the Intel ME, below the OS kernel (Ring 0), the hypervisor (-1), and SMM (-2). |
| **Ring signature** | A signature proving that one member of a group signed, without revealing which one; used for Monero's sender privacy. |
| **RingCT** | Ring Confidential Transactions: Monero's scheme for hiding amounts. |
| **Snapshot vs. backup** | A snapshot is a point-in-time view on the **same** storage; a backup is a copy on **separate** storage. Only a backup survives drive failure. |
| **Stealth address** | A one-time output address derived for each Monero payment, so payments to the same recipient cannot be linked. |
| **Threat model** | A structured description of what you protect, from whom, and under which assumptions. |
| **TOTP** | Time-based one-time password (the six-digit authenticator code). Phishable, but far stronger than SMS. |
| **Zero-knowledge (password managers)** | The provider stores only client-side-encrypted data and never has the key to decrypt it. |

---

[← Stack overview](./README.md)
