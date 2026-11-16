# Provenance

MoonQuorum core weighted-policy model, knapsack solver, witness verifier, outage
analysis, schema handling and quorum-specific tests were newly implemented here
with AI assistance. No third-party quorum solver code was copied.

Adapted from the author's Apache-2.0 MoonSTN project
https://github.com/JingLan0v0/MoonSTN (source 8eb077356ac3cf1e73ba6cca3ffe188652c6eb44):
cmd/main/host.mbt, CLI argument/error scaffolding, JSON text preflight,
scripts/moon.ps1, installer/CI scaffolding, verifier process/transport scaffolding,
and PowerShell smoke structure. MoonSTN in turn attributes MoonJMES infrastructure.
The new reasoning/oracle is not taken from those projects. LICENSE retains the
Apache-2.0 terms. Core JSON/debug come from the pinned MoonBit standard library.

Conceptual reference: David K. Gifford, Weighted Voting for Replicated Data,
SOSP1979, https://doi.org/10.1145/800215.806583 ; author paper:
https://www.cs.swarthmore.edu/~newhall/readings/gifford79.pdf .
Our program analyzes two supplied global weight vectors. It does not implement
that paper's full replication protocol or claim its protocol guarantees.
The 0/1 knapsack transformation and correctness reasoning are described in
architecture.md. Related ecosystem code is not bundled or used at runtime.
