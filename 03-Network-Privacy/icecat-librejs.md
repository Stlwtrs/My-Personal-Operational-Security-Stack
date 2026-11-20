# GNU IceCat with LibreJS

| | |
| --- | --- |
| **Layer** | 3 · Network Privacy |
| **Status** | ✅ Implemented (daily browser) |
| **Threats mitigated** | Untrusted JavaScript (tracking, fingerprinting, cryptojacking, drive-by exploits), browser telemetry |
| **MITRE ATT&CK** | [T1189](https://attack.mitre.org/techniques/T1189/) Drive-by Compromise · [T1566](https://attack.mitre.org/techniques/T1566/) Phishing |
| **Last reviewed** | 2026-11-20 |

## Why this control exists

Visiting a typical modern website, in Chrome or a stock Firefox, means running dozens of third-party JavaScript files without seeing any of them. Most are harmless, but some exist to track activity, fingerprint the device, or even mine cryptocurrency in your browser (*cryptojacking*). JavaScript is also the main delivery mechanism for browser exploits.

**GNU IceCat** is the GNU Project's version of Firefox ESR (Extended Support Release). It removes non-free components and telemetry and changes many defaults for privacy. It ships with **LibreJS**, which blocks non-trivial JavaScript unless the script carries a recognized free-software license or I explicitly allow it. Current IceCat releases also bundle **JShelter** (see [Privacy Extensions](./privacy-extensions.md)).

## How it works

- **Default deny for scripts.** Pages load with only trivial or free-licensed JavaScript.
- **Explicit trust.** If a site I trust needs proprietary JavaScript (GitHub, for example), I allow that specific site through LibreJS.

## My implementation

| Component | Choice |
| --- | --- |
| Browser | GNU IceCat |
| Script control | LibreJS (bundled), per-site allow list |
| Network path | Always behind [Mullvad VPN](./vpn.md) |
| Extensions | See [Privacy Extensions](./privacy-extensions.md) |

## A useful side effect: phishing pages look broken

This was not the reason I chose IceCat, but it has turned out to be useful. Phishing sites often reuse a real site's JavaScript so that the clone looks authentic. Because I have allowed scripts only on the **real** domain, a clone on a lookalike domain loads with its scripts blocked and its layout broken.

If a link claiming to be GitHub opens with the layout obliterated, that is an immediate red flag before I type anything.

**Caveat:** this is a helpful *tell*, not a control. Many phishing kits are plain HTML and CSS forms that render fine without JavaScript. The real anti-phishing controls in my stack are a password manager that only autofills on the exact domain it saved, and phishing-resistant MFA (see [Layer 4](../04-Identity-Credentials/README.md)).

## Verification

Open a script-heavy site that is not on your allow list. The LibreJS toolbar icon should report blocked scripts, and the site should load degraded until you allow it.

## Trade-offs

- **The "bajillion scripts" problem.** Modern web apps like GitHub, YouTube, and banking sites load scripts from many domains and CDNs. Getting them working means a lot of clicking in LibreJS.
- **Some sites simply will not work** without proprietary JavaScript. For those, I switch to [Mullvad Browser](./mullvad-browser.md).

## Limitations and residual risk

- **Patch cadence.** IceCat is rebased on Firefox ESR by a small volunteer team, and its releases have historically lagged behind Mozilla's ESR security updates. A browser is the most exposed program on any system, so I keep IceCat current and treat any lag as a known risk.
- **Packaging.** On Arch, IceCat is not in the official repositories. It comes from the AUR or is built from source, so the [AUR caveats](../02-Operating-System/arch-linux.md#limitations-and-residual-risk) apply.
- **Fingerprint uniqueness.** A heavily customized browser stands out. IceCat is for **control** over what runs; [Mullvad Browser](./mullvad-browser.md) is for **blending in**.

## Verdict

It is high friction, but for everyday browsing, knowing exactly what code my browser executes is worth the setup time. I am using it right now to write this documentation.

## References

- [GNU IceCat](https://www.gnu.org/software/gnuzilla/)
- [GNU LibreJS](https://www.gnu.org/software/librejs/)

---

[← Layer 3 overview](./README.md) · [Stack overview](../README.md)
