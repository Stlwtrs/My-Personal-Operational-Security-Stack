# Cryptographic Privacy with Monero

| | |
| --- | --- |
| **Layer** | 5 · Financial Privacy |
| **Status** | ✅ Implemented |
| **Threats mitigated** | Blockchain analysis, transaction-graph tracing, linking addresses to real identity, IP-level transaction tracing |
| **MITRE ATT&CK** | N/A (financial surveillance rather than an intrusion technique) |
| **Last reviewed** | 2026-11-20 |

## Why this control exists

Bitcoin is often mistaken for an anonymous currency, but it is a **pseudonymous, fully transparent ledger**. Every transaction ever made is public. Once any address is linked to a real identity, for example through a KYC exchange, anyone can trace that person's financial history forward and backward.

Blockchain analytics firms such as Chainalysis cluster addresses with heuristics. A classic one is the **common-input-ownership heuristic:** if a transaction spends several inputs, they probably belong to the same wallet. Clustering builds a graph of a wallet's spending habits, counterparties, and balance, and in the worst case connects it back to a person.

**Monero (XMR)** is private by default. It hides the **sender**, the **receiver**, and the **amount** of every transaction, while still letting the network verify that each transaction is valid.

## How it works

The descriptions below reflect Monero's protocol as of **November 2026**.

### 1. Stealth addresses (hiding the receiver)

I can publish a single Monero address, but funds never actually arrive at it on-chain.

- **The math:** a Monero address contains two public keys, a view key **A** and a spend key **B**. For each payment, the sender picks a random scalar *r*, publishes **R = rG** in the transaction, and derives a one-time output key:
  **P = H<sub>s</sub>(rA)·G + B**
  Because *rA = aR* (an elliptic-curve Diffie-Hellman exchange), only I, holding the private view key *a*, can recognize **P** as mine, and only I, holding the private spend key, can spend it.
- **The result:** every payment goes to a fresh, unlinkable one-time address. Outside observers cannot tell that two payments went to the same recipient.

### 2. Ring signatures (hiding the sender)

When I spend an output, I do not sign with just my own key.

- **The math:** the wallet selects **15 decoy outputs** from the blockchain and combines them with my real output into a **ring of 16**. A ring signature proves that *one* member of the ring authorized the spend without revealing which one.
- **Preventing double-spends:** each spend also publishes a **key image**, a value that is unique to the real output but cannot be linked to it. If the same output is ever spent twice, the duplicate key image gives it away.

### 2.1 The future: FCMP++ (full-chain membership proofs)

A ring of 16 is strong but still a *bounded* anonymity set, and statistical analysis over time can sometimes narrow down the real output. **FCMP++** replaces rings entirely: the spender proves in zero knowledge that their output is one of **all outputs on the blockchain** (on the order of 150 million).

**Status (November 2026):** FCMP++ is **not on mainnet**. A test network ("stressnet") forked to FCMP++ on October 5, 2026. There is **no official mainnet fork date**; a developer's non-binding working draft has pointed to activation around early 2027, but those dates have moved before. The upgrade also brings the new **CARROT** addressing scheme.

### 3. RingCT (hiding the amount)

Early Monero hid senders but not amounts. **Ring Confidential Transactions (RingCT)** fixed that.

- **The math:** amounts are hidden in **Pedersen commitments,** which hide a value but still let the network check that inputs equal outputs plus the fee, so no coins are created from nothing.
- **Range proofs:** to prove that the hidden amounts are not negative (which would allow inflation), Monero uses **Bulletproofs+**, a compact zero-knowledge range proof adopted in 2022, replacing the original Bulletproofs.

### 4. Dandelion++ (hiding the source IP)

In most cryptocurrencies, a node broadcasts a new transaction to all its peers at once (a "gossip" protocol). That makes it relatively easy for a well-connected observer to guess which IP address a transaction came from.

- **How it works:** in the **stem** phase, a transaction is passed along a single path from node to node, with a small chance at each hop of switching to the **fluff** phase, where it is broadcast normally.
- **The result:** by the time the transaction reaches the public mempool, its origin is obscured by several hops, similar in spirit to how Tor obscures your IP while browsing.

## Fungibility

Fungibility means every unit of a currency is interchangeable with every other (1 XMR = 1 XMR). Because Bitcoin's history is public, coins linked to a past hack can be "tainted" and refused by exchanges, so not all bitcoins are equal. Monero's history is private, so every XMR is indistinguishable from every other, which makes it the closest thing to digital cash available today.

## My implementation

- XMR is held in the official Monero GUI wallet, used only on [Tails](./tails-usb.md).
- Coins are acquired without KYC (see [P2P Exchanges and Self-Mining](./p2p-exchanges.md)).
- I spend XMR directly with privacy-respecting services, for example to pay for my [Mullvad VPN](../03-Network-Privacy/vpn.md) account.

## Trade-offs

- **Size.** Ring signatures, commitments, and range proofs make Monero transactions much larger than Bitcoin's, so the blockchain is heavier to store and sync.
- **Regulatory pressure and liquidity.** Binance delisted Monero in February 2024, Kraken ended XMR support for European Economic Area clients later that year, and the EU's anti-money-laundering regulation is expected to stop regulated EU crypto providers from handling privacy coins from 2027. Buying and selling XMR keeps getting harder, which is part of why I acquire it without exchanges.

## Limitations and residual risk

- **Network-level privacy depends on how you connect.** Connecting a wallet to a malicious remote node, or "spy nodes" that log IP addresses, can leak metadata. I connect over Tor (via Tails), and running your own node is better still.
- **Behavior can undo cryptography.** Moving coins straight from a KYC exchange to a merchant, or sending unusual amounts at predictable times, creates links that no protocol can hide.
- **Ring signatures are probabilistic privacy** until FCMP++ ships.

## Verdict

For my threat model, cryptographically enforced privacy is worth the larger storage requirements and the growing friction of acquiring XMR.

## Learn more

- **[The Monero Project](https://www.getmonero.org/)**: official website and documentation
- **[Monero Research Lab](https://www.getmonero.org/resources/research-lab/)**: the research behind RingCT, FCMP++, and more
- **[Monero source code (GitHub)](https://github.com/monero-project/monero)**
- **[Monero Outreach](https://www.monerooutreach.org/)**: community education

Monero is often dismissed as "crypto for criminals." The same was said about Bitcoin before it went mainstream. In reality, Monero is used by journalists, activists, and ordinary people who do not want their entire financial lives tracked and monetized.

---

[← Layer 5 overview](./README.md) · [Stack overview](../README.md)
