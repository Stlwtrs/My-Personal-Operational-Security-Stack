# Hardware Selection

| | |
| --- | --- |
| **Layer** | 1 · Physical Security |
| **Status** | ✅ Implemented |
| **Threats mitigated** | Unauditable closed-source firmware, Intel ME exposure, camera/microphone hijacking, vendor lock-in |
| **MITRE ATT&CK** | [T1542](https://attack.mitre.org/techniques/T1542/) Pre-OS Boot · [T1125](https://attack.mitre.org/techniques/T1125/) Video Capture · [T1123](https://attack.mitre.org/techniques/T1123/) Audio Capture |
| **Last reviewed** | 2026-11-20 |

## Why this control exists

You can install every firewall and encryption tool in the world, but if the hardware and firmware underneath are compromised, none of it matters. Most consumer laptops (Dell, HP, Lenovo, Apple) ship with closed-source UEFI/BIOS firmware and proprietary microcontrollers that the owner cannot inspect.

I chose a laptop from **[NovaCustom](https://novacustom.com/)**, a Netherlands-based company that builds Linux-first machines to order, because it let me address these problems at the hardware and firmware level instead of trying to patch around them in software.

## How it works

**Open-source firmware (Dasharo / coreboot).** NovaCustom ships its laptops with Dasharo, an open-source firmware distribution built on **coreboot** with a UEFI (EDK II) payload. Coreboot is not a bootloader: it is the firmware that initializes the hardware at power-on and then hands control to a payload, which in turn starts the bootloader (GRUB in my case). Because the source is public, the boot process is far more transparent than a typical closed vendor BIOS.

**Intel ME disabled.** The firmware exposes an option to put the Intel Management Engine into HAP (High Assurance Platform) mode, which halts it early in boot. Details are in [Intel ME (HAP Mode)](./intel-me-hap.md).

**Linux-first engineering.** The machine is designed to run Linux natively with Intel integrated graphics, so there is no fight with proprietary drivers (Nvidia being the usual offender).

## My implementation

| Component | Choice |
| --- | --- |
| Vendor | NovaCustom (built to order) |
| Firmware | Dasharo (coreboot + UEFI payload) |
| Intel ME | Disabled via the HAP bit |
| Camera and microphone | Physically removed at my request when the laptop was built |
| Storage | 4 TB NVMe SSD (room for local virtual machines and AI tooling) |
| Graphics | Intel integrated (no proprietary GPU driver needed) |

Instead of relying on hardware kill switches, I had the camera and microphone removed entirely. This is not necessary for everyone, but it eliminates camera and microphone hijacking as an attack vector rather than merely making it harder.

## Verification

```bash
# Firmware should identify itself as Dasharo
sudo dmidecode -s bios-version

# No internal camera should be present (external webcams will appear if plugged in)
ls /dev/video* 2>/dev/null || echo "no video capture devices"

# No internal capture (microphone) devices should be listed
arecord -l
```

## Trade-offs

- **Cost.** Made-to-order Linux hardware costs more than a mass-market laptop, and shipping from the Netherlands adds international shipping and tax costs. You are paying for the engineering and the care that goes into each build.
- **Performance.** I traded top-tier gaming performance for security and better battery life. If I want to game, a desktop is the better tool anyway.
- **No built-in camera or microphone.** Video calls need an external webcam or headset, which in turn must be allowed through [USBGuard](./usbguard.md).

## Limitations and residual risk

- **"Open-source firmware" is not 100% open.** Coreboot on modern Intel platforms still depends on binary components from Intel, such as the Firmware Support Package (FSP), CPU microcode, and the ME firmware itself. Dasharo greatly reduces what is closed, but it does not eliminate it.
- **Firmware integrity is a separate problem from firmware openness.** Open source makes the firmware inspectable; it does not by itself prove that the image on my flash chip has not been modified. Verified or measured boot (for example UEFI Secure Boot with my own keys, or Dasharo's Heads variant) is the control that addresses that, and it is not documented as part of this stack yet.

## Verdict

As someone going into the cybersecurity field, hardware I can inspect is a non-negotiable for me. The premium, including the cost of shipping from the Netherlands, is 100% worth it.

## References

- [NovaCustom](https://novacustom.com/)
- [Dasharo documentation](https://docs.dasharo.com/)
- [coreboot project](https://www.coreboot.org/)

---

[← Layer 1 overview](./README.md) · [Stack overview](../README.md)
