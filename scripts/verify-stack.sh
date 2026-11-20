#!/usr/bin/env bash
# verify-stack.sh - read-only audit of the controls documented in this repository.
#
# Checks Layer 1 (physical) and Layer 2 (OS) controls, plus the VPN, on a running
# Linux system and prints PASS / WARN / FAIL / SKIP for each.
#
# This script NEVER changes system state. Some checks need root:
#     ./scripts/verify-stack.sh            # unprivileged checks only
#     sudo ./scripts/verify-stack.sh       # full audit
#
# Exit status: 0 if no FAIL results, 1 if any check FAILed, 2 on usage error.

set -uo pipefail

VERSION="2.0.0"
USE_COLOR=1

PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0

usage() {
    cat <<EOF
Usage: $(basename "$0") [--no-color] [--help] [--version]

Read-only audit of the My Personal Operational Security Stack controls.
Run with sudo for the full set of checks.
EOF
}

for arg in "$@"; do
    case "$arg" in
        --no-color) USE_COLOR=0 ;;
        -h|--help) usage; exit 0 ;;
        --version) echo "verify-stack.sh ${VERSION}"; exit 0 ;;
        *) echo "Unknown option: $arg" >&2; usage >&2; exit 2 ;;
    esac
done

if [[ ! -t 1 ]]; then
    USE_COLOR=0
fi

if (( USE_COLOR )); then
    C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_RED=$'\033[31m'
    C_DIM=$'\033[2m'; C_BOLD=$'\033[1m'; C_RESET=$'\033[0m'
else
    C_GREEN=""; C_YELLOW=""; C_RED=""; C_DIM=""; C_BOLD=""; C_RESET=""
fi

pass() { PASS_COUNT=$((PASS_COUNT + 1)); printf '  %s[PASS]%s %s\n' "$C_GREEN" "$C_RESET" "$1"; }
warn() { WARN_COUNT=$((WARN_COUNT + 1)); printf '  %s[WARN]%s %s\n' "$C_YELLOW" "$C_RESET" "$1"; }
fail() { FAIL_COUNT=$((FAIL_COUNT + 1)); printf '  %s[FAIL]%s %s\n' "$C_RED" "$C_RESET" "$1"; }
skip() { SKIP_COUNT=$((SKIP_COUNT + 1)); printf '  %s[SKIP]%s %s\n' "$C_DIM" "$C_RESET" "$1"; }
section() { printf '\n%s== %s ==%s\n' "$C_BOLD" "$1" "$C_RESET"; }

have() { command -v "$1" >/dev/null 2>&1; }
is_root() { [[ ${EUID} -eq 0 ]]; }

# Read a sysctl value from /proc/sys without needing the sysctl binary.
read_sysctl() {
    local path="/proc/sys/${1//./\/}"
    if [[ -r "$path" ]]; then
        tr -d '[:space:]' < "$path"
    else
        echo ""
    fi
}

# ---------------------------------------------------------------------------
# Layer 1 - Physical Security
# ---------------------------------------------------------------------------

check_luks() {
    section "LUKS full disk encryption"
    if ! have lsblk; then
        skip "lsblk not available"
        return
    fi

    local luks_devs
    luks_devs=$(lsblk -rpno NAME,FSTYPE | awk '$2 == "crypto_LUKS" {print $1}')
    if [[ -z "$luks_devs" ]]; then
        fail "No LUKS-formatted block devices found"
        return
    fi
    pass "LUKS device(s) present: $(paste -sd ' ' <<<"$luks_devs")"

    local root_src
    root_src=$(findmnt -no SOURCE / 2>/dev/null || true)
    if lsblk -rspno TYPE "${root_src%%\[*}" 2>/dev/null | grep -qx crypt; then
        pass "Root filesystem sits on a dm-crypt mapping"
    else
        warn "Could not confirm that / is on an encrypted mapping (source: ${root_src:-unknown})"
    fi

    if ! is_root; then
        skip "LUKS header inspection needs root (cryptsetup luksDump)"
        return
    fi
    if ! have cryptsetup; then
        skip "cryptsetup not installed"
        return
    fi

    local dev dump
    while IFS= read -r dev; do
        [[ -z "$dev" ]] && continue
        dump=$(cryptsetup luksDump "$dev" 2>/dev/null) || { warn "$dev: luksDump failed"; continue; }

        if grep -qE '^Version:[[:space:]]+2' <<<"$dump"; then
            pass "$dev: LUKS2"
        else
            warn "$dev: not LUKS2"
        fi

        if grep -qE 'cipher:[[:space:]]+aes-xts-plain64' <<<"$dump"; then
            pass "$dev: cipher aes-xts-plain64"
        else
            warn "$dev: data cipher is not aes-xts-plain64"
        fi

        if grep -qE 'Cipher key:[[:space:]]+512 bits' <<<"$dump"; then
            pass "$dev: 512-bit XTS key (AES-256)"
        else
            warn "$dev: keyslot key size is not 512 bits"
        fi

        if grep -qE 'PBKDF:[[:space:]]+argon2id' <<<"$dump"; then
            pass "$dev: keyslot PBKDF argon2id"
        else
            warn "$dev: keyslot PBKDF is not argon2id"
        fi
    done <<<"$luks_devs"
}

