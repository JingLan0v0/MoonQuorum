# Resource and error contract

| Input | Limit |
|---|---|
| Members | 1..32, unique IDs |
| ID | 1..64 ASCII letters/digits/underscore/dot/hyphen |
| Each weight | Integer 0..1000 |
| Each policy total | <=4096 |
| Each threshold | 1..its policy total |
| Work budget | Default200000, accepted1..2000000 |
| Unavailable IDs | <=32, unique, known |
| Batch items | <=64, independent per-item budgets |
| CLI text | <=1MiB bytes, strict UTF-8, optional BOM |
| Library JSON source | <=1Mi UTF-16 units, depth<=16 |
| JSON string preflight | <=256 scanned source characters including closing quote |
| JSON outer scan | <=200000 non-whitespace characters outside strings |

Unknown fields, duplicate JSON keys, duplicate IDs, fractional/out-of-range
numbers and unknown outage IDs fail. Zero threshold is invalid even for an empty
policy; unattainable thresholds are errors rather than vacuous intersection claims.
Both-zero members are allowed and harmless; neither policy counts their weight.

Each DP state visit charges one step. Validation, witness generation and
independent proof validation are bounded by input caps but not individually
metered. Budget exhaustion raises limit_exceeded without a conclusion. A batch
may consume64 times its per-item budget; no shared batch budget is implied.

invalid_input: schema/model/option values; invalid_json: grammar/duplicate keys;
limit_exceeded: resource boundary or exhausted budget. Host I/O is a CLI diagnostic.
Single error exits2; valid intersecting/disjoint exits0; item errors in a parsed
batch remain exit0 and must be inspected. No real-time/memory SLA is claimed.

## Migration requests

| Input | Limit |
|---|---|
| Named policies | 1..8, unique IDs |
| Distinct voters across all policies | 1..32 |
| Per-policy voter weight | Integer 1..1000, total <=4096 |
| Ordered stages | 1..16, unique IDs |
| Active policies in each stage | 1..8, unique known IDs |
| Outages in each stage | 0..8, unique scenario IDs within the stage |
| Voters unavailable in one outage | 0..32, unique known IDs |
| Shared pair comparison budget | Default 1000000, accepted 1..2000000 per plan |
| Migration batch | 0..16 plans, independent budgets and item errors |

The outer JSON/text limits above also apply. At most 36 distinct unordered
policy comparisons, including self-comparisons, can be executed. Each is
charged once. A stage includes at most 36 conflict records and 64 per-policy
outage capacity records. Failed analysis raises `limit_exceeded` without a
report. An evaluated but blocked migration is a valid result with exit 0. Read
`status` and `first_failed_stage` when gating a rollout.
