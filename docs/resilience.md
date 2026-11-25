# Failure-domain capacity review

Run the weighted migration checks together with correlated outage analysis:

    moon run cmd/main --target js -- --resilience examples/resilience-concentrated.json

The request has the migration fields policies, stages and optional max_steps.
It adds failure_domains (array of objects with id and voters) and
max_domain_failures, the number of simultaneous domain outages to tolerate.

| Input | Required property |
| --- | --- |
| failure_domains | 1 to 32 nonempty domains with unique IDs |
| voters per domain | 1 to 32 named voters, assigning every voter in the policies once |
| max_domain_failures | Integer from zero through the number of domains |

Use the same domain for nodes sharing a power, network, or site failure.
The partition makes each correlated outage count distinct node weights once.
Named outages are checked as individual scenarios. The declared domain count
is checked independently against full membership.

Each policy result reports its minimum number of lost domains that makes its
weight insufficient, the domain IDs witnessing that cut, and remaining weight
after the witness. Worst remaining weight is computed at the requested domain
count. It may equal the threshold and still pass. The earliest blocked stage
is the first explicit migration failure or the first stage containing a policy
that fails the domain-capacity requirement. The existing migration report is
included for inspection.

The library exposes check_resilience, analyze_resilience and
analyze_resilience_batch. CLI --resilience-batch supports up to 16 isolated
requests. Valid ready or blocked reports exit 0. Invalid input, unavailable
I/O and exhausted migration work budgets exit 2. Inspect status for decisions.

The minimum follows from an ordering argument. For any k disjoint domains,
their combined weight is at most the sum of the k heaviest domains. Sorting
once per policy gives every worst-case prefix. The first prefix whose removal
falls below the threshold is a minimum-cardinality witness. Equal weights
are ordered by domain ID. The witness can be checked by summing original
policy weights outside the named domains. This result concerns available
voting weight under the modeled outages.
