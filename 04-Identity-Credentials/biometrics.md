# No-Biometrics Policy

| | |
| --- | --- |
| **Layer** | 4 · Identity and Credentials |
| **Status** | ✅ Implemented |
| **Threats mitigated** | Forced unlocking through physical coercion; compelled biometric unlocking (US legal context) |
| **MITRE ATT&CK** | [T1461](https://attack.mitre.org/techniques/T1461/) Lockscreen Bypass (Mobile) |
| **Last reviewed** | 2026-11-20 |

> **Not legal advice.** I am a student, not a lawyer. This page describes my reasoning and summarizes publicly reported court decisions in the United States. Laws differ by jurisdiction and change over time.

## Why this control exists

Biometrics (Face ID, Touch ID, fingerprint readers) are marketed as a security upgrade. In practice, they are mostly a **convenience** upgrade, and in two specific situations they are weaker than a strong passcode.

### 1. The legal angle (United States)

The Fifth Amendment protects against *compelled testimonial* self-incrimination. Courts have generally treated revealing a passcode, which is something you know, as testimonial, although even that protection has exceptions (the "foregone conclusion" doctrine) and is not absolute.

For biometrics, the law is **unsettled**, and federal appeals courts disagree:

- **United States v. Payne (9th Cir., 2024):** forcing a suspect's thumb onto his phone was **not** testimonial, because it was a physical act requiring no thought, like being fingerprinted at booking.
- **United States v. Brown (D.C. Cir., January 2025):** compelling a defendant to unlock his phone with his thumbprint **was** testimonial, because choosing which finger to use communicated that he controlled the phone and knew how to open it.

That split means whether biometrics are protected can depend on where you are and on the exact facts. A passcode avoids the question: it requires you to *disclose* something, which is the strongest position the law currently recognizes.

As a law-abiding person, this is not about evading anything. I believe everyone has a right to privacy, and I want the strongest legal position available by default.

### 2. Physical coercion

If someone grabs my phone and holds it up to my face, Face ID unlocks it instantly. Nobody can force a 20+ character passcode out of me in the same way. A passcode gives me time to think and the option to refuse.

### 3. Biometric data itself

Apple stores Face ID and Touch ID data in the device's Secure Enclave, and it is not sent to Apple, so the "a corporation has a model of my face" concern is smaller than it is often made out to be. Still, if I never enroll, there is no biometric template on the device to attack or spoof.

## My implementation

| Device | Configuration |
| --- | --- |
| iPhone | Face ID **disabled**; long alphanumeric passcode (20+ characters) |
| Laptop | No fingerprint reader or camera hardware at all (see [Hardware Selection](../01-Physical-Security/hardware-selection.md)); LUKS passphrase and long user password |

## Verification

- **iPhone:** Settings → Face ID & Passcode → every "Use Face ID For" toggle is off, and no face is enrolled.
- **Laptop:** `fprintd-list "$USER"` (if `fprintd` is installed) shows no enrolled fingers, and the hardware has no reader.

## Trade-offs

- **Friction.** I type a long passcode every time I unlock my phone and laptop.
- **Shoulder-surfing exposure.** Typing a passcode in public is riskier than glancing at the phone. This is the classic "watch the passcode, then steal the phone" attack. I counter it by shielding the screen while typing, using a long alphanumeric code that is hard to observe, and following the [privacy-screen](../01-Physical-Security/privacy-screen.md) habits.
- **Losing some iOS protections.** Apple's *Stolen Device Protection* uses Face ID/Touch ID for its extra checks on sensitive actions. Without biometrics I do not get that layer.

## For readers who keep biometrics

If you keep Face ID or Touch ID, learn your device's quick lockdown gesture. On iPhone, pressing and holding the side button and either volume button until the power-off screen appears forces the passcode on the next unlock. Use it in any situation where you might be forced to unlock.

## Verdict

Most people trade real legal and physical protections for a split second of convenience without realizing it. I would rather type a long passcode and keep full control over my devices.

## References

- [CDT: Circuit split on biometric phone unlocking](https://cdt.org/insights/circuit-court-split-lays-the-groundwork-for-scotus-case-on-biometric-cell-phone-unlocking/)
- [Apple Platform Security: Face ID and Touch ID](https://support.apple.com/guide/security/face-id-and-touch-id-security-sec067eb0c9e/web)

---

[← Layer 4 overview](./README.md) · [Stack overview](../README.md)
