# Architecture

For a subset S chosen as a left quorum, a disjoint right quorum exists exactly
when the complement has right weight >= its threshold: nonnegative weights make
the full complement the largest possible right weight disjoint from S.
Thus minimize the right-weight cost of a subset whose left weight reaches q.

The 0/1 knapsack state cost[t] is the minimum right cost at capped left total t,
0 <= t <= q. Initialize cost[0]=0, all others=4097. Process members in input order,
scanning states downward; a transition caps t+left_weight at q and adds the
member's right weight. Strict improvements retain deterministic ties. Int64 masks
carry immutable membership witnesses (32 bits used), avoiding mutable predecessor
chains. A zero-left-weight item cannot improve cost. At the saturated q state,
self-transitions cannot improve because weights are nonnegative. Descending
traversal therefore never selects the current item twice.

A disjoint witness exists iff cost[q] <= total_right - right_threshold. Its left
set is the stored mask and its right set the complement. Otherwise every left
quorum intersects every right quorum. This does not prove any consensus protocol
correct. The result is exact for the documented two global threshold families.

Complexity O(n*q), storage O(q+n); <=131104 charged state visits with n<=32,
q<=4096. Every visited state consumes one step, including unreachable ones.
Default 200000 covers all valid model sizes. All budget state is local to one
check; exhaustion leaves the reusable validated Pair unchanged. All weight sums
are <=4096, costs use sentinel4097, masks use at most32 of64 bits.

Pair snapshots the public array of immutable Member values. The members getter
copies its array; witness arrays are new per check. The independent verifier
uses only original weights, ID sets and sums; it does not call the solver.

The test oracle enumerates all two-subset pairs of three voters for every weight
assignment in {0,1,2}^6 and every valid threshold pair: 6561 cases. It checks actual
witnesses and outage weights too. This is independent of the dynamic program,
but finite and restricted to small weights. Separate tests cover 32 members,
4096 totals, the highest witness bit, budgets, invalid models and array reuse.

core.mbt owns validation/reasoning; json.mbt owns exchange. cmd/main/host.mbt owns
Node file/process I/O only. scripts/verify.mjs is test code, not a runtime solver.

## Staged migration

Input declares named weighted policies, ordered stages, and the policy IDs that
can coexist in each stage. Each stage checks unordered active-policy pairs with
repetition, including self-intersection. Pair keys use the numeric indices from
validation; that supplies a canonical orientation independent of stage order.
The hash table stores only evaluated pairs and is local to one request.

Build each comparison over the union of its voter IDs and reuse the existing
exact weighted intersection solver. The shared budget charges the precise
number of states the solver visits (union size times left threshold plus one,
with the threshold incremented before multiplication). Reserve this cost before
calling the solver. A short budget aborts the whole request without a partial
conclusion. Outages subtract each named voter's contribution from the total of
each active policy. They are independently evaluated against its threshold.

The pair solver's complement can include voters whose weight on its right side
is zero. The migration report filters each witness to voters listed in that
policy. This preserves the sums and disjointness and gives each stage a fresh
array so caller edits cannot affect another occurrence of the pair. The two-policy
interface retains its original witness semantics.

The independent migration oracle constructs all threshold-reaching subsets
for each policy, compares every declared pair, checks returned witness membership
and sums, recomputes capacity, and checks the first failing stage. It covers all
1,728 triples in a three-voter binary-weight family and 256 deterministic seeded
weighted plans. These cases complement the existing 6,561 pair-policy cases.
