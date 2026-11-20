# Mobile 2FA Hardening (Planned)

| | |
| --- | --- |
| **Layer** | 6 · Mobile Security (supports Layer 4 · Identity) |
| **Status** | 🧭 Planned |
| **Threats addressed** | SIM swapping, SMS interception, real-time phishing of one-time codes, MFA fatigue |
| **MITRE ATT&CK** | [T1111](https://attack.mitre.org/techniques/T1111/) Multi-Factor Authentication Interception · [T1621](https://attack.mitre.org/techniques/T1621/) Multi-Factor Authentication Request Generation · [T1557](https://attack.mitre.org/techniques/T1557/) Adversary-in-the-Middle |
| **Last reviewed** | 2026-11-20 |

## Why

Not all second factors are equal. From strongest to weakest:

| Method | Phishing-resistant? | Main weakness |
| --- | --- | --- |
| **FIDO2 / WebAuthn hardware key or passkey** | ✅ Yes, cryptographically bound to the real site's domain | Losing the key (mitigated by registering a backup key) |
| **TOTP authenticator app** | ❌ No | A real-time phishing proxy (adversary-in-the-middle) can relay the six-digit code within its 30-second window |
| **Push approval** | ❌ No | "MFA fatigue": spamming prompts until the victim taps Approve |
| **SMS / voice code** | ❌ No | SIM swapping, SS7 interception, phishing |

The goal is to move every account as far up this table as the service allows.

## The plan

1. **Inventory.** List every account in the vault and record its current second factor.
2. **FIDO2 first.** I already own a hardware security key (it is on my [USBGuard](../01-Physical-Security/usbguard.md) allow list). Register it, plus a **second backup key**, on every service that supports FIDO2/WebAuthn, starting with email, the vault, GitHub, and financial accounts.
3. **TOTP next.** Where FIDO2 is not supported, use TOTP in **Proton Authenticator**, an open-source, end-to-end encrypted authenticator released by Proton in July 2025 that works offline without a Proton account.
4. **SMS last.** Accounts that only offer SMS move to the [SIM-isolated identity device](./sim-isolation.md).
5. **Recovery codes** for every account are stored offline.

## Design principles for the migration

- **TOTP seeds are kept separate from the password vault.** Storing passwords and TOTP seeds in the same vault collapses two factors into one: whoever opens the vault gets both. Keeping TOTP in a separate app on a separate device preserves real two-factor protection.
- **Encrypted, exportable backups.** An authenticator must be able to export its secrets. Being locked into one app is how people lose access to accounts.

## How I will verify it

- The inventory shows **zero SMS-only accounts** that could use something stronger.
- Every FIDO2-capable account has **two** registered keys.
- Test a restore: wipe a test device, restore TOTP from the encrypted backup, and log in successfully.

## References

- [FIDO Alliance: Passkeys and FIDO2](https://fidoalliance.org/passkeys/)
- [Proton Authenticator](https://proton.me/authenticator)
- [CISA: Implementing Phishing-Resistant MFA (fact sheet, PDF)](https://www.cisa.gov/sites/default/files/publications/fact-sheet-implementing-phishing-resistant-mfa-508c.pdf)

---

[← Layer 6 overview](./README.md) · [Stack overview](../README.md)
