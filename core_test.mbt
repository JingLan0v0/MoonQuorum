///|
fn voter(id : String, a : Int32, b : Int32) -> @quorum.Member {
  { id, left_weight: a, right_weight: b, }
}

///|
test "majority policies intersect" {
  let p = @quorum.pair(
    [voter("a", 1, 1), voter("b", 1, 1), voter("c", 1, 1)],
    2,
    2,
  )
  guard @quorum.check_intersection(p) is @quorum.Intersecting else {
    fail("expected intersection")
  }
}

///|
test "cross configuration exposes disjoint quorums" {
  let p = @quorum.pair([voter("old", 3, 0), voter("new", 0, 3)], 2, 2)
  guard @quorum.check_intersection(p) is @quorum.Disjoint(a, b) else {
    fail("expected disjoint")
  }
  assert_true(@quorum.verify_disjoint(p, a, b))
}

///|
test "weights can force intersection even when threshold sum is not above total" {
  let p = @quorum.pair([voter("a", 2, 2), voter("b", 2, 2)], 1, 3)
  guard @quorum.check_intersection(p) is @quorum.Intersecting else {
    fail("indivisible votes")
  }
}

///|
test "zero weights and 32nd witness bit" {
  let ms = Array::makei(32, i => {
    voter(
      "n" + i.to_string(),
      if i == 31 {
        1
      } else {
        0
      },
      if i == 0 {
        1
      } else {
        0
      },
    )
  })
  let p = @quorum.pair(ms, 1, 1)
  guard @quorum.check_intersection(p) is @quorum.Disjoint(a, b) else {
    fail("expected disjoint")
  }
  assert_eq(a, ["n31"])
  assert_true(@quorum.verify_disjoint(p, a, b))
}

///|
test "snapshot protects pair and fresh result arrays" {
  let ms = [voter("a", 1, 0), voter("b", 0, 1)]
  let p = @quorum.pair(ms, 1, 1)
  ms.clear()
  p.members().clear()
  guard @quorum.check_intersection(p) is @quorum.Disjoint(a, _) else {
    fail("disjoint")
  }
  a.clear()
  guard @quorum.check_intersection(p) is @quorum.Disjoint(c, d) else {
    fail("disjoint")
  }
  assert_true(@quorum.verify_disjoint(p, c, d))
}

///|
test "budget exact threshold and reuse" {
  let p = @quorum.pair([voter("a", 1, 1), voter("b", 1, 1)], 1, 1)
  let failed = try {
    @quorum.check_intersection(p, max_steps=3) |> ignore
    false
  } catch {
    @quorum.QuorumError(code, _) => code == "limit_exceeded"
  }
  assert_true(failed)
  guard @quorum.check_intersection(p, max_steps=4) is @quorum.Disjoint(a, b) else {
    fail("disjoint")
  }
  assert_true(@quorum.verify_disjoint(p, a, b))
}

///|
test "outages distinguish unavailable policy from intersection" {
  let p = @quorum.pair([voter("a", 2, 1), voter("b", 1, 2)], 2, 2)
  assert_eq(@quorum.availability(p, ["a"]), (1, 2, false, true))
  assert_eq(@quorum.availability(p, ["a", "b"]), (0, 0, false, false))
}

///|
test "invalid witnesses are rejected without throwing" {
  let p = @quorum.pair([voter("a", 1, 1), voter("b", 1, 1)], 1, 1)
  for
    (a, b) in [
      (["a"], ["a"]),
      (["missing"], ["b"]),
      (["a", "a"], ["b"]),
      ([], ["b"]),
    ] {
    assert_false(@quorum.verify_disjoint(p, a, b))
  }
}

///|
test "invalid model boundaries" {
  for
    ms in [
      [],
      [voter("a", 1, 1), voter("a", 1, 1)],
      [voter("bad id", 1, 1)],
      [voter("a", -1, 1)],
      [voter("a", 1001, 1)],
      Array::makei(33, i => voter(i.to_string(), 1, 1)),
      Array::makei(5, i => voter(i.to_string(), 1000, 1000)),
    ] {
    let failed = try {
      @quorum.pair(ms, 1, 1) |> ignore
      false
    } catch {
      @quorum.QuorumError(_, _) => true
    }
    assert_true(failed)
  }
  for (a, b) in [(0, 1), (1, 0), (2, 1), (1, 2)] {
    let failed = try {
      @quorum.pair([voter("a", 1, 1)], a, b) |> ignore
      false
    } catch {
      @quorum.QuorumError(_, _) => true
    }
    assert_true(failed)
  }
}