check_usbguard() {
    section "USBGuard"
    if ! have usbguard; then
        fail "usbguard is not installed"
        return
    fi

    if have systemctl && systemctl is-active --quiet usbguard.service; then
        pass "usbguard.service is active"
    else
        fail "usbguard.service is not active"
    fi

    local rules="/etc/usbguard/rules.conf"
    if [[ -e "$rules" ]]; then
        local perms owner
        perms=$(stat -c '%a' "$rules")
        owner=$(stat -c '%U' "$rules")
        if [[ "$perms" == "600" && "$owner" == "root" ]]; then
            pass "$rules is root-owned with mode 600"
        else
            warn "$rules has mode $perms owned by $owner (expected 600 root)"
        fi
    else
        fail "$rules does not exist"
    fi

    local conf="/etc/usbguard/usbguard-daemon.conf"
    if [[ -r "$conf" ]]; then
        if grep -qE '^[[:space:]]*ImplicitPolicyTarget=block' "$conf"; then
            pass "Default policy: ImplicitPolicyTarget=block"
        else
            fail "ImplicitPolicyTarget is not set to block"
        fi
    elif [[ -e "$conf" ]]; then
        skip "$conf not readable (run with sudo)"
    else
        fail "$conf does not exist"
    fi

    if is_root && [[ -r "$rules" ]]; then
        if grep -qE '^[[:space:]]*allow[[:space:]]+with-interface' "$rules"; then
            warn "A generic 'allow with-interface' rule exists - if it is the HID recovery rule, it re-opens BadUSB"
        else
            pass "No generic interface-only allow rules found"
        fi
    fi
}

check_intel_me() {
    section "Intel ME (HAP)"
    if ! grep -qi 'GenuineIntel' /proc/cpuinfo 2>/dev/null; then
        skip "Not an Intel CPU"
        return
    fi
    if ! have lspci; then
        skip "lspci not available (package: pciutils)"
        return
    fi

    if lspci -nn | grep -Eiq 'MEI|HECI|Management Engine'; then
        warn "An Intel ME interface (MEI/HECI) is visible to the OS - ME may not be disabled"
    else
        pass "No MEI/HECI device visible (consistent with ME disabled via HAP)"
    fi

    if compgen -G "/dev/mei*" >/dev/null; then
        warn "/dev/mei* device node exists"
    else
        pass "No /dev/mei* device nodes"
    fi
}

check_hardware_sensors() {
    section "Camera and microphone hardware"
    if compgen -G "/dev/video*" >/dev/null; then
        warn "Video capture device(s) present (expected none unless an external webcam is attached)"
    else
        pass "No video capture devices"
    fi

    if have arecord; then
        if arecord -l 2>/dev/null | grep -q '^card'; then
            warn "Audio capture device(s) present (expected none unless an external mic is attached)"
        else
            pass "No audio capture devices"
        fi
    else
        skip "arecord not available (package: alsa-utils)"
    fi
}

# ---------------------------------------------------------------------------
# Layer 2 - Operating System
# ---------------------------------------------------------------------------

check_kernel() {
    section "Kernel"
    local release
    release=$(uname -r)
    if [[ "$release" == *hardened* ]]; then
        pass "Running hardened kernel: $release"
    else
        warn "Not running linux-hardened (current: $release)"
    fi
}

