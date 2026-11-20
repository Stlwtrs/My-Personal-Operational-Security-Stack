# Tor Browser

| | |
| --- | --- |
| **Layer** | 3 · Network Privacy |
| **Status** | ✅ Implemented (situational, not a daily driver) |
| **Threats mitigated** | Single-provider trust (ISP or VPN), IP-based identification, network censorship |
| **MITRE ATT&CK** | [T1040](https://attack.mitre.org/techniques/T1040/) Network Sniffing |
| **Last reviewed** | 2026-11-20 |

> **Disclaimer:** This document is provided for educational purposes and to document my personal privacy architecture. I do not condone using Tor for illegal activity. Tor is a vital tool for journalists, activists, and privacy-conscious people worldwide, and it should be used responsibly and within the law.

## Why this control exists

My VPN hides my traffic from my ISP, but it requires trusting Mullvad. For tasks where I do not want **any** single party to be able to link me to my activity, I use Tor.

Tor (The Onion Router) sends traffic through three volunteer-run relays: a **guard**, a **middle**, and an **exit** relay. Each layer of encryption is peeled off at the next relay, so no single relay knows both who I am and where I am going.

I use Tor Browser for **high-risk compartmentalization** only. Its main role in my stack is anonymous network access for my Monero wallet on [Tails](../05-Financial-Privacy/tails-usb.md).

## My implementation

- **Browser:** the official [Tor Browser](https://www.torproject.org/download/).
- **Bridges when needed:** on networks that block Tor, I use a pluggable-transport bridge:
  - **obfs4** scrambles Tor traffic so it looks like random bytes rather than recognizable Tor traffic.
  - **Snowflake** tunnels traffic over WebRTC through volunteer proxies, so it resembles a video call.
- **Security level:** I run at **Safest** by default, which disables JavaScript on all sites and blocks many other attack vectors. If a site I genuinely need breaks, I step down one level for that task.

## Operational rules

- **Never log in to personal accounts.** Logging in to a personal email or social account ties that whole session to my identity. If I need a fresh identity, I use **New Identity**, which clears state and builds new circuits.
- **Do not resize the window to unusual dimensions.** Window size used to be a major fingerprinting vector. Tor Browser now uses *letterboxing* (padding the page to standard sizes) to blunt this, but keeping the default window size is still the safest habit.
- **No extra extensions.** Tor Browser is tuned so all users look alike. Every added extension makes you more unique.
- **Use HTTPS.** The exit relay can see unencrypted traffic, so HTTPS (or `.onion` services) is essential.

## Verification

Visit [check.torproject.org](https://check.torproject.org/). It confirms whether the browser is using Tor.

## Trade-offs

- **Speed.** Three relays around the world will always be slower than a direct or single-hop VPN connection.
- **CAPTCHAs and blocks.** Because Tor exit IPs are public and shared, services like Google and Cloudflare often challenge or block them.

## Limitations and residual risk

- **Global passive adversaries** that can watch both ends of a connection can attempt traffic correlation. This is explicitly out of scope for my threat model.
- **Browser exploits** remain the main way Tor users are de-anonymized. The Safest security level reduces that risk significantly.
- **Behavior matters more than the tool.** Writing style, login habits, and timing can link activity to a person even over Tor.

## Verdict

Tor is not about convenience; it is about anonymity. When I need it, I accept the friction and latency that come with it.

## Support the Tor Project

The Tor network is maintained by a 501(c)(3) non-profit and funded by donations. If you value a free and open internet, consider supporting relay infrastructure and development: **[donate.torproject.org](https://donate.torproject.org)**.

## References

- [The Tor Project](https://www.torproject.org/)
- [Tor Support: Bridges](https://support.torproject.org/tor-browser/circumvention/using-bridges/)
- [Tor Support: Fingerprinting protections](https://support.torproject.org/tor-browser/features/fingerprinting-protections/)

---

[← Layer 3 overview](./README.md) · [Stack overview](../README.md)
