# Btrfs Snapshots and System Recovery

| | |
| --- | --- |
| **Layer** | 2 · Operating System |
| **Status** | ✅ Implemented |
| **Threats mitigated** | Bad updates, broken configurations, accidental deletion; partial help against non-root ransomware |
| **MITRE ATT&CK** | [T1486](https://attack.mitre.org/techniques/T1486/) Data Encrypted for Impact · [T1490](https://attack.mitre.org/techniques/T1490/) Inhibit System Recovery (see limitations) |
| **Last reviewed** | 2026-11-20 |

## Why this control exists

Security is about **availability** as well as confidentiality and integrity. A kernel update that breaks the graphics stack, or a configuration change that stops the system from booting, can cost hours. I want to be able to return to a known-good state in minutes.

## How it works

**Btrfs** is a copy-on-write (CoW) filesystem. When data changes, Btrfs writes the new version to a new location instead of overwriting the old one in place. A **snapshot** is a new reference to the existing data at that moment, so taking one is nearly instant and initially uses almost no extra space. Space is consumed only as files change afterwards.

**Snapper** manages snapshots: it creates them on a schedule, cleans up old ones, and compares or rolls back changes.

## My implementation

- **Subvolume layout:** separate subvolumes for the root filesystem and for `/home`. Rolling the system back to an earlier snapshot therefore does **not** roll back my personal files, and system snapshots stay small.
- **Schedule:** a daily timeline snapshot, plus a manual snapshot before major updates or risky changes.
- **Retention:** snapshots are kept for roughly 7 days, so they do not slowly fill the SSD.
- **Boot integration:** GRUB is configured to list Btrfs snapshots (via `grub-btrfs`), so I can boot straight into a previous snapshot from the boot menu if the current system will not start.

## Verification

```bash
# List subvolumes
sudo btrfs subvolume list /

# List snapshots managed by Snapper
sudo snapper -c root list

# Take a manual snapshot before a risky change (recommended over raw btrfs commands)
sudo snapper -c root create --description "before kernel upgrade"

# Equivalent raw Btrfs command: a read-only (-r) snapshot of /
sudo btrfs subvolume snapshot -r / /.snapshots/manual-backup
```

## Trade-offs

- **Snapshots are NOT backups.** Snapshots live on the same physical SSD as the data. If the drive dies, both are gone. Snapshots protect against *logical* problems (bad updates, mistakes), not hardware failure. This is why an offline backup target (an air-gapped NAS) is on my [roadmap](../README.md#roadmap).
- **Disk space.** Snapshots that are never cleaned up slowly consume the drive, so retention limits are essential.
- **Kernel/boot mismatch.** If `/boot` (or the EFI partition) is not part of the root snapshot, booting an old snapshot with a newer kernel can cause module mismatches. `grub-btrfs` setups need to account for this.

## Snapshots and a real compromise

It is tempting to think "if someone gets root, I will just boot an old snapshot." **That is not a safe recovery plan,** and it is an important distinction:

- **Root can delete snapshots.** Deleting or encrypting backups and snapshots is a standard attacker technique ([T1490 Inhibit System Recovery](https://attack.mitre.org/techniques/T1490/)).
- **Persistence may live outside the snapshot.** A rootkit can hide in `/home`, the EFI partition, or firmware, none of which a root-subvolume rollback touches.
- **You cannot know when the compromise started.** "An earlier snapshot" may already contain the attacker's foothold.

The correct response to a suspected **root** compromise is incident response, not rollback: disconnect the machine, preserve evidence if needed, **rebuild from known-good installation media**, restore *data* (not system state) from offline backups, and rotate every credential that was used on the machine.

Snapshots do help in narrower cases. Ransomware running as my **unprivileged** user cannot modify read-only root snapshots, and a `/home` snapper configuration can provide a quick restore point for user files. That is useful, but it is not a substitute for offline backups.

## Verdict

Snapshots give me the freedom to experiment and update without fear of a bricked system, and they turn most "I broke it" moments into a two-minute rollback. For an actual compromise, the answer is rebuild and restore, and snapshots are honestly scoped to what they can do.

## References

- [ArchWiki: Btrfs](https://wiki.archlinux.org/title/Btrfs)
- [ArchWiki: Snapper](https://wiki.archlinux.org/title/Snapper)
- [grub-btrfs](https://github.com/Antynea/grub-btrfs)

---

[← Layer 2 overview](./README.md) · [Stack overview](../README.md)