check_sysctl() {
    section "Sysctl hardening"
    # name | minimum acceptable value
    local -a expected=(
        "kernel.kptr_restrict|1"
        "kernel.dmesg_restrict|1"
        "kernel.yama.ptrace_scope|1"
        "net.core.bpf_jit_harden|2"
    )
    local entry name min value
    for entry in "${expected[@]}"; do
        name=${entry%%|*}
        min=${entry##*|}
        value=$(read_sysctl "$name")
        if [[ -z "$value" ]]; then
            skip "$name not available on this kernel"
        elif [[ "$value" =~ ^[0-9]+$ ]] && (( value >= min )); then
            pass "$name = $value (>= $min)"
        else
            fail "$name = $value (expected >= $min)"
        fi
    done
}

check_apparmor() {
    section "AppArmor"
    local enabled="/sys/module/apparmor/parameters/enabled"
    if [[ -r "$enabled" && "$(cat "$enabled")" == "Y" ]]; then
        pass "AppArmor LSM is enabled"
    else
        fail "AppArmor LSM is not enabled"
        return
    fi

    if ! is_root; then
        skip "Profile mode counts need root (aa-status)"
        return
    fi
    if ! have aa-status; then
        skip "aa-status not installed"
        return
    fi

    local enforced complain
    enforced=$(aa-status --enforced 2>/dev/null || echo "")
    complain=$(aa-status --complaining 2>/dev/null || echo "")
    if [[ "$enforced" =~ ^[0-9]+$ ]] && (( enforced > 0 )); then
        pass "$enforced profile(s) in enforce mode"
    else
        warn "No profiles in enforce mode"
    fi
    if [[ "$complain" =~ ^[0-9]+$ ]]; then
        if (( complain == 0 )); then
            pass "0 profiles in complain mode"
        else
            warn "$complain profile(s) in complain mode (logging only, not protecting)"
        fi
    fi
}

check_btrfs() {
    section "Btrfs snapshots"
    local fstype
    fstype=$(findmnt -no FSTYPE / 2>/dev/null || echo "")
    if [[ "$fstype" == "btrfs" ]]; then
        pass "Root filesystem is Btrfs"
    else
        fail "Root filesystem is ${fstype:-unknown}, not Btrfs"
        return
    fi

    if ! have snapper; then
        warn "snapper is not installed"
        return
    fi
    if ! is_root; then
        skip "Snapper configuration check needs root"
        return
    fi
    if snapper list-configs 2>/dev/null | grep -qE '^root[[:space:]]'; then
        pass "Snapper config 'root' exists"
    else
        warn "No Snapper config named 'root'"
    fi
    if have systemctl && systemctl is-enabled --quiet snapper-timeline.timer 2>/dev/null; then
        pass "snapper-timeline.timer is enabled"
    else
        warn "snapper-timeline.timer is not enabled"
    fi
    if have systemctl && systemctl is-enabled --quiet snapper-cleanup.timer 2>/dev/null; then
        pass "snapper-cleanup.timer is enabled (retention enforced)"
    else
        warn "snapper-cleanup.timer is not enabled (snapshots may accumulate)"
    fi
}

# ---------------------------------------------------------------------------
# Layer 3 - Network
# ---------------------------------------------------------------------------

check_vpn() {
    section "Mullvad VPN"
    if ! have mullvad; then
        skip "mullvad CLI not installed"
        return
    fi
    local status
    status=$(mullvad status 2>/dev/null || echo "")
    if grep -qi '^connected' <<<"$status"; then
        pass "Mullvad reports: $(head -n1 <<<"$status")"
    else
        fail "Mullvad is not connected (${status:-no output})"
    fi
}

# ---------------------------------------------------------------------------

main() {
    printf '%sMy Personal Operational Security Stack - verify-stack.sh v%s%s\n' "$C_BOLD" "$VERSION" "$C_RESET"
    printf 'Host: %s  |  Kernel: %s  |  Root: %s\n' "$(uname -n)" "$(uname -r)" "$(is_root && echo yes || echo no)"
    if ! is_root; then
        printf '%sTip: run with sudo for the full audit.%s\n' "$C_DIM" "$C_RESET"
    fi

    check_luks
    check_usbguard
    check_intel_me
    check_hardware_sensors
    check_kernel
    check_sysctl
    check_apparmor
    check_btrfs
    check_vpn

    printf '\n%sSummary:%s %s%d PASS%s, %s%d WARN%s, %s%d FAIL%s, %d SKIP\n' \
        "$C_BOLD" "$C_RESET" \
        "$C_GREEN" "$PASS_COUNT" "$C_RESET" \
        "$C_YELLOW" "$WARN_COUNT" "$C_RESET" \
        "$C_RED" "$FAIL_COUNT" "$C_RESET" \
        "$SKIP_COUNT"

    (( FAIL_COUNT == 0 ))
}

main
