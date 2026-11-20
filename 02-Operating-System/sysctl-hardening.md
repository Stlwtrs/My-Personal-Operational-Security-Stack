# Sysctl Kernel Hardening

| | |
| --- | --- |
| **Layer** | 2 · Operating System |
| **Status** | ✅ Implemented |
| **Threats mitigated** | Kernel information leaks, local privilege escalation, process snooping and injection |
| **MITRE ATT&CK** | [T1068](https://attack.mitre.org/techniques/T1068/) Exploitation for Privilege Escalation · [T1055.008](https://attack.mitre.org/techniques/T1055/008/) Ptrace System Calls · [T1082](https://attack.mitre.org/techniques/T1082/) System Information Discovery |
| **Last reviewed** | 2026-11-20 |

## Why this control exists

Even with a hardened kernel and AppArmor, Linux exposes a lot of information to unprivileged users by default. An attacker who lands a low-privilege shell can use details like kernel memory addresses or other processes' memory to build a reliable privilege-escalation exploit.

`sysctl` lets me tune kernel parameters at runtime and lock this information down.

## My implementation

The settings live in a dedicated drop-in file, `/etc/sysctl.d/total-hardening.conf`. Any name works as long as it ends in `.conf`. A copy is in [`configs/sysctl/total-hardening.conf`](../configs/sysctl/total-hardening.conf).

| Parameter | My value | What it does |
| --- | --- | --- |
| `kernel.kptr_restrict` | `1` | Hides kernel pointer addresses (for example in `/proc/kallsyms`) from users without `CAP_SYSLOG`. Without addresses, memory-corruption exploits are much harder to make reliable. `2` hides them from everyone, including root. |
| `kernel.dmesg_restrict` | `1` | Only privileged users can read the kernel ring buffer (`dmesg`), which often contains hardware details, memory addresses, and error messages useful to an attacker. |
| `kernel.yama.ptrace_scope` | `1` | `ptrace` lets one process inspect and modify another's memory. At `1`, a process can only trace its own descendants, so a compromised process cannot attach to another program running as the same user and read its secrets or inject code. |
| `net.core.bpf_jit_harden` | `2` | Hardens the BPF just-in-time compiler for all users (for example constant blinding), defeating JIT-spraying techniques that abuse BPF. |

### `ptrace_scope` values at a glance

| Value | Meaning |
| --- | --- |
| `0` | Classic behavior: any process can trace any other process with the same UID |
| `1` | Restricted: only a parent (or an explicitly allowed process) can trace |
| `2` | Admin-only: tracing requires `CAP_SYS_PTRACE` |
| `3` | Disabled entirely until reboot |

## Verification

```bash
# Apply all sysctl.d files now, without rebooting
sudo sysctl --system

# Check each value
sysctl kernel.kptr_restrict kernel.dmesg_restrict kernel.yama.ptrace_scope net.core.bpf_jit_harden
```

Expected output:

```text
kernel.kptr_restrict = 1
kernel.dmesg_restrict = 1
kernel.yama.ptrace_scope = 1
net.core.bpf_jit_harden = 2
```

## Trade-offs

- **Debugging.** With `ptrace_scope = 1`, launching a program *under* a debugger (`gdb ./app`, `strace ./app`) still works, because the program is a child of the debugger. What breaks is **attaching to an already-running process** (`gdb -p <pid>`, `strace -p <pid>`). For that, use `sudo` for the one session instead of lowering the setting system-wide.

## Limitations and residual risk

- **Do not weaken stricter kernel defaults.** A sysctl file is applied after boot and overrides the kernel's default. If the running kernel already defaults to a stricter value (for example `kptr_restrict = 2`), writing `1` here would *lower* it. Check the value with the drop-in temporarily disabled before deciding what to set.
- **These four settings are a baseline, not a complete hardening profile.** The reference config includes additional commonly recommended settings, commented out and clearly marked as not applied, for future evaluation.

## Verdict

This laptop is my daily workstation, not a development server. The security benefit of these settings far outweighs the occasional `sudo` I need when attaching a debugger.

## References

- [Linux kernel documentation: `/proc/sys/kernel/`](https://docs.kernel.org/admin-guide/sysctl/kernel.html)
- [Linux kernel documentation: Yama LSM](https://docs.kernel.org/admin-guide/LSM/Yama.html)
- [ArchWiki: sysctl](https://wiki.archlinux.org/title/Sysctl)

---

[← Layer 2 overview](./README.md) · [Stack overview](../README.md)
