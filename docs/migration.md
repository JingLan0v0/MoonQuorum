# Review a staged voting configuration migration

Use MoonQuorum before rolling out changes to weighted voting policies. List each
policy once and declare which policies can coexist at each deployment step. For
each stage the report checks whether any two threshold-reaching sets can be
disjoint, and whether each active policy still reaches its threshold under each
named outage. The first failed stage points to a concrete rollout decision.

```sh
moon run cmd/main --target js -- --migration examples/migration-ready.json
moon run cmd/main --target js -- --migration examples/migration-bridge.json
moon run cmd/main --target js -- --migration examples/migration-outage.json
moon run examples/migration --target js
```

| Example | What to check | Expected result |
|---|---|---|
| migration-ready.json | Old policy, coexistence, then new policy. Either voter b or d is absent in separate cases. | ready. Every active threshold remains reachable in the listed cases. |
| migration-bridge.json | Both endpoints require voter a. The bridge only requires voter b. | blocked at introduce-bridge. Old quorum [a,c] and bridge quorum [b] are disjoint. A later stage has a separate bridge/new conflict. |
| migration-outage.json | Voters c and d are offline in the coexistence stage. | blocked at maintenance. All intersections pass. Old policy has 3 of 3 required weight, new policy has 3 of 4. |

## Input

```json
{
  "policies": [
    {"id":"old","voters":[{"id":"a","weight":2}],"threshold":2},
    {"id":"new","voters":[{"id":"a","weight":3}],"threshold":3}
  ],
  "stages": [
    {"id":"before","active":["old"]},
    {"id":"overlap","active":["old","new"],"outages":[{"id":"a-down","unavailable":["a"]}]},
    {"id":"after","active":["new"]}
  ]
}
```

Stages are ordered by deployment sequence. Include every policy that can coexist
in each stage, including any old policy still in use by another process. For
each stage, the unordered pairs include a policy paired with itself. This
detects a single policy with two disjoint threshold-reaching subsets. The tool
compares only declared active sets, so rollout coverage depends on the supplied
model. List transition stages explicitly when policies may coexist across steps.

Use the same voter ID for the same entity throughout. A voter absent from a
policy contributes zero to that policy. Voters listed in a policy have positive
integer weights. Omitted outages default to an empty list. An outage may contain
a voter known to the model but absent from the stage. That voter contributes
zero lost weight to any policy it does not belong to. Outages are separate
scenarios. Put multiple voter IDs in one scenario for a simultaneous failure.

## Output and library

- `ready` means every declared stage passes the tested properties. `blocked`
  means at least one check fails. `first_failed_stage` is a stage ID or null.
- `stages` includes every stage in input order. Each conflict names the two
  policies and two disjoint sets made only of those policies' voters. Each
  outage lists remaining weight, threshold and shortfall per active policy.
- `pair_checks` counts unique unordered pairs. `work_steps` counts DP visits
  across the whole report. Reversed/repeated pairs share one computed result.
- Both valid statuses exit 0. Consumers can gate rollout on the JSON status.
  Invalid input and work exhaustion exit 2 with empty stdout for single requests.
  The `--migration-batch` mode accepts up to 16 requests and isolates item errors.
  Use `-` as the file argument to read standard input.

Call `check_migration(policies, stages, max_steps=1000000)` for typed results.
`analyze_migration` and `analyze_migration_batch` wrap the same library for JSON
integration. The executable in `examples/migration` exercises the typed API.

Full policy membership is used for intersection checks. Removing voters can
only reduce the quorum families, so an outage cannot create an intersection
counterexample that was absent from the full sets. Capacity is evaluated for
each declared outage and each policy independently. The conclusions cover
weighted set intersection and threshold reachability for the supplied models.
Protocol safety, network communication and rollback execution require separate
evidence.

See [resource limits](resource-limits.md) and [algorithm](architecture.md).
