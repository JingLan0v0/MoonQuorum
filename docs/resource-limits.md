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
