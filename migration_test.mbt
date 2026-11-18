///|
test "a bridge conflict blocks a migration whose endpoints intersect" {
  let specs : Array[@quorum.PolicySpec] = [
    { id: "old", voters: [{ id: "a", weight: 2, }], threshold: 2, },
    { id: "bridge", voters: [{ id: "b", weight: 2, }], threshold: 2, },
    { id: "new", voters: [{ id: "a", weight: 3, }], threshold: 3, },
  ]
  let r = @quorum.check_migration(specs, [
    { id: "endpoints", active: ["old", "new"], outages: [], },
    { id: "overlap", active: ["bridge", "old"], outages: [], },
    { id: "repeat", active: ["old", "bridge"], outages: [], },
  ])
  assert_eq(r.first_failed_stage, Some("overlap"))
  assert_eq(r.pair_checks, 5)
  assert_true(r.stages[0].conflicts.is_empty())
  let conflict = r.stages[1].conflicts[0]
  assert_eq(conflict.left_policy, "old")
  assert_eq(conflict.right_policy, "bridge")
  assert_eq(conflict.left_witness, ["a"])
  assert_eq(conflict.right_witness, ["b"])
  conflict.left_witness.clear()
  assert_eq(r.stages[2].conflicts[0].left_witness, ["a"])
}

///|
test "outage failure is evaluated for each policy in its stage" {
  let r = @quorum.check_migration(
    [
      {
        id: "read",
        voters: [{ id: "a", weight: 2, }, { id: "b", weight: 1, }],
        threshold: 2,
      },
      {
        id: "write",
        voters: [{ id: "a", weight: 2, }, { id: "b", weight: 2, }],
        threshold: 3,
      },
    ],
    [
      {
        id: "stable",
        active: ["read", "write"],
        outages: [{ id: "low", unavailable: ["b"], }],
      },
      { id: "later", active: ["read", "write"], outages: [], },
    ],
  )
  assert_eq(r.first_failed_stage, Some("stable"))
  assert_true(r.stages[0].conflicts.is_empty())
  let capacities = r.stages[0].outages[0].capacities
  assert_eq(capacities[0].remaining, 2)
  assert_eq(capacities[0].shortfall, 0)
  assert_eq(capacities[1].remaining, 2)
  assert_eq(capacities[1].shortfall, 1)
  assert_eq(r.pair_checks, 3)
}

///|
test "shared migration budget counts unique comparisons and allows retry" {
  let specs : Array[@quorum.PolicySpec] = [
    { id: "old", voters: [{ id: "a", weight: 1, }], threshold: 1, },
    { id: "new", voters: [{ id: "a", weight: 1, }], threshold: 1, },
  ]
  let stages : Array[@quorum.MigrationStage] = [
    { id: "pre", active: ["old"], outages: [], },
    { id: "joint", active: ["new", "old"], outages: [], },
    { id: "post", active: ["new"], outages: [], },
  ]
  let failed = try {
    @quorum.check_migration(specs, stages, max_steps=5) |> ignore
    false
  } catch {
    @quorum.QuorumError(code, _) => code == "limit_exceeded"
  }
  assert_true(failed)
  let r = @quorum.check_migration(specs, stages, max_steps=6)
  assert_eq(r.work_steps, 6)
  assert_eq(r.first_failed_stage, None)
}

///|
test "a single active policy can violate self-intersection" {
  let r = @quorum.check_migration(
    [
      {
        id: "one",
        voters: [{ id: "a", weight: 1, }, { id: "b", weight: 1, }],
        threshold: 1,
      },
    ],
    [{ id: "stable", active: ["one"], outages: [], }],
  )
  assert_eq(r.first_failed_stage, Some("stable"))
  let conflict = r.stages[0].conflicts[0]
  assert_eq(conflict.left_policy, conflict.right_policy)
  assert_eq(conflict.left_witness, ["a"])
  assert_eq(conflict.right_witness, ["b"])
}
