///|
pub(all) struct Voter {
  id : String
  weight : Int32
}

///|
pub(all) struct PolicySpec {
  id : String
  voters : Array[Voter]
  threshold : Int32
}

///|
pub(all) struct Outage {
  id : String
  unavailable : Array[String]
}

///|
pub(all) struct MigrationStage {
  id : String
  active : Array[String]
  outages : Array[Outage]
}

///|
pub(all) struct PolicyConflict {
  left_policy : String
  right_policy : String
  left_witness : Array[String]
  right_witness : Array[String]
}

///|
pub(all) struct PolicyCapacity {
  policy : String
  remaining : Int32
  threshold : Int32
  shortfall : Int32
}

///|
pub(all) struct OutageReport {
  scenario : String
  capacities : Array[PolicyCapacity]
}

///|
pub(all) struct StageReport {
  stage : String
  conflicts : Array[PolicyConflict]
  outages : Array[OutageReport]
}

///|
pub(all) struct MigrationReport {
  first_failed_stage : String?
  stages : Array[StageReport]
  pair_checks : Int32
  work_steps : Int32
}

///|
priv struct IndexedPolicy {
  id : String
  voters : Array[Voter]
  weights : Map[String, Int32]
  threshold : Int32
  total : Int32
}

///|
fn take_unique(
  names : Map[String, Bool],
  name : String,
  kind : String,
) -> Unit raise QuorumError {
  if !valid_id(name) || names.contains(name) {
    raise QuorumError(
      "invalid_input",
      "invalid or duplicate " + kind + " id: " + name,
    )
  }
  names[name] = true
}

///|
fn index_policy(spec : PolicySpec) -> IndexedPolicy raise QuorumError {
  if spec.voters.length() < 1 || spec.voters.length() > 32 {
    raise QuorumError("limit_exceeded", "require 1..32 voters per policy")
  }
  let unique : Map[String, Bool] = Map([])
  let weights : Map[String, Int32] = Map([])
  let mut total = 0
  for voter in spec.voters {
    take_unique(unique, voter.id, "voter")
    if voter.weight < 1 || voter.weight > 1000 {
      raise QuorumError("invalid_input", "voter weights must be in 1..1000")
    }
    weights[voter.id] = voter.weight
    total += voter.weight
  }
  if total > 4096 {
    raise QuorumError("limit_exceeded", "policy total weight exceeds 4096")
  }
  if spec.threshold < 1 || spec.threshold > total {
    raise QuorumError(
      "invalid_input", "threshold must be 1..total policy weight",
    )
  }
  {
    id: spec.id,
    voters: spec.voters,
    weights,
    threshold: spec.threshold,
    total,
  }
}

///|
fn policy_comparison(
  left : IndexedPolicy,
  right : IndexedPolicy,
) -> Pair raise QuorumError {
  let members : Array[Member] = left.voters.map(v => {
    id: v.id,
    left_weight: v.weight,
    right_weight: right.weights.get(v.id).unwrap_or(0),
  })
  for voter in right.voters {
    if !left.weights.contains(voter.id) {
      members.push({ id: voter.id, left_weight: 0, right_weight: voter.weight, })
    }
  }
  pair(members, left.threshold, right.threshold)
}

///|
fn validate_stages(
  stages : Array[MigrationStage],
  policy_ids : Map[String, Int32],
  voters : Map[String, Bool],
) -> Array[Array[Int32]] raise QuorumError {
  let stage_ids : Map[String, Bool] = Map([])
  stages.map(stage => {
    take_unique(stage_ids, stage.id, "stage")
    if stage.active.length() < 1 || stage.active.length() > 8 {
      raise QuorumError(
        "limit_exceeded", "require 1..8 active policies per stage",
      )
    }
    if stage.outages.length() > 8 {
      raise QuorumError("limit_exceeded", "at most 8 outage cases per stage")
    }
    let active_ids : Map[String, Bool] = Map([])
    let active = stage.active.map(id => {
      take_unique(active_ids, id, "active policy")
      guard policy_ids.get(id) is Some(index) else {
        raise QuorumError("invalid_input", "unknown active policy: " + id)
      }
      index
    })
    let outage_ids : Map[String, Bool] = Map([])
    for outage in stage.outages {
      take_unique(outage_ids, outage.id, "outage")
      if outage.unavailable.length() > 32 {
        raise QuorumError("limit_exceeded", "at most 32 unavailable voter ids")
      }
      let unavailable : Map[String, Bool] = Map([])
      for id in outage.unavailable {
        take_unique(unavailable, id, "unavailable voter")
        if !voters.contains(id) {
          raise QuorumError("invalid_input", "unknown unavailable voter: " + id)
        }
      }
    }
    active
  })
}

