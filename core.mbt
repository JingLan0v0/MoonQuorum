///|
pub(all) suberror QuorumError {
  QuorumError(String, String)
}

///|
pub(all) struct Member {
  id : String
  left_weight : Int32
  right_weight : Int32
} derive(Eq, Debug)

///|
pub struct Pair {
  members : Array[Member]
  left_threshold : Int32
  right_threshold : Int32
  right_total : Int32
}

///|
pub(all) enum Intersection {
  Intersecting
  Disjoint(Array[String], Array[String])
}

///|
fn valid_id(s : String) -> Bool {
  if s.length() < 1 || s.length() > 64 {
    return false
  }
  for c in s.iter() {
    if !((c >= 'a' && c <= 'z') ||
      (c >= 'A' && c <= 'Z') ||
      (c >= '0' && c <= '9') ||
      c == '_' ||
      c == '-' ||
      c == '.') {
      return false
    }
  }
  true
}

///|
pub fn pair(
  members : Array[Member],
  left_threshold : Int32,
  right_threshold : Int32,
) -> Pair raise QuorumError {
  if members.length() < 1 || members.length() > 32 {
    raise QuorumError("limit_exceeded", "require 1..32 members")
  }
  let seen : Map[String, Bool] = Map([])
  let mut left = 0
  let mut right = 0
  for m in members {
    if !valid_id(m.id) || seen.contains(m.id) {
      raise QuorumError("invalid_input", "invalid or duplicate member id")
    }
    seen[m.id] = true
    if m.left_weight < 0 ||
      m.left_weight > 1000 ||
      m.right_weight < 0 ||
      m.right_weight > 1000 {
      raise QuorumError("invalid_input", "weights must be integers in 0..1000")
    }
    left += m.left_weight
    right += m.right_weight
  }
  if left > 4096 || right > 4096 {
    raise QuorumError("limit_exceeded", "each total weight must be <=4096")
  }
  if left_threshold < 1 ||
    left_threshold > left ||
    right_threshold < 1 ||
    right_threshold > right {
    raise QuorumError(
      "invalid_input", "threshold must be 1..total policy weight",
    )
  }
  {
    members: members.copy(),
    left_threshold,
    right_threshold,
    right_total: right,
  }
}

///|
pub fn Pair::members(self : Pair) -> Array[Member] {
  self.members.copy()
}

///|
fn selected_weight(
  p : Pair,
  names : Array[String],
) -> (Int32, Int32) raise QuorumError {
  if names.length() > p.members.length() {
    raise QuorumError("invalid_input", "too many member ids")
  }
  let seen : Map[String, Bool] = Map([])
  let mut left = 0
  let mut right = 0
  for name in names {
    if seen.contains(name) {
      raise QuorumError("invalid_input", "duplicate member id")
    }
    seen[name] = true
    let mut found = false
    for m in p.members {
      if m.id == name {
        left += m.left_weight
        right += m.right_weight
        found = true
        break
      }
    }
    if !found {
      raise QuorumError("invalid_input", "unknown member: " + name)
    }
  }
  (left, right)
}

///|
/// Independently checks membership, unique ids, both thresholds and disjointness.
pub fn verify_disjoint(
  p : Pair,
  left : Array[String],
  right : Array[String],
) -> Bool {
  try {
    let (a, _) = selected_weight(p, left)
    let (_, b) = selected_weight(p, right)
    a >= p.left_threshold &&
    b >= p.right_threshold &&
    !left.any(x => right.contains(x))
  } catch {
    QuorumError(_, _) => false
  }
}

///|
/// Remaining total weights and ability to form each quorum after named outages.
pub fn availability(
  p : Pair,
  unavailable : Array[String],
) -> (Int32, Int32, Bool, Bool) raise QuorumError {
  let (lost_left, lost_right) = selected_weight(p, unavailable)
  let mut total_left = 0
  for m in p.members {
    total_left += m.left_weight
  }
  let a = total_left - lost_left
  let b = p.right_total - lost_right
  (a, b, a >= p.left_threshold, b >= p.right_threshold)
}

///|
fn left_weight_unit(p : Pair) -> Int32 {
  let mut unit = 0
  for voter in p.members {
    let mut weight = voter.left_weight
    while weight != 0 {
      let remainder = unit % weight
      unit = weight
      weight = remainder
    }
    if unit == 1 {
      break
    }
  }
  unit
}

///|
/// Exact intersection of two global weighted threshold families, not protocol safety.
pub fn check_intersection(
  p : Pair,
  max_steps~ : Int32 = 200000,
) -> Intersection raise QuorumError {
  if max_steps < 1 || max_steps > 2000000 {
    raise QuorumError("invalid_input", "max_steps must be 1..2000000")
  }
  // Charge the original full table so callers keep the same budget contract.
  if p.members.length() * (p.left_threshold + 1) > max_steps {
    raise QuorumError(
      "limit_exceeded", "work budget exhausted; no intersection conclusion",
    )
  }
  // A disjoint assignment can count each voter's weight on only one side.
  let mut disjoint_limit = 0
  let mut total_left = 0
  for voter in p.members {
    disjoint_limit += voter.left_weight.max(voter.right_weight)
    total_left += voter.left_weight
  }
  if p.left_threshold + p.right_threshold > disjoint_limit {
    return Intersecting
  }
  // All reachable unsaturated totals are multiples of this unit.
  let unit = left_weight_unit(p)
  let q = (p.left_threshold - 1) / unit + 1
  let cost = Array::make(q + 1, 4097)
  let masks : Array[Int64] = Array::make(q + 1, 0L)
  cost[0] = 0
  let mut reachable_max = 0
  let mut remaining_left = total_left / unit
  for i = 0; i < p.members.length(); i = i + 1 {
    let m = p.members[i]
    // With no left weight, a voter cannot improve any state.
    if m.left_weight == 0 {
      continue
    }
    let left_weight = m.left_weight / unit
    // A state below this bound cannot reach the threshold using the remaining voters.
    let reachable_min = (q - remaining_left).max(0)
    for t = reachable_max; t >= reachable_min; t = t - 1 {
      if cost[t] == 4097 {
        continue
      }
      let target = (t + left_weight).min(q)
      let candidate = cost[t] + m.right_weight
      if candidate < cost[target] {
        cost[target] = candidate
        masks[target] = masks[t] | (1L << i)
      }
    }
    reachable_max = (reachable_max + left_weight).min(q)
    remaining_left -= left_weight
  }
  if cost[q] > p.right_total - p.right_threshold {
    return Intersecting
  }
  let left : Array[String] = []
  let right : Array[String] = []
  for i = 0; i < p.members.length(); i = i + 1 {
    if (masks[q] & (1L << i)) != 0L {
      left.push(p.members[i].id)
    } else {
      right.push(p.members[i].id)
    }
  }
  Disjoint(left, right)
}

///|
pub fn version() -> String {
  "0.3.3"
}

///|
pub extend Member with Eq::{equal, not_equal}

///|
pub extend Member with @debug.Debug::{to_repr}
