# Ecosystem review — 2026-11-16

Checked current Mooncakes registry index fetched on November16, public GitHub
sources and web queries for functional dependencies, graph dominance, quorum,
weighted voting and MoonQuorum. No claim of complete ecosystem coverage or
name ownership. Repeat before formal application/publication.

| Related project | Observed scope | Boundary |
|---|---|---|
| moonbitstack/moonraft 0.8.0, Apache-2.0 | Raft protocol, membership, replication; registry metadata and published membership/readindex APIs | MoonQuorum is an offline checker of two arbitrary nonnegative weighted policies; no Raft state machine or protocol claims |
| Kali-Leo/moonbit-CryptoAssert | README and multisig quorum-intersection lemma: crypto/assertion/proof infrastructure | This project returns concrete disjoint sets for heterogeneous per-member weights, with explicit outages and CLI; no cryptography or formal protocol proof |
| LuoYunxin1/moonnormal 0.1.2, MIT | Database functional dependencies/normalization/decomposition | Rejected initial idea due to close overlap; no database normalization implemented |
| Novanke/cairndom 0.4.0, Apache-2.0 | Dominance/frontiers/loops/exit-path analysis | Rejected graph-dominance direction; no control-flow analysis implemented |

Links: https://github.com/moonbitstack/moonraft ;
https://github.com/Kali-Leo/moonbit-CryptoAssert ;
https://github.com/LuoYunxin1/moonnormal ; https://github.com/Novanke/cairndom .
The moonraft README retrieval was unavailable through the connector; scope and
license above are supported by current registry metadata and indexed public APIs.

Relative to the user's MoonSTN/MoonJMES/MoonPatch: no temporal difference
constraints, JSON query language or patch processing. Host I/O and development
infrastructure are reused with attribution; weighted analysis and tests are new.
The mathematical problem and knapsack algorithm are established techniques,
not claimed inventions. The deliverable is a bounded, checkable MoonBit API/CLI.

## Migration scope update — 2026-11-18

The new workflow checks explicit coexistence and outage models offline. It can
be used before a protocol-specific rollout. MoonRaft owns a Raft implementation
and membership behavior. MoonQuorum uses arbitrary supplied weights and compares
static threshold families over several steps. The tool relies on the caller
to enumerate the policies that may coexist. This comparison describes the
reviewed libraries and does not establish that all MoonBit alternatives were found.
