# Acceptance evidence — 2026-11-16

Local verifier completed at 2026-11-16T09:00:46.513Z using pinned moon/moonc,
Node24.14.0 on Windows. Debug/release each passed 12 MoonBit unit tests,
6561 independent exhaustive weighted-policy comparisons with checked witnesses
and outage results, 18 bad batch items isolated between good neighbors, seven
transport rejections, process I/O/BOM/stdout failure checks, exact maximum-table
budget boundary, three scenarios and the public API example. PowerShell pipeline,
three scenarios and caller-directory restoration passed.

Early development found deprecated generated method promotion, a reserved test
helper name and a JS test-helper length-call typo; these were corrected before
the successful complete run. Historical failures are not counted as passing.

Machine-readable local receipt: local-verification.json.

## Clean delivery verification

Source commit: `a95671a20b30ebec75744c16f4f372f460a6116e`.
Git source ZIP: 47 entries / 39 files; excludes toolchains, credentials, caches,
Git metadata and build products. SHA-256:
`3470a5237d3e65609d6d2c7ed0cb3c23deba5148ac76eee86c22d2b47b2ad441`.
A fresh extraction passed the entire verifier at 2026-11-16T09:06:38.418Z,
including both modes and PowerShell smoke. A separate module then referenced
that extracted package through a local workspace and passed public API checks
in debug/release with warnings denied: intersecting and disjoint outcomes,
independent witness validation, outage capacity, version, exact budget and recovery.
This is a local-source consumer, NOT a registry download. The following docs-only
commit records these observed receipts. See delivery-verification.json.

The desktop proposal is MoonQuorum-十一月项目申报书.md; its repository link remains
pending until the owner creates the repository. The active desktop checkout
retains its Git history and has no remote configured.

Remote CI, public GitHub, registry preflight/publication and registry consumer:
NOT performed; explicitly deferred by the user. Competition approval is not proven.
