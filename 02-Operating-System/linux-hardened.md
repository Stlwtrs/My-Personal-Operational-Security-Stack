# The `linux-hardened` Kernel

| | |
| --- | --- |
| **Layer** | 2 · Operating System |
| **Status** | ✅ Implemented |
| **Threats mitigated** | Kernel exploits, memory-corruption attacks, kernel information leaks |
| **MITRE ATT&CK** | [T1068](https://attack.mitre.org/techniques/T1068/) Exploitation for Privilege Escalation · [T1082](https://attack.mitre.org/techniques/T1082/) System Information Discovery |
| **Last reviewed** | 2026-11-20 |

## Why this control exists

The mainline Linux kernel is tuned for compatibility and performance. That is the right default for most users, but it means some security features are off or relaxed so that older software and unusual hardware keep working.

**`linux-hardened`** is a security-focused kernel maintained as a patch set on top of the stable kernel. Arch ships it in its **official repositories** (`pacman -S linux-hardened`); it is not an AUR package. It applies extra exploit mitigations and stricter defaults directly in the kernel.

## How it works

Examples of what the hardened kernel changes (the exact list evolves with each release):

- **Stronger memory-corruption mitigations,** such as higher address space layout randomization (ASLR) entropy and additional heap and slab hardening, which make memory-corruption exploits less reliable.
- **Restricted kernel information,** for example blocking unprivileged access to the kernel log (`dmesg`) and hiding kernel pointers, so attackers cannot easily learn kernel memory addresses.
- **Reduced unprivileged attack surface,** such as restricting unprivileged user namespaces and unprivileged BPF, two features that have been the entry point for many local privilege-escalation exploits.

## My implementation

- `linux-hardened` installed from the official Arch repositories and set as the default boot entry.
- My hardware uses Intel integrated graphics, so I do not depend on out-of-tree GPU drivers.
- Additional runtime settings are in [Sysctl Kernel Hardening](./sysctl-hardening.md).

## Verification

```bash
uname -r                    # should end in "-hardened"
pacman -Q linux-hardened    # installed version
```

## Trade-offs

- **Hardware and driver compatibility.** Proprietary or out-of-tree modules (looking at you, Nvidia) may fail to build or load. If you depend on them, use the DKMS versions and install `linux-hardened-headers` so modules rebuild on every kernel update.
- **Software that expects unprivileged user namespaces.** Some sandboxing tools and applications rely on them and may need configuration changes or a policy exception.
- **Slight performance cost** from some mitigations.

## Limitations and residual risk

- A hardened kernel raises the cost of exploitation; it does not eliminate kernel vulnerabilities.
- **Keep a fallback kernel.** Having the standard `linux` or `linux-lts` kernel as a second boot entry means a bad hardened-kernel update does not leave the machine unbootable.

## Verdict

With Intel integrated graphics, `linux-hardened` runs flawlessly on my hardware. Knowing that common kernel exploit techniques are significantly harder to pull off is worth the very small maintenance overhead.

## References

- [linux-hardened (GitHub)](https://github.com/anthraxx/linux-hardened)
- [ArchWiki: Security (Kernel hardening)](https://wiki.archlinux.org/title/Security#Kernel_hardening)

---

[← Layer 2 overview](./README.md) · [Stack overview](../README.md)
