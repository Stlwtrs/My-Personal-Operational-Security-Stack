# Mandatory Access Control (AppArmor)

| | |
| --- | --- |
| **Layer** | 2 · Operating System |
| **Status** | ✅ Implemented |
| **Threats mitigated** | Exploited applications reading or writing files outside their purpose; post-exploitation access to keys and documents |
| **MITRE ATT&CK** | [T1005](https://attack.mitre.org/techniques/T1005/) Data from Local System · [T1552.004](https://attack.mitre.org/techniques/T1552/004/) Private Keys · [T1068](https://attack.mitre.org/techniques/T1068/) Exploitation for Privilege Escalation |
| **Last reviewed** | 2026-11-20 |

## Why this control exists

Traditional Linux permissions use **Discretionary Access Control (DAC)**: a program runs with the full permissions of the user who started it. If I open a malicious PDF in a vulnerable PDF reader, the attacker who exploits it inherits *my* permissions immediately. They can read my SSH keys, my documents, and anything else I can read.

**Mandatory Access Control (MAC)** adds a second, policy-based check that the program cannot override. Even if an attacker fully compromises a confined program, the kernel only allows the files, capabilities, and network access listed in that program's profile.

## How it works

The two main Linux MAC frameworks are:

| | AppArmor | SELinux |
| --- | --- | --- |
| Model | Path-based profiles per program | Label-based policy for the whole system |
| Default on | Ubuntu, Debian | Fedora, RHEL and derivatives |
| On Arch | Supported by the official kernel and packages | Requires unofficial (AUR) packages |
| Learning curve | Moderate | Steep |

I use **AppArmor**. It is officially supported on Arch, and its per-program, path-based profiles are much easier to read and maintain on a single-user workstation.

Profiles run in one of two modes:

- **Complain:** violations are logged but allowed. This is useful while writing a profile, but it provides no protection.
- **Enforce:** violations are blocked by the kernel and logged.

## My implementation

- AppArmor enabled as a Linux Security Module through the kernel command line (`lsm=` parameter), with `apparmor.service` enabled.
- The standard profiles shipped with the distribution's packages are loaded.
- **All loaded profiles run in enforce mode.** I do not leave profiles in complain mode, because a complain-mode profile is only a log.

## Verification

```bash
aa-enabled                    # "Yes" if AppArmor is active
sudo aa-status                # profiles loaded, and how many are in enforce vs. complain mode
sudo aa-status | grep <app>   # does a specific program have a profile?
sudo aa-unconfined            # network-facing processes that have NO profile
```

A hardened setup should show **zero profiles in complain mode**. `aa-unconfined` is the honest counterpart: it shows exactly what AppArmor is *not* protecting.

## Trade-offs

- **The false-positive phase.** When a new profile is enforced, an application can break because it touches files the profile did not anticipate, sometimes legitimately and sometimes not (a text editor has no reason to read network configuration, for example). Check `journalctl` and the audit log for `DENIED` entries, and adjust the profile with `aa-logprof`.

## Limitations and residual risk

- **AppArmor only confines programs that have a profile.** On a desktop, many applications have no profile and run **unconfined**, with ordinary DAC permissions. AppArmor walls off the profiled programs; it does not automatically put every app on its own island. Expanding profile coverage is ongoing work, and `aa-unconfined` is how I track it.
- Profiles are only as strict as they are written. An overly broad profile (`/home/** rw`, for example) gives little real protection.

## Verdict

Once profiles are tuned, AppArmor is invisible in daily use. If a zero-day hits a profiled application, AppArmor is the wall between the attacker and my keys and documents. Knowing which applications are *not* behind that wall is just as important as the wall itself.

## References

- [AppArmor](https://apparmor.net/)
- [ArchWiki: AppArmor](https://wiki.archlinux.org/title/AppArmor)

---

[← Layer 2 overview](./README.md) · [Stack overview](../README.md)