///|
/// Check explicit coexistence stages in order. Includes each active policy's
/// self-intersection. Outages affect capacity; intersections use full membership.
pub fn check_migration(
  specs : Array[PolicySpec],
  stages : Array[MigrationStage],
  max_steps~ : Int32 = 1000000,
) -> MigrationReport raise QuorumError {
  if specs.length() < 1 ||
    specs.length() > 8 ||
    stages.length() < 1 ||
    stages.length() > 16 {
    raise QuorumError(
      "limit_exceeded", "require 1..8 policies and 1..16 stages",
    )
  }
  if max_steps < 1 || max_steps > 2000000 {
    raise QuorumError("invalid_input", "max_steps must be 1..2000000")
  }
  let policy_names : Map[String, Bool] = Map([])
  let policy_ids : Map[String, Int32] = Map([])
  let voters : Map[String, Bool] = Map([])
  let policies = specs.mapi((index, spec) => {
    take_unique(policy_names, spec.id, "policy")
    policy_ids[spec.id] = index
    let policy = index_policy(spec)
    for voter in policy.voters {
      voters[voter.id] = true
    }
    if voters.length() > 32 {
      raise QuorumError(
        "limit_exceeded", "at most 32 distinct voters across policies",
      )
    }
    policy
  })
  let active_by_stage = validate_stages(stages, policy_ids, voters)
  let cache : Map[Int32, Intersection] = Map([])
  let mut first_failed = None
  let mut steps = 0
  let reports = stages.mapi((stage_index, stage) => {
    let active = active_by_stage[stage_index]
    let conflicts : Array[PolicyConflict] = []
    for i = 0; i < active.length(); i = i + 1 {
      for j = i; j < active.length(); j = j + 1 {
        let a = active[i]
        let b = active[j]
        let (left, right) = if a <= b { (a, b) } else { (b, a) }
        let key = left * policies.length() + right
        let result = match cache.get(key) {
          Some(saved) => saved
          None => {
            let comparison = policy_comparison(policies[left], policies[right])
            let cost = comparison.validated_members.length() *
              (comparison.left_threshold + 1)
            if cost > max_steps - steps {
              raise QuorumError(
                "limit_exceeded", "migration work budget exhausted; no migration conclusion",
              )
            }
            let result = check_intersection(comparison, max_steps=cost)
            steps += cost
            cache[key] = result
            result
          }
        }
        match result {
          Intersecting => ()
          Disjoint(l, r) =>
            conflicts.push({
              left_policy: policies[left].id,
              right_policy: policies[right].id,
              left_witness: l.filter(id => policies[left].weights.contains(id)),
              right_witness: r.filter(id => policies[right].weights.contains(id)),
            })
        }
      }
    }
    let mut failed = !conflicts.is_empty()
    let outages = stage.outages.map(outage => {
      let capacities = active.map(index => {
        let p = policies[index]
        let mut remaining = p.total
        for id in outage.unavailable {
          remaining -= p.weights.get(id).unwrap_or(0)
        }
        let shortfall = if remaining < p.threshold {
          p.threshold - remaining
        } else {
          0
        }
        if shortfall > 0 {
          failed = true
        }
        { policy: p.id, remaining, threshold: p.threshold, shortfall, }
      })
      { scenario: outage.id, capacities, }
    })
    if failed && first_failed is None {
      first_failed = Some(stage.id)
    }
    { stage: stage.id, conflicts, outages, }
  })
  {
    first_failed_stage: first_failed,
    stages: reports,
    pair_checks: cache.length(),
    work_steps: steps,
  }
}
