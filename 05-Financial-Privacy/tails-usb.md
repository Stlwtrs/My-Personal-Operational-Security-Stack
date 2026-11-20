# Tails OS for Wallet Management

| | |
| --- | --- |
| **Layer** | 5 · Financial Privacy |
| **Status** | ✅ Implemented |
| **Threats mitigated** | Malware on my daily OS stealing wallet keys, keyloggers, local disk forensics, IP-address leaks from wallet traffic |
| **MITRE ATT&CK** | [T1056.001](https://attack.mitre.org/techniques/T1056/001/) Keylogging · [T1005](https://attack.mitre.org/techniques/T1005/) Data from Local System · [T1014](https://attack.mitre.org/techniques/T1014/) Rootkit |
| **Last reviewed** | 2026-11-20 |

## Why this control exists

Even with a hardened Arch install, if my daily system were compromised by sophisticated malware (an eBPF rootkit, for example), my wallet keys could be stolen the moment I unlocked the wallet there.

So I never manage my wallet on my daily OS. I use **Tails**, a portable operating system that boots from a USB stick, sends all network traffic through Tor, and forgets everything when it shuts down, apart from an optional encrypted Persistent Storage.

Booting a separate OS for wallet work **compartmentalizes** my funds away from anything that might be lurking on my daily system.

## How it works

- **Amnesic.** Each boot starts from the same clean, read-only system image. Malware that infects one session does not survive a reboot (unless it gets into Persistent Storage).
- **Tor-only networking.** Applications that try to connect directly, bypassing Tor, are blocked.
- **Encrypted Persistent Storage.** A LUKS-encrypted partition on the same USB stick holds only what I choose to keep, in this case the wallet.

Tails is now part of the Tor Project; the two organizations merged in 2024.

## My implementation

| Component | Choice |
| --- | --- |
| OS | Tails, booted live from a dedicated USB stick |
| Network | Tor (Tails default) |
| Wallet | Official Monero GUI wallet, installed in Persistent Storage; its Tails mode routes connections through Tor |
| Persistent Storage | LUKS-encrypted with a long (20+ word) passphrase |

## Operational rules

- **Physical separation.** The Tails USB is stored separately from my laptop when not in use.
- **No digital copies of secrets.** The Persistent Storage passphrase and the wallet's seed are never typed into any other device. Both exist only on paper, stored in a secure location.
- **Private locations only.** Accessing the wallet means a full Tails boot and a wallet sync, which I only do somewhere private.
- **Verify every download.** Tails images are verified using the official instructions before being written to the USB stick.

## Verification

- At boot, Tails' welcome screen confirms the version, and *Persistent Storage* unlocks only with the correct passphrase.
- Inside Tails, [check.torproject.org](https://check.torproject.org/) confirms that traffic goes through Tor.
- The Monero GUI shows its sync status and the daemon/node it is connected to.

## Trade-offs

- **Sync time.** Every boot requires the wallet to catch up with the blockchain, which takes a while if Tails has not been used for weeks.
- **No quick checks.** I cannot glance at my balance on my phone. Accessing funds is a deliberate, multi-step physical process, and that is the point.

## Limitations and residual risk

- **This is isolation, not cold storage.** Tails is online (over Tor) while the wallet is open, so this setup is better described as an **isolated warm wallet** than as cold storage. For large long-term holdings, true cold storage keeps the spend key on a device that **never** touches a network. Monero supports this through **offline transaction signing** (a view-only wallet online, with signing on an offline machine) and through hardware wallets.
- **Same hardware as my daily OS.** Tails protects against software on the daily OS, not against compromised **firmware or hardware** of the laptop it boots on. My [open firmware and HAP-disabled ME](../01-Physical-Security/README.md) reduce that risk.
- **Persistent Storage is a target.** Anything that writes malware into Persistent Storage survives reboots, so I keep it limited to the wallet.

## Verdict

For long-term storage and high-value transactions, the friction is worth it. It turns my wallet from a convenient but exposed **hot wallet** on my daily system into a deliberately isolated one.

## Try Tails yourself

Tails is a lifeline for people living under repressive regimes, for investigative journalists, and for whistleblowers. Edward Snowden famously used it to communicate securely with journalists.

- **[Tails](https://tails.net/)**: official website, downloads, and documentation
- **[Donate to Tails](https://tails.net/donate/)**: support the people who maintain this critical privacy tool

---

[← Layer 5 overview](./README.md) · [Stack overview](../README.md)
