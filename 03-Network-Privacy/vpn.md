# Mullvad VPN

| | |
| --- | --- |
| **Layer** | 3 · Network Privacy |
| **Status** | ✅ Implemented |
| **Threats mitigated** | ISP logging and resale of browsing data, DNS snooping, on-path observers on untrusted Wi-Fi, website-fingerprinting traffic analysis |
| **MITRE ATT&CK** | [T1040](https://attack.mitre.org/techniques/T1040/) Network Sniffing · [T1557](https://attack.mitre.org/techniques/T1557/) Adversary-in-the-Middle |
| **Last reviewed** | 2026-11-20 |

## Why this control exists

Without a VPN, my ISP can see every domain I look up, every server I connect to, and when and for how long I use each service. That data can be logged, sold to data brokers, or leaked in a breach.

A VPN **moves** that visibility from my ISP to the VPN provider; it does not make it disappear. So the real question is which party I trust more, and why. I chose **Mullvad** because its claims are backed by evidence:

- **No personal information required.** Accounts are a randomly generated 16-digit number, with no email address.
- **Anonymous payment options,** including cash and Monero.
- **Proven no-logs under pressure.** In April 2023, Swedish police arrived at Mullvad's office with a search warrant to seize computers containing customer data. Mullvad showed that no such data existed, and the police left without taking anything.
- **Regular independent audits** of its apps and infrastructure (for example by Cure53).

Even encrypted traffic leaks information through the **size and timing** of packets. Researchers have shown that machine-learning models can often guess which website you are visiting from those patterns alone ("website fingerprinting"). The settings below address that.

## How it works (my configuration)

### DAITA (Defense Against AI-guided Traffic Analysis)

- *What it is:* Mullvad makes every packet in the tunnel the same size, adds random background traffic, and distorts traffic patterns, which blurs the size and timing signals of my browsing. It was developed with Karlstad University and is built on the open-source Maybenot framework.
- *Why it matters:* it makes website-fingerprinting models much less accurate, because every page load looks more alike on the wire.

### Multihop

- *What it is:* traffic enters through one Mullvad server and exits through a second one.
- *Why it matters:* the entry server knows my IP address but not my destinations; the exit server sees destinations but not my IP. That makes traffic-correlation attacks against a single server much harder.

### DNS content blocking

- *What it is:* DNS queries are resolved by Mullvad's resolver inside the encrypted tunnel, with blocklists for ads, trackers, and known malware domains.
- *Why it matters:* my ISP never sees which domains I look up, and requests to known-malicious domains fail before a connection is even attempted.

## Verification

```bash
mullvad status    # should report "Connected" and the relay in use
```

Then open the [Mullvad connection check](https://mullvad.net/en/check) in the browser. It confirms that traffic is going through Mullvad and tests for DNS and WebRTC leaks.

## Trade-offs

- **Speed.** DAITA and Multihop together noticeably slow my connection. Padding, dummy packets, and an extra hop all cost bandwidth and latency.
- **Mobile data.** DAITA's dummy traffic uses extra data. On a limited mobile plan, turning it off while on cellular saves a lot of data, at some cost to privacy.
- **Battery life.** Constant encryption and padding cost CPU. With everything enabled, I lose about an hour and a half of battery life.
- **CAPTCHAs and blocks.** Shared VPN exit IPs are sometimes rate-limited or challenged by websites.

## Limitations and residual risk

- **A VPN does not make you anonymous.** Cookies, logins, and browser fingerprints identify you regardless of your IP address. That is why the [browser controls](./README.md#browser-compartmentalization) exist.
- **Mullvad is now the party I trust.** Their track record is strong, but it is still trust in a single provider. For tasks that require not trusting any single party, I use [Tor](./tor-browser.md).
- **Leak protection.** Mullvad's always-require-VPN / lockdown setting blocks traffic if the tunnel drops. Without it, a reconnect can briefly leak traffic outside the tunnel.

## Verdict

I accept the latency and battery hit. Making sure my ISP sees nothing but encrypted noise, from a provider that has proven it keeps no logs, is worth the performance cost for my threat model.

## References

- [Mullvad VPN](https://mullvad.net/en)
- [Mullvad: Search warrant, customer data not compromised (April 2023)](https://mullvad.net/en/blog/2023/4/20/mullvad-vpn-was-subject-to-a-search-warrant-customer-data-not-compromised/)
- [Mullvad: DAITA](https://mullvad.net/en/vpn/daita)

---

[← Layer 3 overview](./README.md) · [Stack overview](../README.md)
