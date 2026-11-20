# Self-Hosted Password Vault (Vaultwarden)

| | |
| --- | --- |
| **Layer** | 4 · Identity and Credentials |
| **Status** | ✅ Implemented |
| **Threats mitigated** | Cloud password-manager breaches, exposed vendor APIs and infrastructure, unwanted cloud sync |
| **MITRE ATT&CK** | [T1555.005](https://attack.mitre.org/techniques/T1555/005/) Credentials from Password Stores: Password Managers · [T1110](https://attack.mitre.org/techniques/T1110/) Brute Force |
| **Last reviewed** | 2026-11-20 |

## Why this control exists

Most people use 1Password, LastPass, or Bitwarden's cloud service. They are convenient, but they all follow a **trusted third party** model: you trust that the company's servers will not be breached, that its implementation is sound, and that its infrastructure will not be abused. The 2022 LastPass breach, in which attackers stole encrypted customer vaults, showed that this risk is real.

I do not want a company to hold the keys to my identity, so I host my own vault with **Vaultwarden**, a lightweight, unofficial, Bitwarden-compatible server written in Rust. I keep using the official Bitwarden client apps.

## How it works

Bitwarden-compatible vaults are **end-to-end encrypted on the client**:

1. My master password is run through a key derivation function (PBKDF2-SHA256 with a high iteration count, or Argon2id) on my own device.
2. The derived key decrypts the vault key, and vault items are encrypted with **AES-256-CBC with HMAC-SHA256** authentication.
3. The server only ever stores ciphertext. Even someone who steals the server's disk gets encrypted blobs that are useless without my master password.

Because I also host the server, there is no third party at all: the server is mine, and the data on it is ciphertext.

## My implementation

| Setting | Value |
| --- | --- |
| Server | Vaultwarden, self-hosted at home |
| Exposure | **LAN only.** It is not reachable from the internet, and there are no open ports or tunnels to it from outside. |
| Clients | Official Bitwarden apps |
| Master password | Random 32–36 characters (see [Passphrase Strategy](./passphrase-strategy.md)) |
| Backups | Captured by encrypted Btrfs snapshots on the server (see limitations) |

**Day-to-day:** clients sync only when I am at home on my local network. When I travel, the Bitwarden apps work from their **encrypted local cache**, so I can still read every password; new entries sync the next time I am home.

## Verification

```bash
# On the server: Vaultwarden should listen only on the LAN interface or behind a LAN-only reverse proxy
sudo ss -tlnp | grep -Ei 'vaultwarden|:80 |:443 |:8000 '

# From outside the home network (for example, phone on cellular): the vault address must NOT be reachable
```

In the Bitwarden client, **Settings → Account security** shows the KDF algorithm and its parameters.

## Trade-offs

- **No automatic sync on the go.** If I create or change a password while away, I need to make sure it syncs to my other devices once I am home.
- **I am the sysadmin.** Updates, TLS, uptime, and backups are my responsibility, with no vendor to fall back on.

## Limitations and residual risk

- **This is LAN-only, not air-gapped.** A truly air-gapped machine has no network connection at all, and my clients could not sync with it. "LAN-only" is the accurate term: it removes **internet** exposure, but a compromised device on my home network could still reach the server.
- **Backups are not yet off-device.** Btrfs snapshots live on the same drive as the database, so by my own rule ([snapshots are not backups](../02-Operating-System/btrfs-snapshots.md#trade-offs)) a drive failure would take both. Until the planned offline NAS exists, an encrypted vault export (`bw export --format encrypted_json`) to offline media is a cheap interim backup.
- **Client-side malware beats any vault.** A keylogger on my laptop captures the master password regardless of where the server lives. Enabling two-step login on the vault account adds another barrier.

## Verdict

Cloud breaches are one of the most common ways people lose their digital lives. With my vault off the internet, an attacker has to get onto my home network **and** know my master password before encrypted data becomes readable. For my threat model, that is a very high bar.

## References

- [Vaultwarden (GitHub)](https://github.com/dani-garcia/vaultwarden)
- [Bitwarden Security Whitepaper](https://bitwarden.com/help/bitwarden-security-white-paper/)

---

[← Layer 4 overview](./README.md) · [Stack overview](../README.md)
