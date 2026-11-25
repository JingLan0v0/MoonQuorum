///|
pub(all) struct FailureDomain {
  id : String
  voters : Array[String]
}

///|
pub(all) struct DomainRisk {
  policy : String
  threshold : Int32
  minimum_failures : Int32
  witness_domains : Array[String]
  witness_remaining : Int32
  worst_remaining : Int32
}

///|
pub(all) struct ResilienceReport {
  migration : MigrationReport
  max_domain_failures : Int32
  policies : Array[DomainRisk]
  first_failed_stage : String?
}

///|
fn index_domains(
  specs : Array[PolicySpec],
  domains : Array[FailureDomain],
) -> Map[String, Int32] raise QuorumError {
  let known : Map[String, Bool] = Map([])
  for policy in specs {
    for voter in policy.voters {
      known[voter.id] = true
    }
  }
  let names : Map[String, Bool] = Map([])
  let assigned : Map[String, Int32] = Map([])
  for index, group in domains {
    take_unique(names, group.id, "failure domain")
    if group.voters.length() < 1 || group.voters.length() > 32 {
      raise QuorumError(
        "limit_exceeded", "require 1..32 voters per failure domain",
      )
    }
    for id in group.voters {
      if !known.contains(id) {
        raise QuorumError(
          "invalid_input",
          "unknown voter in failure domain: " + id,
        )
      }
      if assigned.contains(id) {
        raise QuorumError(
          "invalid_input",
          "voter belongs to more than one domain entry: " + id,
        )
      }
      assigned[id] = index
    }
  }
  if assigned.length() != known.length() {
    raise QuorumError("invalid_input", "failure domains must cover every voter")
  }
  assigned
}

///|
fn domain_risk(
  policy : PolicySpec,
  domains : Array[FailureDomain],
  assignment : Map[String, Int32],
  k : Int32,
) -> DomainRisk {
  let weights = Array::make(domains.length(), 0)
  let mut total = 0
  for voter in policy.voters {
    weights[assignment[voter.id]] += voter.weight
    total += voter.weight
  }
  let ranked = domains.mapi((i, group) => (group.id, weights[i]))
  ranked.sort_by((a, b) => {
    let (id_a, weight_a) = a
    let (id_b, weight_b) = b
    if weight_a == weight_b {
      id_a.compare(id_b)
    } else {
      weight_b.compare(weight_a)
    }
  })
  let witness : Array[String] = []
  let mut witness_remaining = total
  let mut worst_remaining = total
  for i, entry in ranked {
    let (id, lost) = entry
    if i < k {
      worst_remaining -= lost
    }
    if witness_remaining >= policy.threshold {
      witness_remaining -= lost
      witness.push(id)
    }
  }
  {
    policy: policy.id,
    threshold: policy.threshold,
    minimum_failures: witness.length(),
    witness_domains: witness,
    witness_remaining,
    worst_remaining,
  }
}

///|
/// Combine migration checks with exact minimum correlated outages for
/// disjoint failure domains. The worst-case remaining weight is measured at
/// max_domain_failures. Named outage scenarios are checked separately.
pub fn check_resilience(
  specs : Array[PolicySpec],
  stages : Array[MigrationStage],
  domains : Array[FailureDomain],
  max_domain_failures : Int32,
  max_steps~ : Int32 = 1000000,
) -> ResilienceReport raise QuorumError {
  if domains.length() < 1 || domains.length() > 32 {
    raise QuorumError("limit_exceeded", "require 1..32 failure domains")
  }
  if max_domain_failures < 0 || max_domain_failures > domains.length() {
    raise QuorumError(
      "invalid_input", "max_domain_failures must be 0..domain count",
    )
  }
  let migration = check_migration(specs, stages, max_steps~)
  let assignment = index_domains(specs, domains)
  let by_name : Map[String, Bool] = Map([])
  let policies = specs.map(policy => {
    let risk = domain_risk(policy, domains, assignment, max_domain_failures)
    by_name[policy.id] = risk.worst_remaining < risk.threshold
    risk
  })
  let mut first_failed_stage = None
  for stage in stages {
    if migration.first_failed_stage == Some(stage.id) ||
      stage.active.any(id => by_name[id]) {
      first_failed_stage = Some(stage.id)
      break
    }
  }
  { migration, max_domain_failures, policies, first_failed_stage, }
}
