# Faraday Bag (RF Shielding)

| | |
| --- | --- |
| **Layer** | 1 · Physical Security |
| **Status** | ✅ Implemented |
| **Threats mitigated** | Location tracking and wireless reachability of devices while stored, including phones that keep beaconing after "power off" |
| **MITRE ATT&CK** | [T1430](https://attack.mitre.org/techniques/T1430/) Location Tracking (Mobile) |
| **Last reviewed** | 2026-11-20 |

## Why this control exists

A common and dangerous assumption is that a device that is "off" is silent. That is not always true:

- **Phones.** Apple states that some devices, including iPhone, can keep sending their location to the Find My network for up to 24 hours after being turned off. That helps if the phone is stolen, but it also means a "switched off" phone is not radio-silent.
- **Laptops.** Business ("vPro") Intel laptops with Intel AMT can be managed out-of-band over the network while the OS is not running. My own laptop has the Intel ME disabled through [HAP mode](./intel-me-hap.md), so this risk is already small for it. The bag is a second layer rather than the primary control.

A Faraday bag removes the question entirely: whatever the firmware is doing, no radio signal gets in or out.

## How it works

A Faraday bag is a pouch lined with conductive metal mesh (usually nickel and copper) that blocks radio-frequency signals. Inside it a device cannot send or receive cellular, Wi-Fi, Bluetooth, NFC, or GPS signals.

This is **RF isolation**, not a true *air gap*. An air gap means a system never connects to a network at all; a Faraday bag only cuts the radio link while the device is inside it.

## My implementation

- **Gear:** a double-layer shielded bag from [SLNT](https://slnt.com/), sized for my laptop and phone.
- **Daily protocol:** when my phone or laptop is not in use, it goes into the bag. A nice side effect is that it doubles as a notification silencer in class, so my professors stay happy.

## Verification

Do this when you buy the bag, and repeat it every few months. The mesh wears with folding, and a bag that worked on day one can leak later.

1. Leave Wi-Fi and Bluetooth on and make sure the device is connected to a network.
2. Seal the device fully inside the bag (the roll-top or closure matters).
3. From another device: call the phone, ping the laptop's IP address, or try a Bluetooth connection.
4. **Pass:** the call goes straight to voicemail and pings time out. **Fail:** anything gets through.

## Trade-offs

- **Heat.** Devices shed heat through their chassis, and a sealed bag traps it like an oven. Let devices cool and **power them off** before bagging them. I learned this the hard way: I once bagged my laptop while it was still running and thought I had destroyed it.
- **Battery drain.** A phone that is still on inside the bag cannot find a signal and keeps searching at higher transmit power, draining the battery. Powering off first avoids this too.
- **Convenience.** It adds one physical step when I pack up. For my threat model, a three-second step for that peace of mind is an easy trade.

## Limitations and residual risk

- The bag only protects devices **while they are inside it**. It does nothing once the device is in use.
- It does not protect against an attacker who physically takes the bag.
- If you rely on remote locate/wipe features to recover a stolen phone, note that a bag blocks those too. Here that is the point, but it is a real trade-off.

## Verdict

For my phone, this is a meaningful control against tracking. For my laptop, it is defense in depth on top of HAP mode. Either way, it is cheap, simple, and easy to verify.

## References

- [SLNT](https://slnt.com/)
- [Apple: Find My](https://www.apple.com/icloud/find-my/)

---

[← Layer 1 overview](./README.md) · [Stack overview](../README.md)
