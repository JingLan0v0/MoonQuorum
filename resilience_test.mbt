///|
fn regional_policies() -> Array[@quorum.PolicySpec] {
  [
    {
      id: "old",
      voters: [
        { id: "a", weight: 1, },
        { id: "b", weight: 1, },
        { id: "c", weight: 1, },
      ],
      threshold: 2,
    },
    {
      id: "new",
      voters: [
        { id: "a", weight: 2, },
        { id: "b", weight: 1, },
        { id: "c", weight: 1, },
      ],
      threshold: 3,
    },
  ]
}

///|
fn regions() -> Array[@quorum.FailureDomain] {
  [
    { id: "z", voters: ["a"], },
    { id: "b", voters: ["b"], },
    { id: "a", voters: ["c"], },
  ]
}

///|
test "domain risk can be the first failing stage ahead of a named outage" {
  let stages : Array[@quorum.MigrationStage] = [
    { id: "before", active: ["old"], outages: [], },
    { id: "joint", active: ["old", "new"], outages: [], },
    {
      id: "later",
      active: ["new"],
      outages: [{ id: "db", unavailable: ["a", "b"], }],
    },
  ]
  let report = @quorum.check_resilience(
    regional_policies(),
    stages,
    regions(),
    1,
  )
  assert_eq(report.migration.first_failed_stage, Some("later"))
  assert_eq(report.first_failed_stage, Some("joint"))
  assert_eq(report.policies[0].worst_remaining, 2)
  assert_eq(report.policies[0].minimum_failures, 2)
  assert_eq(report.policies[0].witness_domains, ["a", "b"])
  assert_eq(report.policies[1].minimum_failures, 1)
  assert_eq(report.policies[1].witness_domains, ["z"])
  assert_eq(report.policies[1].witness_remaining, 2)
}

///|
test "zero tolerated failures still reports the minimum and retains readiness" {
  let stages : Array[@quorum.MigrationStage] = [
    { id: "joint", active: ["old", "new"], outages: [], },
  ]
  let report = @quorum.check_resilience(
    regional_policies(),
    stages,
    regions(),
    0,
  )
  assert_eq(report.first_failed_stage, None)
  assert_eq(report.policies[1].worst_remaining, 4)
  assert_eq(report.policies[1].minimum_failures, 1)
}

///|
test "failure domains must form an exact voter partition" {
  let stages : Array[@quorum.MigrationStage] = [
    { id: "joint", active: ["old", "new"], outages: [], },
  ]
  let inputs : Array[Array[@quorum.FailureDomain]] = [
    [{ id: "one", voters: ["a", "b"], }],
    [{ id: "one", voters: ["a", "b"], }, { id: "two", voters: ["b", "c"], }],
    [{ id: "one", voters: ["a", "b", "c", "unexpected"], }],
    [{ id: "one", voters: ["a"], }, { id: "one", voters: ["b", "c"], }],
  ]
  for input in inputs {
    try
      @quorum.check_resilience(regional_policies(), stages, input, 1) |> ignore
    catch {
      @quorum.QuorumError(code, _) => assert_eq(code, "invalid_input")
    } noraise {
      _ => fail("invalid domain partition accepted")
    }
  }
}
