# MoonQuorum 0.3.6 published — 2026-11-28

Published from `05f188a73590c14b56435b7c1f6e1ae3b0c8ff75`. The 50,000-query local outage benchmark returned the same totals. Across nine alternating runs the median batch time was 151.4 ms before and 134.8 ms after. The validated membership index is private.
See [acceptance](acceptance.md) for the public archive and exact install verification.

# MoonQuorum 0.3.5 published — 2026-11-28

Published from `6f4d6e7eabc6b866cd305577ca5146f8349bf121`. The regression reproduced a valid witness being rejected in 0.3.4 after clearing the publicly readable member array. The private snapshot now protects intersection checks, witness verification and outage results.
See [acceptance](acceptance.md) for the public archive and exact install verification.

# MoonQuorum 0.3.4 published — 2026-11-28

Published from `d24b04d05efd740fd0c4be17aa74c90a24d4840a`. Both builds agreed on the results of 50,000 verification calls. The median elapsed time for nine alternating CLI batches on the local machine was 372.4 ms before and 262.2 ms after.
See [acceptance](acceptance.md) for the verified ZIP and exact-version consumer.

# MoonQuorum 0.3.3 published — 2026-11-27

Published from `2446173e1acf4191caf6bfad1aa0dc99f4502d24`. The solver skips states below the minimum reachable threshold. A 64-request comparison produced byte-identical reports. The first fixture visits 1,591 states, down from 59,311.
The exact public package installs and passes both modes. See
[acceptance](acceptance.md) for CI and registry receipts.

# MoonQuorum 0.3.2 published — 2026-11-27

Published from `9573c9641bf02940c08b5af91fa9d7a9ee0be511`. The public ZIP and exact-version install
were verified. See [acceptance](acceptance.md) for release evidence.

# Local intersection optimization — 2026-11-27

A disjoint choice contributes at most the larger of the two weights for each
voter. The solver returns intersection when their sum cannot reach the two
thresholds together. It checks the original work charge before this proof.
At equality the solver still checks for a disjoint witness.

Both local builds passed 26 unit tests, 6,561 independent weighted cases,
1,984 migration models, 256 domain models and 64 exact-number comparisons.
PowerShell smoke passed. Two clean Release CLI builds produced byte-identical
reports for 64 high-threshold requests. In the first 32-voter fixture, the
previous loop bounds scanned 47,983 states and the new proof needs no table.

# Local solver optimization — 2026-11-26

The pair solver scales the left weights by their greatest common divisor and
rounds the threshold up in those units. It preserves the full-table work charge
and the order of witness ties. A regression checks a threshold between two
reachable weight totals.

Debug and release each passed 25 units, 6,561 independent weighted cases,
1,984 migration cases, 256 domain models and 64 exact-number comparisons.
PowerShell smoke passed. A separate 320-request CLI comparison with a fresh
build of 0.3.1 produced byte-identical output. For the 32-voter uniform-weight
fixture, the loop bounds reduce scans from 15,376 to 136 states per request;
the charged budget remains 65,568.

# MoonQuorum 0.3.1 published - 2026-11-26

Published from 7f47897de578b02e3020db0c35ce2039ea3271ab. The public registry download
and exact-version consumer were verified. See [acceptance](acceptance.md)
for CI, archive and installation evidence.

# Local optimization — 2026-11-26

The intersection solver skips zero-left-weight voters and limits each descending
pass to states the earlier voters could have reached. Both pair and migration
budget accounting still charge the original full table. The 32-voter regression
checks the exact budget boundary and verifies the deterministic disjoint witness.

The local debug and release verifiers each passed 24 units, 6,561 weighted-policy
cases, 1,984 migration models, 256 domain-outage models and 64 exact number
comparisons. PowerShell smoke passed. A separate 64-request release comparison
produced byte-identical output. For that workload the inner loop scanned 15,376
states per model instead of 65,568. The median elapsed batch times across nine
alternating pairs, including CLI startup, were 124.7 ms and 123.1 ms.


# MoonQuorum 0.3.0 — 2026-11-25

Published source `05cc1591aebbf228bb7213788a7788ba8611bfef` implements correlated failure-domain witnesses
and validates exact decimal integer input. The one-command MVP
`node examples/demo.mjs`, the Windows/Ubuntu CI, extracted package and
fresh registry installation all passed. Details in acceptance.md and
publication-0.3.0.json. The revised desktop proposal includes actual source,
test and package links.

Earlier release evidence follows.

# Active revision — 2026-11-18

MoonQuorum 0.2.0 implements staged migration review. Each stage checks all
declared coexisting weighted policies, checks named outages and points to the
first failure. See migration.md, architecture.md and competition.md. Preserve
the repository history and the existing 0.1.0 package.

Release source `4262589baedbdd0dcf493776c56defca3797f196` passed full verification
in the checkout and a fresh extraction of the publisher archive. CI 44242287069
passed on Windows and Ubuntu. Mooncakes 0.2.0 is published, and a fresh exact
consumer passed debug and release. The downloaded ZIP and all 49 installed files
match the tested package. See acceptance.md and publication-0.2.0.json.

Desktop proposal: C:/Users/XJY/Desktop/MoonQuorum-十一月项目申报书-修订版.md.
The participant can update the original form before the date in the rejection
notice. The revised technical delivery awaits organizer re-review.

# MoonQuorum handoff — 2026-11-16

Active project: C:/Users/XJY/Desktop/moonbit-quorum. Version0.1.0 published and verified.
On 2026-11-16 the user supplied https://github.com/JingLan0v0/MoonQuorum and
authorized normal GitHub upload and Mooncakes publication. Earlier deferral is superseded.

Implemented: weighted pair validation/snapshots; exact capped knapsack analysis;
independent disjoint witness verifier; named-outage capacity analysis; bounded
JSON/batch/CLI; three examples and independent subset oracle. The model covers
two global threshold policies only, not consensus execution or protocol safety.

Use toolchain.json. Local MOON_HOME:
C:/Users/XJY/Desktop/MoonBit黑客松/.tools/moonstn-toolchain (external shared compiler).
No credential file is copied. Run node scripts/verify.mjs and PowerShell smoke.
Read acceptance.md for actual receipts; Windows/Ubuntu CI and registry consumer passed.

Continue by checking Git status, preserving history, reading competition.md and
publishing.md, and using the repository supplied by the user. Update actual links
only after creation. Do not mistake local archive/consumer checks for publication.

## Delivery evidence

Source a95671a20b30ebec75744c16f4f372f460a6116e passed clean-source extraction,
full debug/release checks and an independent extracted-source library consumer.
See acceptance.md and delivery-verification.json. The following documentation
commit records receipts; keep it and the source history when uploading later.
Desktop proposal: C:/Users/XJY/Desktop/MoonQuorum-十一月项目申报书.md.

## Published delivery — 2026-11-16

Repository https://github.com/JingLan0v0/MoonQuorum is public and was verified empty
before the normal initial push; original history was preserved. Source
5e1b46af506c1aba66f32e08b126cb9298fd427c passed fresh full local/package tests and
Windows/Ubuntu CI 43847756029. Mooncakes JingLan0v0/quorum@0.1.0 returned 200 OK.
A new credential-free cache installed the exact version and passed debug/release
public API assertions with no local workspace dependency. All 37 downloaded files
match the archive. See publication-0.1.0.json. Desktop proposal now uses real links.
Earlier local-only status is historical. No competition form was submitted.
