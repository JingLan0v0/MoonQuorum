///|
fn main raise {
  let p = @quorum.pair(
    [
      { id: "old", left_weight: 3, right_weight: 0, },
      { id: "new", left_weight: 0, right_weight: 3, },
    ],
    2,
    2,
  )
  guard @quorum.check_intersection(p) is @quorum.Disjoint(a, b) else {
    abort("expected counterexample")
  }
  assert_true(@quorum.verify_disjoint(p, a, b))
  assert_eq(@quorum.availability(p, ["old"]), (0, 3, false, true))
  println("PASS public API: disjoint witness and outage analysis")
}
