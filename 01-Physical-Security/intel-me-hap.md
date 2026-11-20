# Intel ME (HAP Mode)

| | |
| --- | --- |
| **Layer** | 1 · Physical Security |
| **Status** | ✅ Implemented |
| **Threats mitigated** | Firmware-level exploitation of the Management Engine, out-of-band remote management (Intel AMT) |
| **MITRE ATT&CK** | [T1542](https://attack.mitre.org/techniques/T1542/) Pre-OS Boot |
| **Last reviewed** | 2026-11-20 |

## Why this control exists

The **Intel Management Engine (ME)** is a separate, closed-source microcontroller built into the chipset (the Platform Controller Hub) of modern Intel platforms. Since ME version 11 it runs its own operating system based on MINIX 3. It starts before the main CPU, keeps running while the system is on, and can access system memory and, on supported platforms, the network. Because it sits below the OS kernel and even the hypervisor, it is often described as running at **"Ring -3."** It is more privileged than `root` on the Linux system above it.

On business ("vPro") platforms the ME also hosts **Intel Active Management Technology (AMT)**, which allows remote out-of-band management. This is not theoretical: in 2017, [CVE-2017-5689](https://nvd.nist.gov/vuln/detail/CVE-2017-5689) (Intel-SA-00075) allowed unauthenticated remote access to AMT, and Intel-SA-00086 disclosed further flaws in ME 11 itself.

Many consumer laptops do not include AMT at all, but every modern Intel system still runs ME firmware. Minimizing what that firmware does is a reasonable hardening step.

## How it works

There are two main approaches:

1. **Firmware modification with `me_cleaner`.** This tool edits the firmware image to strip out ME modules and/or set the HAP bit, and the modified image is then written back to the SPI flash chip. On older platforms it could remove most of the ME firmware; on ME 11 and newer, far less can be removed. Writing the flash often requires an external hardware programmer and risks bricking the board. **This is not what I did.**
2. **HAP mode (High Assurance Platform).** HAP is a bit in the firmware's flash descriptor that Intel added for a US government (NSA) program. Researchers at Positive Technologies showed in 2017 that setting it on ME 11 makes the ME halt shortly after it finishes platform initialization. The ME cannot be removed completely, because modern Intel platforms will not boot without it, but HAP stops it after its essential startup work. **This is the method I use.**

## My implementation

My laptop runs Dasharo firmware (see [Hardware Selection](./hardware-selection.md)). Dasharo's Intel Management Engine options include a **Disabled (HAP)** mode, which sets the HAP bit in the flash descriptor. When the ME is disabled, Dasharo also hides the ME's host interface (MEI/HECI) from the operating system.

## Verification

```bash
# The ME host interface (MEI/HECI) should NOT appear when the ME is disabled
lspci -nn | grep -Ei 'communication controller|MEI|HECI' || echo "no MEI/HECI device visible"

# No /dev/mei* character devices should exist
ls /dev/mei* 2>/dev/null || echo "no /dev/mei devices"

# The kernel should not have bound the mei driver
sudo dmesg | grep -i mei
```

The firmware setup menu (Intel Management Engine Options) also shows the configured ME mode.

**Be honest about what this proves.** The absence of the MEI device is consistent with HAP being active, but the OS cannot directly prove that the ME has halted; it can only show that its interface is gone. The firmware setting plus the missing interface is the best evidence available from a normal user's position.

## Trade-offs

- **Not a full removal.** The ME firmware is still physically present in flash. Anyone who can rewrite the flash descriptor, for example with an SPI programmer and physical access, could re-enable it.
- **Possible side effects.** HAP has been reported to affect suspend/sleep on some platforms. Test sleep and resume after enabling it.

## Limitations and residual risk

- HAP is a mitigation, not a guarantee. The ME still executes code during early boot, and any vulnerability in that early phase is not addressed.
- My threat model explicitly excludes nation-state attackers with physical access to the flash chip. That is acceptable for me, but a determined attacker with the same access could do the same thing.

## Verdict

For my Tier 2 threat model (ISPs, opportunistic attackers, and physical theft), HAP mode is more than sufficient. It removes the ME's runtime and remote-management attack surface while keeping the system stable, and it was a single firmware setting rather than a risky flash operation.

## References

- [Positive Technologies: Disabling Intel ME 11 via undocumented mode](https://global.ptsecurity.com/analytics/disabling-intel-me-11-via-undocumented-mode)
- [Dasharo documentation](https://docs.dasharo.com/)
- [me_cleaner](https://github.com/corna/me_cleaner)
- [NVD: CVE-2017-5689](https://nvd.nist.gov/vuln/detail/CVE-2017-5689)

---

[← Layer 1 overview](./README.md) · [Stack overview](../README.md)
