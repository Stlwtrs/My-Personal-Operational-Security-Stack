# SIM Isolation (Planned)

| | |
| --- | --- |
| **Layer** | 6 · Mobile Security |
| **Status** | 🧭 Planned |
| **Threats addressed** | SIM swapping, SMS-based account takeover, linking my daily device to my legal identity |
| **MITRE ATT&CK (Mobile)** | [T1451](https://attack.mitre.org/techniques/T1451/) SIM Card Swap · [T1430](https://attack.mitre.org/techniques/T1430/) Location Tracking |
| **Last reviewed** | 2026-11-20 |

## Why

My phone number is tied to my legal identity and to accounts that, in the worst case, can be reset by SMS. In a **SIM-swap** attack, a criminal convinces or bribes a carrier employee to move my number to a SIM they control. From then on, they receive my calls and SMS codes, including password-reset codes.

Some legacy financial institutions still require SMS 2FA. As long as that is true, my phone number is part of my attack surface.

## The plan

Move my primary SIM into a **separate, locked-down "identity" device** that is used only for:

- banking and other services that require a real phone number,
- SMS 2FA where no alternative exists,
- calls that must come from my real number.

My **daily device** (the planned [GrapheneOS](./grapheneos.md) phone) then no longer carries the number that is tied to my identity. Whether it runs Wi-Fi only or uses a separate data-only line is still an open decision.

### Carrier-side hardening (independent of the device split)

- Set a **carrier account PIN** and enable the carrier's **port-out / SIM-change protection** (most major US carriers offer a version of this).
- Use a carrier account email address that is not publicly associated with me.

## What this does and does not solve

| Helps with | Does not solve |
| --- | --- |
| A malicious app or compromise on my daily phone cannot read SMS codes it never receives | A SIM swap still hijacks the number itself, so carrier-side protections still matter |
| My daily device is not trivially tied to my legal identity through its phone number | The identity device is still located by the cell network whenever it is on; isolation reduces linkage, not tower-based location of that device |
| Fewer apps and services ever see my real number | Services that insist on SMS 2FA remain weaker than TOTP or FIDO2, wherever that SIM lives |

## How I will verify it

- The daily device has no SIM or eSIM carrying my primary number.
- Every account in my vault is reviewed: which ones still use SMS 2FA, and which have moved to TOTP or FIDO2 (tracked in [Mobile 2FA](./mobile-2fa.md)).
- The carrier account shows the PIN and port-out protection as enabled.

## References

- [FCC consumer guide: Cell phone fraud (SIM swapping and port-out scams)](https://www.fcc.gov/consumers/guides/cell-phone-fraud)
- [FCC rules: Protecting Consumers from SIM-Swap and Port-Out Fraud (2023)](https://www.federalregister.gov/documents/2023/12/08/2023-26338/protecting-consumers-from-sim-swap-and-port-out-fraud)

---

[← Layer 6 overview](./README.md) · [Stack overview](../README.md)
