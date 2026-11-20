# Mullvad Browser

| | |
| --- | --- |
| **Layer** | 3 · Network Privacy |
| **Status** | ✅ Implemented |
| **Threats mitigated** | Browser fingerprinting, canvas and font tracking, cross-site correlation |
| **MITRE ATT&CK** | N/A (tracking and fingerprinting are privacy threats rather than intrusion techniques) |
| **Last reviewed** | 2026-11-20 |

## Why this control exists

A VPN hides your IP address, but it does **not** stop websites from recognizing your browser. Screen size, installed fonts, time zone, user agent, graphics rendering, and CPU core count combine into a profile that is often unique to your device: its **fingerprint**.

**Mullvad Browser** is a joint project between Mullvad VPN and the Tor Project. It takes Tor Browser's anti-fingerprinting work and removes the Tor network, so you can use it with a normal VPN at normal speeds. The strategy is the same as Tor Browser's: **make every user look identical,** so no one stands out.

## How it works

- **Uniform fingerprint.** Letterboxing standardizes the reported window size, canvas readouts are blocked, and fonts are restricted to a standard set.
- **Private by default.** It runs in private browsing mode, so cookies and site data are cleared when it closes.
- **No telemetry.** No analytics, crash reports, or calls home.
- **Preinstalled protections.** It ships with uBlock Origin and NoScript already configured.

## My implementation

- I use Mullvad Browser **as shipped**, with no extra extensions and the default settings. Adding extensions or changing preferences makes the fingerprint less uniform and defeats the point.
- I use it when I want to blend in without the latency of Tor, and when IceCat's LibreJS makes a site unusable.
- It always runs behind [Mullvad VPN](./vpn.md).

### Why use both Mullvad Browser and IceCat?

They solve different problems:

| | IceCat | Mullvad Browser |
| --- | --- | --- |
| Strategy | **Control:** default-deny scripts | **Blend in:** look like every other user |
| Customization | Heavy (extensions, allow lists) | None, on purpose |
| Best for | Everyday browsing on sites I trust | Sites that need lots of JavaScript; general anonymity on the clearnet |

## Verification

Test your browser at the EFF's [Cover Your Tracks](https://coveryourtracks.eff.org/). With default settings, Mullvad Browser should present a fingerprint shared by its whole user base rather than a unique one. The Tor Project's [fingerprinting protections guide](https://support.torproject.org/tor-browser/features/fingerprinting-protections/) explains what is being normalized; it applies here because Mullvad Browser is built on the same work.

## Trade-offs

- **Frequent logins.** Site data is cleared on close, so I log in to sites more often.
- **Some breakage.** Anti-fingerprinting can slightly slow down or break some web apps.

## Limitations and residual risk

- It is less anonymous than Tor Browser because my traffic exits from a VPN server, which means trusting Mullvad, rather than through three independent relays.
- Logging in to an account identifies me no matter how uniform the fingerprint is.

## Verdict

It is the closest you can get to Tor Browser's anti-fingerprinting without using the Tor network, and it pairs perfectly with Mullvad VPN.

## References

- [Mullvad Browser](https://mullvad.net/en/browser)
- [EFF: Cover Your Tracks](https://coveryourtracks.eff.org/)

---

[← Layer 3 overview](./README.md) · [Stack overview](../README.md)
