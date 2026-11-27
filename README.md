# MoonQuorum

An offline MoonBit library and CLI for reviewing **staged weighted voting
configuration changes**. It checks the policies that can coexist at each rollout
step, finds disjoint voter sets as counterexamples, and locates threshold
shortfalls under named outages. The original two-policy API remains available.

[中文说明](README.zh-CN.md) · Apache-2.0 · Pure MoonBit core · JS backend

Version 0.3.3. Repository: [JingLan0v0/MoonQuorum](https://github.com/JingLan0v0/MoonQuorum).
Published: [JingLan0v0/quorum@0.3.2](https://mooncakes.io/docs/JingLan0v0/quorum@0.3.2).
Actual registry and CI receipts: [acceptance](docs/acceptance.md).

## Run the verified failure-domain scenarios

Install the pinned versions from toolchain.json and run from the repository root:

    node examples/demo.mjs

The command builds the CLI and checks a concentrated layout, a balanced layout,
the first affected migration stage, and invalid overlapping domains. Use
`--resilience` to evaluate a file or `--resilience-batch` to check several
plans. See the [input and output contract](docs/resilience.md).

## Review a migration

```sh
moon run cmd/main --target js -- --migration examples/migration-ready.json
moon run cmd/main --target js -- --migration examples/migration-bridge.json
moon run cmd/main --target js -- --migration examples/migration-outage.json
moon run examples/migration --target js
```

These examples check a viable rollout, a disjoint quorum in a bridge stage, and
an outage that leaves a policy one vote short. `check_migration` exposes typed
stage results. `analyze_migration` and `analyze_migration_batch` expose the same
checks as JSON. See [request schema, results and examples](docs/migration.md).

## Two-policy scenarios

| Scenario | Command argument | Result and decision |
|---|---|---|
| Read/write configuration review | `examples/read-write.json` | Three equal voters, both thresholds 2: `intersecting` |
| Membership rollout review | `examples/rollout.json` | Old/new voters carry different weights: `disjoint`, with authentic witness sets |
| Maintenance planning | `examples/maintenance.json` | East unavailable: left weight 1 cannot meet 2; right weight 2 can meet 2 |

```sh
moon run cmd/main --target js -- examples/read-write.json
moon run cmd/main --target js -- examples/rollout.json
moon run cmd/main --target js -- examples/maintenance.json
moon run examples/library --target js
node scripts/verify.mjs
```

Use the pinned toolchain in `toolchain.json` and Node 24.14.0. On the author's
Windows machine `./scripts/moon.ps1` locates the shared external toolchain. It
also accepts `MOON_HOME`. The verifier additionally accepts `MOON_BIN`.
Core has no runtime third-party dependencies. Node provides only CLI I/O.

## Input and result contract

```json
{"members":[{"id":"old","left_weight":3,"right_weight":0},{"id":"new","left_weight":0,"right_weight":3}],"left_threshold":2,"right_threshold":2,"unavailable":[]}
```

Member IDs identify the **same physical voter** across the policies. Zero weight
models absence from one policy. Both thresholds must be positive and achievable
before outages. Unknown fields/IDs and duplicate IDs are errors. Defaults:
`unavailable=[]`, `max_steps=200000`. Detailed limits: [resource contract](docs/resource-limits.md).

Results contain `status`, both `*_available_weight` values and both
`*_available` booleans. `disjoint` additionally includes `left_witness` and
`right_witness`; verify them with `verify_disjoint`. Witnesses follow input order,
are deterministic, and need not be minimal-cardinality quorums.

Intersection is evaluated for the full supplied policies; outages affect only
availability fields. Outage counts are capacity checks, not probabilistic uptime
or evidence of actual communication. No request contacts a server.

`intersecting` is a mathematical property of the supplied weighted sets, **not a
proof of consensus safety, Byzantine resilience or liveness**. Member identities,
weights and thresholds are trusted configuration input, not discovered facts.
No signatures, logs, elections, leases, nested/federated quorum slices, dynamic
reconfiguration protocol, or operational rollout approval are implemented.

`moon-quorum [--batch] <file|->` reads a file or stdin. Single valid results
(including `disjoint`) exit 0. Malformed/schema/budget/I/O failures exit 2 with
empty stdout. `--batch` takes up to 64 requests; item errors become `status:error`
without poisoning neighbors. Malformed whole batch input exits 2. On stdout
failure a partial output may already exist; check process status. `--version`
and `--help` are supported. JSON uses strict UTF-8 (optional BOM); duplicate keys
are rejected and diagnostics escape control characters.

## Install the library

In a consumer MoonBit module:

```sh
moon add JingLan0v0/quorum@0.3.2
```

Import `JingLan0v0/quorum` in `moon.pkg`. See `examples/library/main.mbt` for usage.
The command examples above run from a source checkout.

## Public library

`pair(members,left_threshold,right_threshold)` validates and snapshots input.
`check_intersection(pair,max_steps=200000)` returns `Intersecting` or
`Disjoint(left,right)`, or raises `QuorumError(code,message)`.
`verify_disjoint(pair,left,right)` independently checks authenticity, uniqueness,
disjointness and both sums. `availability(pair,unavailable)` returns
`(left_weight,right_weight,left_possible,right_possible)`.
`parse_json`, `analyze`, `analyze_batch` provide bounded JSON integration.
`Pair::members()` returns a copy. See [local consumer setup](docs/local-consumer.md)
and `examples/library/main.mbt` for a runnable consumer.

## Verification and delivery

```sh
moon fmt --check
moon check --target js --deny-warn
moon test --target js --deny-warn
moon info --target js
node scripts/verify.mjs
```

The verifier checks debug and release against an independent enumeration of all
pairs of subsets for 6,561 three-voter weighted-policy cases, validates every
counterexample and outage result, tests malformed input/budgets/process I/O, and
runs all examples. It also checks 1,728 exhaustive and 256 seeded migration
plans in each mode, recomputing capacity and validating the reported stages and
witness memberships. The verifier builds a fresh CLI and records its digest.
Windows/Ubuntu CI is configured; actual run receipts are recorded separately. See [actual evidence](docs/acceptance.md),
[architecture](docs/architecture.md), [ecosystem comparison](docs/ecosystem.md),
[competition checklist](docs/competition.md) and [publishing](docs/publishing.md).