///|
test "maximum capacity remains bounded" {
  let ms = Array::makei(32, i => voter(i.to_string(), 128, 128))
  let p = @quorum.pair(ms, 4096, 4096)
  guard @quorum.check_intersection(p) is @quorum.Intersecting else {
    fail("all required")
  }
}

///|
test "unknown and duplicate outages fail" {
  let p = @quorum.pair([voter("a", 1, 1)], 1, 1)
  for names in [["x"], ["a", "a"]] {
    let failed = try {
      @quorum.availability(p, names) |> ignore
      false
    } catch {
      @quorum.QuorumError(_, _) => true
    }
    assert_true(failed)
  }
}

///|
test "strict text preflight" {
  for
    s in [
      "{\"a\":1,\"a\":2}",
      "[".repeat(17) + "0" + "]".repeat(17),
      " ".repeat(1048577),
    ] {
    let failed = try {
      @quorum.parse_json(s) |> ignore
      false
    } catch {
      @quorum.QuorumError(_, _) => true
    }
    assert_true(failed)
  }
}

///|
test "pruning retains the full work charge and disjoint witness" {
  let members = Array::makei(32, i => {
    let id = "n" + i.to_string()
    if i < 16 {
      voter(id, 128, 0)
    } else {
      voter(id, 0, 128)
    }
  })
  let pair = @quorum.pair(members, 2048, 2048)
  let full_cost = 32 * 2049
  try
    @quorum.check_intersection(pair, max_steps=full_cost - 1) |> ignore
  catch {
    @quorum.QuorumError(code, _) => assert_eq(code, "limit_exceeded")
  } noraise {
    _ => fail("accepted a budget below the full work charge")
  }
  guard @quorum.check_intersection(pair, max_steps=full_cost)
    is @quorum.Disjoint(left, right) else {
    fail("expected disjoint witness")
  }
  assert_eq(left, Array::makei(16, i => "n" + i.to_string()))
  assert_eq(right, Array::makei(16, i => "n" + (16 + i).to_string()))
  assert_true(@quorum.verify_disjoint(pair, left, right))
}

///|
test "common weight unit preserves a threshold between reachable totals" {
  let members = [voter("a", 4, 3), voter("b", 2, 0), voter("c", 0, 1)]
  let p = @quorum.pair(members, 3, 2)
  guard @quorum.check_intersection(p, max_steps=12) is @quorum.Intersecting else {
    fail("weight two cannot satisfy threshold three")
  }
  let at_unit = @quorum.pair(members, 2, 2)
  guard @quorum.check_intersection(at_unit, max_steps=9)
    is @quorum.Disjoint(left, right) else {
    fail("weight two can satisfy threshold two")
  }
  assert_eq(left, ["b"])
  assert_eq(right, ["a", "c"])
  assert_true(@quorum.verify_disjoint(at_unit, left, right))
}

///|
test "combined disjoint weight bound keeps equality and the original budget" {
  let members = [voter("a", 2, 3), voter("b", 3, 2)]
  let above = @quorum.pair(members, 4, 3)
  try @quorum.check_intersection(above, max_steps=9) |> ignore catch {
    @quorum.QuorumError(code, _) => assert_eq(code, "limit_exceeded")
  } noraise {
    _ => fail("accepted less than the full budget")
  }
  guard @quorum.check_intersection(above, max_steps=10) is @quorum.Intersecting else {
    fail("threshold sum exceeds the combined disjoint weight")
  }
  let equal = @quorum.pair(members, 3, 3)
  guard @quorum.check_intersection(equal, max_steps=8)
    is @quorum.Disjoint(left, right) else {
    fail("disjoint quorums exist at the bound")
  }
  assert_eq(left, ["b"])
  assert_eq(right, ["a"])
}
