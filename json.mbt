///|
fn fields(
  obj : Map[String, Json],
  allowed : Array[String],
) -> Unit raise QuorumError {
  for k in obj.keys() {
    if !allowed.contains(k) {
      raise QuorumError("invalid_input", "unknown field: " + k)
    }
  }
}

///|
fn required(obj : Map[String, Json], key : String) -> Json raise QuorumError {
  guard obj.get(key) is Some(v) else {
    raise QuorumError("invalid_input", "missing field: " + key)
  }
  v
}

///|
fn integer(v : Json) -> Int32 raise QuorumError {
  guard v is Number(n, repr~) && n >= 0.0 && n <= 2000000.0 && n.floor() == n else {
    raise QuorumError("invalid_input", "expected bounded nonnegative integer")
  }
  let decoded = n.to_int()
  if repr is Some(spelling) && exact_bounded_integer(spelling) != Some(decoded) {
    raise QuorumError(
      "invalid_input", "expected exact bounded nonnegative integer",
    )
  }
  decoded
}

///|
fn text(v : Json) -> String raise QuorumError {
  guard v is String(s) else {
    raise QuorumError("invalid_input", "expected string")
  }
  s
}

///|
fn strings(xs : Array[String]) -> Json {
  Json::array(xs.map(Json::string))
}

///|
pub fn analyze(value : Json) -> Json raise QuorumError {
  guard value is Object(obj) else {
    raise QuorumError("invalid_input", "request must be an object")
  }
  fields(obj, [
    "members", "left_threshold", "right_threshold", "unavailable", "max_steps",
  ])
  guard required(obj, "members") is Array(ms) else {
    raise QuorumError("invalid_input", "members must be an array")
  }
  if ms.length() > 32 {
    raise QuorumError("limit_exceeded", "at most 32 members")
  }
  let members = ms.map(v => {
    guard v is Object(m) else {
      raise QuorumError("invalid_input", "member must be an object")
    }
    fields(m, ["id", "left_weight", "right_weight"])
    {
      id: text(required(m, "id")),
      left_weight: integer(required(m, "left_weight")),
      right_weight: integer(required(m, "right_weight")),
    }
  })
  let p = pair(
    members,
    integer(required(obj, "left_threshold")),
    integer(required(obj, "right_threshold")),
  )
  let unavailable = match obj.get("unavailable") {
    None => []
    Some(Array(xs)) => {
      if xs.length() > 32 {
        raise QuorumError("limit_exceeded", "at most 32 unavailable ids")
      }
      xs.map(text)
    }
    _ => raise QuorumError("invalid_input", "unavailable must be an array")
  }
  let (a, b, la, ra) = availability(p, unavailable)
  let steps = match obj.get("max_steps") {
    None => 200000
    Some(v) => integer(v)
  }
  let out : Map[String, Json] = Map([
    ("left_available_weight", Json::number(a.to_double())),
    ("right_available_weight", Json::number(b.to_double())),
    ("left_available", Json::boolean(la)),
    ("right_available", Json::boolean(ra)),
  ])
  match check_intersection(p, max_steps=steps) {
    Intersecting => out["status"] = Json::string("intersecting")
    Disjoint(left, right) => {
      out["status"] = Json::string("disjoint")
      out["left_witness"] = strings(left)
      out["right_witness"] = strings(right)
    }
  }
  Json::object(out)
}

///|
pub fn analyze_batch(value : Json) -> Json raise QuorumError {
  analyze_requests(value, analyze)
}

///|
fn analyze_requests(
  value : Json,
  analyze_one : (Json) -> Json raise QuorumError,
  limit~ : Int32 = 64,
) -> Json raise QuorumError {
  guard value is Array(xs) else {
    raise QuorumError("invalid_input", "batch must be an array")
  }
  if xs.length() > limit {
    raise QuorumError(
      "limit_exceeded",
      "at most " + limit.to_string() + " batch items",
    )
  }
  Json::array(
    xs.map(x => {
      analyze_one(x) catch {
        QuorumError(code, msg) =>
          Json::object(
            Map([
              ("status", Json::string("error")),
              ("code", Json::string(code)),
              ("message", Json::string(msg)),
            ]),
          )
      }
    }),
  )
}

///|
/// Preflight bounds decoder work before delegating exact JSON grammar to core.
pub fn parse_json(source : String) -> Json raise QuorumError {
  if source.length() > 1048576 {
    raise QuorumError("limit_exceeded", "JSON exceeds 1 Mi UTF-16 units")
  }
  let mut depth = 0
  let mut quoted = false
  let mut escaped = false
  let mut tokens = 0
  let mut string_units = 0
  for c in source.iter() {
    if quoted {
      string_units += 1
      if string_units > 256 {
        raise QuorumError(
          "limit_exceeded", "JSON string exceeds 256 source characters",
        )
      }
      if escaped {
        escaped = false
      } else if c == '\\' {
        escaped = true
      } else if c == '"' {
        quoted = false
      }
    } else {
      if c == '"' {
        quoted = true
        string_units = 0
      }
      if c == '{' || c == '[' {
        depth += 1
      }
      if c == '}' || c == ']' {
        depth -= 1
      }
      if c != ' ' && c != '\n' && c != '\r' && c != '\t' {
        tokens += 1
      }
      if depth > 16 || tokens > 200000 {
        raise QuorumError(
          "limit_exceeded", "JSON nesting or token budget exceeded",
        )
      }
    }
  }
  @json.parse(
    source,
    max_nesting_depth=16,
    reject_duplicate_keys=true,
    preserve_number_repr=true,
  ) catch {
    _ => raise QuorumError("invalid_json", "invalid JSON text")
  }
}
