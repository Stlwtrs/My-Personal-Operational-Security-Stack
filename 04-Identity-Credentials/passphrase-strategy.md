# Passphrase Strategy

| | |
| --- | --- |
| **Layer** | 4 · Identity and Credentials |
| **Status** | ✅ Implemented |
| **Threats mitigated** | Brute-force and dictionary attacks, credential stuffing, password reuse |
| **MITRE ATT&CK** | [T1110.001](https://attack.mitre.org/techniques/T1110/001/) Password Guessing · [T1110.002](https://attack.mitre.org/techniques/T1110/002/) Password Cracking · [T1110.004](https://attack.mitre.org/techniques/T1110/004/) Credential Stuffing |
| **Last reviewed** | 2026-11-20 |

## Why this control exists

A typical password looks like `Password1!`: a dictionary word, a capital letter, a digit, and a symbol in predictable places. Cracking tools try exactly these patterns first, so passwords like this fall almost instantly in an offline attack, no matter how "complex" they look.

What defeats cracking is **entropy**, meaning true unpredictability, and the easiest way to get it is **length plus randomness**. What defeats credential stuffing is something different: **uniqueness**. If every account has its own password, a breach of one site reveals nothing about the others.

## My implementation: a tiered approach

### Tier 1: the master keys (memorized)

These are the only secrets I memorize. They protect everything else.

| Secret | Length | Notes |
| --- | --- | --- |
| LUKS disk passphrase | 32–36 random characters | Typed every boot; it is muscle memory, and I can enter it in under five seconds |
| Vault master password | 32–36 random characters | Unlocks Tier 2 |
| Phone passcode | ~20–24 characters | A long alphanumeric passcode instead of a PIN or biometrics (see [No Biometrics](./biometrics.md)) |

### Tier 2: the vault (generated, never memorized)

Every other account (banking, GitHub, forums, everything) gets a **unique, randomly generated 48–60 character** password stored in my [self-hosted vault](./password-manager.md). I could not memorize these if I tried, and I do not need to.

## The math

For a password chosen **uniformly at random**, entropy in bits = length × log₂(size of the character set). With an 82-character set (upper- and lowercase letters, digits, and 20 symbols):

| Length | Possible combinations | Entropy |
| --- | --- | --- |
| 20 | 82²⁰ | ≈ 127 bits |
| 32 | 82³² | ≈ 203 bits |
| 36 | 82³⁶ | ≈ 229 bits |
| 60 | 82⁶⁰ | ≈ 381 bits |

**What that means in time:** at one **trillion** guesses per second, searching half of the 36-character keyspace (the average for a successful attack) would take on the order of **10⁴⁹ years**. The universe is about 1.4 × 10¹⁰ years old.

**A fun thought experiment for 60 characters:** the observable universe contains roughly 10⁸⁰ atoms. If *every atom* were a computer making a billion guesses per second, an exhaustive search would still take around **10¹⁸ years**, about 77 million times the current age of the universe. That is not "longer than the heat death of the universe" (heat-death estimates are vastly longer), but it is far beyond anything physically achievable.

You can reproduce these numbers with a few lines of Python:

```python
import math
bits = 36 * math.log2(82)                            # ≈ 228.9
years = (82**36 / 2) / 1e12 / 3.156e7                # ≈ 1.2e49 at 10^12 guesses/s
print(round(bits, 1), f"{years:.1e}")
```

### Context that matters more than raw entropy

- **Offline vs. online attacks.** These numbers assume an attacker with a copy of the password hash who can guess as fast as their hardware allows. Online attacks against a login page are rate-limited and far slower.
- **Slow key derivation multiplies the work.** LUKS (Argon2id) and Bitwarden (PBKDF2 or Argon2id) make every guess deliberately expensive, so the real cost is far higher than the table suggests.
- **Diminishing returns.** Beyond roughly 128 bits, extra length adds no practical security; nothing can search a 2¹²⁸ space. My 48–60 character Tier 2 passwords are overkill. Since the vault generates them, the length costs nothing, but in practice those accounts are protected by being **unique and random**, not by having 381 bits. (Some sites also cap password length, so the generator setting has to adapt.)
- **The real threats to Tier 2 accounts** are phishing, malware, and server-side breaches, not brute force. That is why [MFA](../06-Mobile-Security/mobile-2fa.md) and domain-matched autofill matter so much.

## How I memorize the master keys

Practice and repetition. I type these passphrases at least five times a day, so they have become muscle memory: my fingers know the pattern even if I could not easily recite it. I can type my disk passphrase without looking at the keyboard.

An alternative worth knowing is the **diceware passphrase**: several random words from a large word list (for example, 7–8 words from the EFF long word list, roughly 90–100 bits). It is much easier to memorize than a random string at strong entropy, but I prefer random strings for my Tier 1 secrets.

## Trade-offs

- **The risk:** because Tier 1 lives in my head, a head injury or sudden death would make that data permanently inaccessible, including to my family.
- **The mitigation:** I keep a **sealed physical paper copy** of the master passphrases in a secure offline location. They are never stored digitally, never photographed, and never typed anywhere except where they are used.

## Verdict

The friction of typing a long passphrase is a small price for cryptographic security. If someone gets into an account protected this way by brute force, they should buy a lottery ticket. Actually, maybe not; they used up all their luck.

## References

- [NIST SP 800-63B: Digital Identity Guidelines (Authentication)](https://pages.nist.gov/800-63-4/sp800-63b.html)
- [EFF: Diceware and the long word list](https://www.eff.org/dice)

---

[← Layer 4 overview](./README.md) · [Stack overview](../README.md)
