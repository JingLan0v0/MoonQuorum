# Acceptance evidence — 2026-11-18

## MoonQuorum 0.2.0 staged migration release

Release source: `4262589baedbdd0dcf493776c56defca3797f196`.
Checkout verification completed 2026-11-18T05:11:42.241Z.
Clean package extraction verification completed 2026-11-18T05:11:43.187Z.
Each location passed debug and release with 17 units, 6,561 original
weighted-policy cases, 1,728 exhaustive migration models and 256 seeded
weighted migration models per mode. Both public API samples, all six scenarios,
transport and batch isolation, budget boundaries and PowerShell smoke passed.
The verification report includes the freshly built CLI SHA-256 for each mode.
The independent migration oracle caught and now covers a witness membership
bug where a voter absent from a policy could appear on its side of the report.

[GitHub CI 44242287069](https://github.com/JingLan0v0/MoonQuorum/actions/runs/44242287069)
passed on Windows and Ubuntu for that source. The 49 published files matched
the source commit after line-ending normalization. Mooncakes returned
`202 Accepted` for preflight and `200 OK` for formal publication, both exit 0.
Registry creation timestamp: 2026-11-18T05:12:31.993380+00:00.

The ZIP from a fresh registry cache matched SHA-256
`c99dfa0079a010722217550ae49794049e814c627ad798f3708e8c5cc436aa69`, with all 49 installed files matching the tested package.
The credential-free consumer installed the exact version without a workspace
override. Both modes passed the original API, migration shortfall and first
failed stage, work-budget recovery and migration batch isolation. The public
Mooncakes version page returned HTTP 200.

[Mooncakes 0.2.0](https://mooncakes.io/docs/JingLan0v0/quorum@0.2.0) ·
[Machine-readable receipt](publication-0.2.0.json) ·
[Revision and competition status](competition.md).

The follow-up documentation commit records these observations. They cover
technical delivery for the revised project. Organizer re-review is pending.

## Historical evidence — 2026-11-16

## GitHub and Mooncakes publication — 2026-11-16

The owner supplied https://github.com/JingLan0v0/MoonQuorum and explicitly authorized
both uploads. The public repository was independently verified empty and not archived.
Normal push preserved both original commits; no force push. Publication source:
`5e1b46af506c1aba66f32e08b126cb9298fd427c`.
[CI run 43847756029](https://github.com/JingLan0v0/MoonQuorum/actions/runs/43847756029)
passed Windows and Ubuntu on that exact SHA before publication.

Fresh local verifier: 2026-11-16T10:18:29.339Z; actual package extraction verifier:
2026-11-16T10:19:31.632Z. Each passed debug/release: 12 units, 6561 exhaustive
policy cases, 18 bad batch items, seven transport rejects, all process/scenario
checks. PowerShell smoke passed in both checkout and extraction.

Actual Mooncakes ZIP: 37 tracked files, excludes Git metadata, CI/ignore files,
credentials, toolchains, caches and build outputs. SHA-256:
`9b913e2e8481e432b22482e925f248bc8be20d0cffb4e54f041ed08df95a2813`.
Preflight returned `202 Accepted`, actual publication returned `200 OK`, both exit0.
Registry creation timestamp: 2026-11-16T10:20:28.306014+00:00 (18:20:28 Asia/Shanghai).

A new credential-free empty cache installed JingLan0v0/quorum@0.1.0 without local
workspace/path substitution. Debug/release with warnings denied passed version,
intersecting/disjoint outcomes, independent witness validation, outage capacity,
exact budget threshold and recovery. All 37 downloaded files and ZIP digest match.
See [publication-0.1.0.json](publication-0.1.0.json). Desktop proposal now includes
actual repository and Mooncakes links. The following docs-only commit records
these receipts; the immutable package remains tied to the source above.

Earlier sections below are historical local preparation. Their upload deferral
has been superseded; competition approval is still not implied.

## Initial local preparation

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
