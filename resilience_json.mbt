///|
pub fn analyze_resilience(value : Json) -> Json raise QuorumError {
  let obj = request_object(value, "resilience request")
  fields(obj, [
    "policies", "stages", "max_steps", "failure_domains", "max_domain_failures",
  ])
  let (specs, stages, steps) = read_migration_model(obj)
  let domains = request_array(
    required(obj, "failure_domains"),
    "failure_domains",
    32,
  ).map(value => {
    let group = request_object(value, "failure domain")
    fields(group, ["id", "voters"])
    {
      id: text(required(group, "id")),
      voters: request_array(required(group, "voters"), "voters", 32).map(text),
    }
  })
  let limit = integer(required(obj, "max_domain_failures"))
  let report = check_resilience(specs, stages, domains, limit, max_steps=steps)
  let (status, first) = match report.first_failed_stage {
    None => ("ready", Json::null())
    Some(id) => ("blocked", Json::string(id))
  }
  let risks = report.policies.map(risk => {
    Json::object(
      Map([
        ("policy", Json::string(risk.policy)),
        ("threshold", count_json(risk.threshold)),
        ("minimum_failures", count_json(risk.minimum_failures)),
        ("witness_domains", strings(risk.witness_domains)),
        ("witness_remaining", count_json(risk.witness_remaining)),
        ("worst_remaining", count_json(risk.worst_remaining)),
      ]),
    )
  })
  Json::object(
    Map([
      ("status", Json::string(status)),
      ("first_failed_stage", first),
      ("max_domain_failures", count_json(report.max_domain_failures)),
      ("policies", Json::array(risks)),
      ("migration", encode_migration_report(report.migration)),
    ]),
  )
}

///|
pub fn analyze_resilience_batch(value : Json) -> Json raise QuorumError {
  analyze_requests(value, analyze_resilience, limit=16)
}
