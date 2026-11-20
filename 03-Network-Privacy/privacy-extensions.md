# Privacy and Security Extensions

| | |
| --- | --- |
| **Layer** | 3 · Network Privacy |
| **Status** | ✅ Implemented (IceCat profile) |
| **Threats mitigated** | Cross-site tracking, malvertising, URL tracking parameters, JavaScript fingerprinting, browser-based port scanning |
| **MITRE ATT&CK** | [T1189](https://attack.mitre.org/techniques/T1189/) Drive-by Compromise |
| **Last reviewed** | 2026-11-20 |

## Why this control exists

Even inside a privacy-focused browser, the average website is hostile. Pages try to load trackers from dozens of domains, serve malicious ads (*malvertising*), and run scripts that fingerprint the device. My extensions act as a second filtering layer inside the browser.

**Scope:** this extension set lives in my **IceCat** profile. [Mullvad Browser](./mullvad-browser.md) and [Tor Browser](./tor-browser.md) stay stock on purpose, because adding extensions to them makes their users less uniform and undermines their anti-fingerprinting design.

## The extensions I use

| Extension | What it does | Notes |
| --- | --- | --- |
| **uBlock Origin** | Blocks ads, trackers, and known-malicious domains using filter lists, inside the browser before requests are made | The core of the set. Blocking ads is a security control, not just a cosmetic one: malvertising is a real infection vector. |
| **LibreJS** | Blocks non-free, non-trivial JavaScript unless I allow it | Bundled with IceCat. See [IceCat](./icecat-librejs.md). |
| **JShelter** | Wraps JavaScript APIs to reduce fingerprinting and limit risky browser features | Bundled with current IceCat. Uses *farbling*: it slightly randomizes fingerprintable values **per domain and per session**, so the fingerprint each site sees differs and cannot be linked across sites. This is a different strategy from Mullvad Browser's "everyone looks identical." |
| **ClearURLs** | Strips tracking parameters such as `utm_source` and `fbclid` from links | uBlock Origin can do much of this with URL-tracking filter lists, so there is some overlap. |
| **Decentraleyes** | Serves common JavaScript libraries (jQuery, Bootstrap, etc.) from a local copy instead of public CDNs | Avoids a request to a third-party CDN for each page. LocalCDN is a more actively developed fork with broader library coverage. |
| **Privacy Redirect** | Redirects YouTube, X/Twitter, Reddit, and others to privacy-friendly front ends (Invidious, Nitter, Libreddit) | **No longer maintained.** LibRedirect is its maintained successor, and many front-end instances have shut down or moved to forks. |
| **Total Privacy and Security (TPRB)** | Tightens tracking protections and privacy defaults against known data brokers | A fail-safe for domains that slip past uBlock Origin's lists. |
| **Privacy Badger** | EFF's tracker blocker | Since October 2020, Privacy Badger no longer learns from your own browsing by default, because local learning could itself be used to fingerprint users. It now relies on a pre-trained list ("Badger Sett") that the EFF updates. Local learning can be re-enabled in its settings. |
| **Port Authority** | Blocks websites from using your browser to port-scan your computer or local network, and blocks LexisNexis ThreatMetrix tracking scripts | Created after eBay was caught port-scanning visitors in 2020. It is not a general connection monitor or IDS; it targets these two specific abuses. |

## Verification

- **uBlock Origin:** the toolbar badge shows how many requests were blocked on each page.
- **Port Authority:** test pages linked from its [GitHub repository](https://github.com/ACK-J/Port_Authority) attempt browser-based port scans; blocked attempts appear in the developer tools' Network tab.
- **Fingerprinting:** compare results at [Cover Your Tracks](https://coveryourtracks.eff.org/) with JShelter on and off.

## Trade-offs

- **Breakage.** With LibreJS, JShelter, uBlock Origin, and the rest running together, many web apps (banking portals, heavy SaaS apps) break. I allow specific sites or use a less restricted browser for them.
- **Fingerprint entropy.** Every extension can make a browser *more* unique, which works against anti-fingerprinting. I accept that this profile is distinctive. Its job is control over what runs, not blending in; blending in is [Mullvad Browser](./mullvad-browser.md)'s job.

## Limitations and residual risk

- **Overlap.** Several extensions do similar work (uBlock Origin, Privacy Badger, TPRB, and ClearURLs all block or strip tracking to some degree). Overlap adds defense in depth, but it also adds fingerprint surface and maintenance.
- **Extensions are a supply-chain risk.** Each has broad access to every page I visit, and extensions are sometimes sold or hijacked and then updated with malicious code. Fewer, well-maintained, widely audited extensions are better than many.
- **Unmaintained extensions age badly.** Privacy Redirect is a current example. Unmaintained extensions should be replaced or removed.

## Verdict

Maximum protection comes with friction no matter what you do. I accept the occasional broken site in exchange for knowing what runs on each page and what is tracking me. I also review this list periodically, because an extension that was the right choice two years ago may not be the right choice now.

## References

- [uBlock Origin](https://github.com/gorhill/uBlock)
- [JShelter: Farbling](https://jshelter.org/farbling/)
- [EFF: Privacy Badger is changing to protect you better (2020)](https://www.eff.org/deeplinks/2020/10/privacy-badger-changing-protect-you-better)
- [Port Authority (GitHub)](https://github.com/ACK-J/Port_Authority)
- [LibRedirect](https://libredirect.github.io/)

---

[← Layer 3 overview](./README.md) · [Stack overview](../README.md)
