# Acceptance evidence — 2026-11-25

## Mooncakes 0.3.4 — 2026-11-28

Release source: `d24b04d05efd740fd0c4be17aa74c90a24d4840a`. [GitHub Actions](https://github.com/JingLan0v0/MoonQuorum/actions/runs/46043599978) passed
on Windows and Ubuntu for this commit. The 62 archive files
match the release source. Full Debug, Release and PowerShell checks passed
after clean extraction. Both builds agreed on the results of 50,000 verification calls. The median elapsed time for nine alternating CLI batches on the local machine was 372.4 ms before and 262.2 ms after.

Mooncakes preflight returned 202 Accepted and publication returned 200 OK.
The [public version](https://mooncakes.io/docs/JingLan0v0/quorum@0.3.4) returned HTTP 200.
The [public ZIP](https://download.mooncakes.io/user/JingLan0v0/quorum/0.3.4.zip) and tested publisher ZIP match the
registry SHA-256 `dca4c36f63e217f8571ded49a9d3bf8dd8a2d65d86c3cf89441db7a1d6012b32`. Registry timestamp: 2026-11-27T17:42:04.275929+00:00.

An anonymous consumer installed `JingLan0v0/quorum@0.3.4` using a fresh cache. All
62 installed files matched the public ZIP byte for byte.
Debug and Release passed. The consumer verified a full witness and rejected overlapping or unknown voter IDs.

## Mooncakes 0.3.3 — 2026-11-27

Release source: `2446173e1acf4191caf6bfad1aa0dc99f4502d24`. [GitHub Actions](https://github.com/JingLan0v0/MoonQuorum/actions/runs/45956452413) passed
on Windows and Ubuntu for this commit. All 62 archive files
match the release source. Full Debug, Release and PowerShell verification
passed after clean extraction. The solver skips states below the minimum reachable threshold. A 64-request comparison produced byte-identical reports. The first fixture visits 1,591 states, down from 59,311.

Mooncakes preflight returned 202 Accepted and publication returned 200 OK.
The [public version](https://mooncakes.io/docs/JingLan0v0/quorum@0.3.3) returned HTTP 200.
The [registry ZIP](https://download.mooncakes.io/user/JingLan0v0/quorum/0.3.3.zip) and the tested publisher ZIP
match the public SHA-256 `d746b6eef5dcb16fb8e6661c9160b6b7ff23f923aafcd21e3dc9dbdd1d1588d9`.
Registry publication timestamp: 2026-11-27T15:10:34.1296140+08:00.

An anonymous consumer installed `JingLan0v0/quorum@0.3.3` from a fresh cache.
All 62 installed files matched the public ZIP.
Debug and Release passed. The installed build verified the near-threshold disjoint witness.

## Mooncakes 0.3.2 — 2026-11-27

Release source: `9573c9641bf02940c08b5af91fa9d7a9ee0be511`. [GitHub Actions](https://github.com/JingLan0v0/MoonQuorum/actions/runs/45955481203) passed
on Windows and Ubuntu for this commit. The archive contained 62
files matching the source. Full Debug and Release verification and the
PowerShell smoke test passed after clean extraction.

Mooncakes preflight returned 202 Accepted and publication returned 200 OK.
The [version page](https://mooncakes.io/docs/JingLan0v0/quorum@0.3.2) returned HTTP 200.
The [public ZIP](https://download.mooncakes.io/user/JingLan0v0/quorum/0.3.2.zip) and the tested publisher ZIP share SHA-256
`7c07665ed278376a9a5908cf8c488709f93a93b7f975bca9bb5a5bd9b1f5b5cc`. The public metadata records 2026-11-27T15:01:53.4858960+08:00.

A clean consumer installed `JingLan0v0/quorum@0.3.2` from Mooncakes without a workspace
override or registry credentials. All 62 installed files
matched the ZIP byte for byte. Debug and Release passed. The consumer exercised the disjoint-weight bound, equality witnesses and the original work charge.

## Mooncakes 0.3.1 - 2026-11-26

Release source: 7f47897de578b02e3020db0c35ce2039ea3271ab. The [GitHub Actions run](https://github.com/JingLan0v0/MoonQuorum/actions/runs/45763252075) passed on
Windows and Ubuntu for that commit. Full debug and release verification
and PowerShell smoke passed on a clean extraction of the publisher ZIP.

Mooncakes returned 202 Accepted for preflight and 200 OK for publication.
The [public version page](https://mooncakes.io/docs/JingLan0v0/quorum@0.3.1) returned HTTP 200. The
[registry ZIP](https://download.mooncakes.io/user/JingLan0v0/quorum/0.3.1.zip) SHA-256 equals the tested
publisher ZIP and the public metadata checksum:
e1d673a8649d8416e10992dfec2b0f70066aef9b05890cf81faac91fc12e90e9

An independent consumer installed JingLan0v0/quorum@0.3.1 from the public
registry using a fresh cache without credentials or a workspace override.
All 62 installed files matched the publisher ZIP byte for byte.
Both installed builds verified the exact work-budget boundary and a disjoint witness for a 32-voter pair.
Registry publication timestamp: 11/26/2026 14:15:12.

## MoonQuorum 0.3.0

Published from `05cc1591aebbf228bb7213788a7788ba8611bfef` at 2026-11-25T10:33:42.734299+00:00.
[CI 45595756279](https://github.com/JingLan0v0/MoonQuorum/actions/runs/45595756279)
passed Windows and Ubuntu for this SHA. The exact reviewer command
`node examples/demo.mjs` succeeded with four assertions in the clean checkout.
The legacy 0.2.0 release CLI was identified by the digest in its acceptance
receipt. All six legacy fixture reports matched byte for byte, including
output streams and exit codes.

The actual publisher archive contained 61 tracked files, equal to the
release source after newline normalization. Its separate extraction passed
debug/release, PowerShell, 23 unit tests per mode, 6,561 two-policy cases,
1,984 migration cases, 256 independent domain-outage cases and 64 decimal
integer comparisons per mode. Verification completed at 2026-11-25T10:33:07.343Z.

The old parser reproduced accepting the weight 1.00000000000000001 as 1.
The revised parser checks the preserved decimal token and rejects fractional,
out-of-range or forged representations. Equivalent integral decimal and
exponent forms still pass. The domain witness is checked in the oracle by
enumerating independent outage subsets and summing surviving weights.

Mooncakes preflight returned 202 and formal upload returned 200. The version
page is public. A fresh credential-free consumer installed the exact version
without a workspace override. Both modes confirmed exact integer rejection
and a correlated outage witness. The downloaded ZIP and all 61 installed
files match the tested package. SHA-256 `07bc2a70269a6cb2d5914dac8a26a29842139e72383e8c4c526d89831e9c0910`.

[Registry version](https://mooncakes.io/docs/JingLan0v0/quorum@0.3.0) ·
[Machine-readable release proof](publication-0.3.0.json)

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
