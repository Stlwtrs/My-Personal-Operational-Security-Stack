# LUKS Full Disk Encryption

| | |
| --- | --- |
| **Layer** | 1 · Physical Security |
| **Status** | ✅ Implemented |
| **Threats mitigated** | Data theft from a lost, stolen, or seized laptop; offline imaging of the SSD |
| **MITRE ATT&CK** | [T1005](https://attack.mitre.org/techniques/T1005/) Data from Local System (via physical access) |
| **Last reviewed** | 2026-11-20 |

## Why this control exists

If my laptop is stolen out of my bag at a coffee shop, I want confidence that the thief cannot read my files, my crypto wallet data, or my password vault cache.

Even if a thief removes the NVMe SSD and connects it to another machine, they hit a cryptographic wall. **LUKS (Linux Unified Key Setup)** encrypts the entire block device, so without the passphrase its contents are indistinguishable from random noise.

## How it works

LUKS2 uses a two-key design:

1. A random **volume key** encrypts the actual disk data, here with **AES-256 in XTS mode** (`aes-xts-plain64`). XTS uses two 256-bit keys, which is why the key size is reported as **512 bits**.
2. My passphrase never encrypts data directly. It goes through a deliberately slow, memory-hard **key derivation function** (Argon2id by default in LUKS2) to unlock a *keyslot*, which holds an encrypted copy of the volume key.

This means an attacker cannot practically attack AES-256 itself. The only realistic attack is guessing the passphrase, and Argon2id makes every guess expensive. That is why passphrase strength is the deciding factor (see [Passphrase Strategy](../04-Identity-Credentials/passphrase-strategy.md)).

**On quantum computing:** the best known quantum attack on symmetric ciphers (Grover's algorithm) roughly halves the effective key length, which leaves AES-256 at about 128-bit security. That is still considered secure, so AES-256 is not the weak point here.

## My implementation

| Setting | Value |
| --- | --- |
| Format | LUKS2 |
| Cipher | AES-256-XTS (`aes-xts-plain64`, 512-bit key) |
| Passphrase | Fully random, 32–36 characters, memorized |
| Recovery | Sealed paper copy kept in a secure offline location (see [Passphrase Strategy](../04-Identity-Credentials/passphrase-strategy.md#trade-offs)) |

The passphrase lives in my head for daily use, not on a sticky note on the laptop. Encryption with the key taped to the device is useless. Typing it takes a few seconds at boot, which is negligible.

## Verification

```bash
# Find the encrypted partition (TYPE "crypt" sits on top of it)
lsblk -o NAME,TYPE,FSTYPE,MOUNTPOINTS

# Inspect the LUKS header (adjust the device path to match your system)
sudo cryptsetup luksDump /dev/nvme0n1p2
```

In the output, check for:

- `Version: 2`
- Under **Data segments**: `cipher: aes-xts-plain64`
- Under **Keyslots**: `Cipher key: 512 bits` and `PBKDF: argon2id`

The [`verify-stack.sh`](../scripts/verify-stack.sh) script runs these checks automatically.

## Trade-offs

- **The "hit by a bus" dilemma.** A passphrase that only exists in my head can be lost through injury or simply forgetting it, and then the data is gone for good. I mitigate this with a sealed offline paper copy, which deliberately trades a little physical-security risk for recoverability.
- **Boot friction.** A few seconds of typing on every boot.

## Limitations and residual risk

- **Only protects data at rest.** While the laptop is running or **suspended**, the volume key is in RAM and the data is effectively unlocked. Cold-boot and DMA-style attacks target exactly this state. When the laptop is going to be out of my control (travel, checkpoints), it should be **fully shut down**, not suspended.
- **Evil-maid attacks.** If the bootloader or kernel image on the unencrypted boot/EFI partition is tampered with while the laptop is unattended, a modified boot chain could capture the passphrase the next time I type it. Defenses include Secure Boot with self-signed boot images, TPM-measured boot, or Heads firmware. These are not yet part of this stack.
- **Shoulder surfing.** A passphrase typed in public can be observed. See [Privacy Screen](./privacy-screen.md).
- **Header damage.** If the LUKS header at the start of the partition is corrupted, the data is unrecoverable even with the correct passphrase.

## Further hardening (not yet implemented)

- Keep an offline **LUKS header backup** (`cryptsetup luksHeaderBackup`) on separate, encrypted media.
- Evaluate **Secure Boot with my own keys** (or Dasharo's Heads variant) to close the evil-maid gap.

## Verdict

Three seconds of friction at boot is a small price for knowing that a stolen, powered-off laptop gives the thief hardware and nothing else.

## References

- [cryptsetup / LUKS2 on-disk format (GitLab)](https://gitlab.com/cryptsetup/cryptsetup)
- [ArchWiki: dm-crypt / Encrypting an entire system](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system)

---

[← Layer 1 overview](./README.md) · [Stack overview](../README.md)
