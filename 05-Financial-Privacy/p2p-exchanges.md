# P2P Exchanges and Self-Mining

| | |
| --- | --- |
| **Layer** | 5 · Financial Privacy |
| **Status** | ✅ Implemented |
| **Threats mitigated** | KYC data breaches, exchange insolvency, arbitrary account freezes, financial surveillance |
| **MITRE ATT&CK** | N/A |
| **Last reviewed** | 2026-11-20 |

## Why this control exists

Centralized exchanges like Coinbase and Binance are single points of failure. To use them, you hand over your legal identity (KYC), your bank details, and your full transaction history. That creates two risks:

- **The honeypot risk.** Exchanges are prime targets for attackers. If an exchange's database is breached, your identity is permanently linked to your wallet addresses, and in the worst case the funds held there are stolen.
- **The freeze risk.** Automated risk systems can freeze accounts over "suspicious activity," which can include something as ordinary as regularly withdrawing to your own cold storage.

I minimize my reliance on centralized, KYC-heavy exchanges and acquire cryptocurrency through **self-mining** and **non-custodial peer-to-peer swaps**.

## 1. Self-mining with XMRig

Mining Monero myself means newly created coins go straight to my own wallet: no fiat on-ramp, no bank transfer, no KYC.

Monero uses the **RandomX** proof-of-work algorithm, which is designed to run efficiently on ordinary CPUs. I use **[XMRig](https://xmrig.com/)**, an open-source, high-performance miner, configured through its `config.json` rather than long command lines. A sanitized example is in [`configs/xmrig/config.example.json`](../configs/xmrig/config.example.json).

### Key settings

| Setting | Value | Why |
| --- | --- | --- |
| `cpu.huge-pages` | `true` | Large memory pages reduce **TLB** (Translation Lookaside Buffer) misses, which significantly improves RandomX hashrate. Because XMRig runs as an unprivileged user, root must reserve huge pages ahead of time (`vm.nr_hugepages`); XMRig's startup log shows whether the allocation succeeded. |
| `cpu.max-threads-hint` | `75` | Use about 75% of CPU threads, never 100%. The machine stays responsive and runs cooler, and hardware longevity matters as much as hashrate. |
| `pools[].tls` | `true` | Encrypts the connection between the miner and the pool so an observer cannot read the mining protocol traffic. The pool must support TLS. |
| `http.enabled` | `false` | Keeps XMRig's HTTP API off. It is disabled by default and binds to `127.0.0.1` when enabled, but enabling it on `0.0.0.0` without an access token would let anyone on the network query or control the miner, so I keep it off. |

### Operational rules for mining

1. **Never run as root.** XMRig is written in C++ and works directly with system memory. It runs under a dedicated, unprivileged user, so a vulnerability in the miner gives an attacker an account with nothing useful in it.
2. **Thermal management.** Mining keeps the CPU under sustained load. I monitor temperatures with `lm_sensors` (official Arch repositories). If the CPU passes about 85 °C, I reduce the thread count. Availability matters as much as confidentiality and integrity, and cooked hardware is an availability failure.
3. **Network isolation.** All mining traffic goes through [Mullvad VPN](../03-Network-Privacy/vpn.md), so neither my ISP nor the pool sees my real IP address.

**Worth knowing:** a traditional pool operator sees my payout address and the (VPN) IP I connect from. **P2Pool**, a decentralized Monero mining pool with no operator and no custody of funds, is an alternative that removes that middleman.

## 2. Non-custodial P2P swaps

When I need to trade another asset for Monero, I use **non-custodial** methods, such as BTC↔XMR **atomic swaps**.

- Buyers and sellers trade directly, with no central intermediary holding funds.
- An atomic swap is enforced cryptographically: either both sides of the trade complete, or neither does.
- No government ID is handed to a central authority, which keeps my data out of centralized databases that could later be breached.

## 3. Spending: closing the loop

I spend XMR directly with privacy-respecting services. For example, I pay for my Mullvad VPN account with Monero. Acquiring, holding, and spending privately creates a closed loop with no KYC link at any point.

## Verification

```bash
# XMRig must not be running as root
ps -o user=,comm= -C xmrig

# Huge pages reserved by the system
grep -i hugepages_total /proc/meminfo

# CPU temperatures under load
sensors
```

## Trade-offs

- **Friction and skill.** P2P trading and mining are much slower and need far more technical knowledge than typing a card number into an exchange.
- **Vigilance.** P2P markets have no customer support to reverse a bad trade, and the same privacy that protects me also protects a scammer. If you get scammed, the money is almost certainly gone.
- **Economics.** CPU mining on a laptop often earns less than the electricity it uses and adds wear to the hardware. I do it for privacy, not profit.

## Limitations and residual risk

- **Taxes still apply.** In the US, mined cryptocurrency is generally taxable income at its fair market value when received (IRS Notice 2014-21), and crypto-to-crypto swaps can be taxable events. Privacy from the public is not privacy from your tax obligations.
- **Pool-level metadata.** With a centralized pool, the pool links my payout address to my mining sessions.

## Verdict

I am willing to trade convenience for financial privacy. The extra time and effort of acquiring XMR without exchanges is worth it to keep my identity out of centralized databases.

## References

- [XMRig documentation](https://xmrig.com/docs/miner)
- [P2Pool](https://p2pool.io/)
- [IRS Notice 2014-21](https://www.irs.gov/pub/irs-drop/n-14-21.pdf)

---

[← Layer 5 overview](./README.md) · [Stack overview](../README.md)
