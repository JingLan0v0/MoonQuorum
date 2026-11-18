// This executable imports only the published package interface.

///|
fn main raise {
  let policies : Array[@quorum.PolicySpec] = [
    {
      id: "old",
      voters: [{ id: "a", weight: 2, }, { id: "b", weight: 1, }],
      threshold: 2,
    },
    {
      id: "new",
      voters: [{ id: "a", weight: 2, }, { id: "c", weight: 2, }],
      threshold: 3,
    },
  ]
  let stages : Array[@quorum.MigrationStage] = [
    { id: "before", active: ["old"], outages: [], },
    {
      id: "joint",
      active: ["old", "new"],
      outages: [{ id: "maintenance", unavailable: ["c"], }],
    },
    { id: "after", active: ["new"], outages: [], },
  ]
  let report = @quorum.check_migration(policies, stages)
  assert_eq(report.first_failed_stage, Some("joint"))
  assert_true(report.stages[1].conflicts.is_empty())
  assert_eq(report.stages[1].outages[0].capacities[1].shortfall, 1)
  assert_eq(report.pair_checks, 3)
  println("PASS migration API: isolated outage shortfall in joint stage")
}
