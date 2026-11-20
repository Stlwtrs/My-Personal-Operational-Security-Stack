# Privacy Screen (Anti-Shoulder-Surfing)

| | |
| --- | --- |
| **Layer** | 1 · Physical Security |
| **Status** | ✅ Implemented |
| **Threats mitigated** | Shoulder surfing and visual eavesdropping ("visual hacking") in public spaces |
| **MITRE ATT&CK** | N/A (physical observation is outside ATT&CK's scope) |
| **Last reviewed** | 2026-11-20 |

## Why this control exists

You can have the strongest encryption in the world, but if someone watches you type your disk passphrase, they do not need to break anything. They just remember it.

At a coffee shop, on campus, or in a library, a laptop screen is effectively a billboard for anyone nearby. A privacy screen narrows the viewing angle so that only the person directly in front of it can read it.

## How it works

A privacy filter is a micro-louver film (a microscopic set of blinds). Looking straight on, the screen looks normal. From the side, even slightly off-center, the light is blocked and the screen appears black or heavily dimmed.

## My implementation

- **Gear:** a magnetic or slide-mount filter. I recommend non-adhesive filters so they can be taken off easily in a private room.
- **Where it matters most:**
  - **Public transit:** stops the person in the next seat from reading messages or documents.
  - **Coffee shops and libraries:** stops people at nearby tables from watching sensitive work.
  - **Flights:** in tight seating, the passenger next to me sees a black rectangle instead of my screen.

## Verification

Look at the screen from the side, at roughly 30–45 degrees, the angle a seatmate would see. The content should not be readable.

## Trade-offs

- **Dimming.** Privacy filters block a noticeable share of the screen's light (roughly 30–40% for typical filters), so I run the brightness higher, which costs some battery life.
- **Color accuracy.** Filters slightly wash out colors, which matters if you do photo or video work.

## Limitations and residual risk

- **It only narrows the angle.** Someone standing **directly behind** me, or a camera mounted overhead, can still see the screen.
- **It does not protect the keyboard.** Passphrases can be learned by watching fingers instead of the screen. When typing my LUKS or vault passphrase in public, I shield the keyboard or wait until I am somewhere private.

## Verdict

For someone in cybersecurity, a privacy screen is one of the cheapest and most effective physical security tools you can buy. The dimming is a small price.

---

[← Layer 1 overview](./README.md) · [Stack overview](../README.md)
