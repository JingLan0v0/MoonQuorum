///|
fn request_object(
  value : Json,
  label : String,
) -> Map[String, Json] raise QuorumError {
  guard value is Object(obj) else {
    raise QuorumError("invalid_input", label + " must be an object")
  }
  obj
}

///|
fn request_array(
  value : Json,
  label : String,
  limit : Int32,
) -> Array[Json] raise QuorumError {
  guard value is Array(values) else {
    raise QuorumError("invalid_input", label + " must be an array")
  }
  if values.length() > limit {
    raise QuorumError("limit_exceeded", label + " exceeds its item limit")
  }
  values
}

///|
fn read_policy(value : Json) -> PolicySpec raise QuorumError {
  let obj = request_object(value, "policy")
  fields(obj, ["id", "voters", "threshold"])
  let voters : Array[Voter] = request_array(
    required(obj, "voters"),
    "voters",
    32,
  ).map(v => {
    let voter = request_object(v, "voter")
    fields(voter, ["id", "weight"])
    {
      id: text(required(voter, "id")),
      weight: integer(required(voter, "weight")),
    }
  })
  {
    id: text(required(obj, "id")),
    voters,
    threshold: integer(required(obj, "threshold")),
  }
}

///|
fn read_stage(value : Json) -> MigrationStage raise QuorumError {
  let obj = request_object(value, "stage")
  fields(obj, ["id", "active", "outages"])
  let active = request_array(required(obj, "active"), "active", 8).map(text)
  let outages : Array[Outage] = match obj.get("outages") {
    None => []
    Some(v) =>
      request_array(v, "outages", 8).map(item => {
        let outage = request_object(item, "outage")
        fields(outage, ["id", "unavailable"])
        let unavailable = request_array(
          required(outage, "unavailable"),
          "unavailable",
          32,
        ).map(text)
        { id: text(required(outage, "id")), unavailable, }
      })
  }
  { id: text(required(obj, "id")), active, outages, }
}

///|
fn count_json(n : Int32) -> Json {
  Json::number(n.to_double())
}

///|
fn encode_stage_report(report : StageReport) -> Json {
  let conflicts = report.conflicts.map(c => {
    Json::object(
      Map([
        ("left_policy", Json::string(c.left_policy)),
        ("right_policy", Json::string(c.right_policy)),
        ("left_witness", strings(c.left_witness)),
        ("right_witness", strings(c.right_witness)),
      ]),
    )
  })
  let outages = report.outages.map(outage => {
    let capacities = outage.capacities.map(c => {
      Json::object(
        Map([
          ("policy", Json::string(c.policy)),
          ("remaining", count_json(c.remaining)),
          ("threshold", count_json(c.threshold)),
          ("shortfall", count_json(c.shortfall)),
        ]),
      )
    })
    Json::object(
      Map([
        ("scenario", Json::string(outage.scenario)),
        ("capacities", Json::array(capacities)),
      ]),
    )
  })
  Json::object(
    Map([
      ("stage", Json::string(report.stage)),
      ("conflicts", Json::array(conflicts)),
      ("outages", Json::array(outages)),
    ]),
  )
}

///|
pub fn analyze_migration(value : Json) -> Json raise QuorumError {
  let obj = request_object(value, "migration request")
  fields(obj, ["policies", "stages", "max_steps"])
  let policies = request_array(required(obj, "policies"), "policies", 8).map(
    read_policy,
  )
  let stages = request_array(required(obj, "stages"), "stages", 16).map(
    read_stage,
  )
  let steps = match obj.get("max_steps") {
    None => 1000000
    Some(v) => integer(v)
  }
  let report = check_migration(policies, stages, max_steps=steps)
  let (status, first) = match report.first_failed_stage {
    None => ("ready", Json::null())
    Some(id) => ("blocked", Json::string(id))
  }
  Json::object(
    Map([
      ("status", Json::string(status)),
      ("first_failed_stage", first),
      ("stages", Json::array(report.stages.map(encode_stage_report))),
      ("pair_checks", count_json(report.pair_checks)),
      ("work_steps", count_json(report.work_steps)),
    ]),
  )
}

///|
pub fn analyze_migration_batch(value : Json) -> Json raise QuorumError {
  analyze_requests(value, analyze_migration, limit=16)
}
