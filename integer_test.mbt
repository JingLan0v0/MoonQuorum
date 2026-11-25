///|
fn weight_request(token : String) -> Json raise @quorum.QuorumError {
  let before =
    #|{"members":[{"id":"a","left_weight":
  let after =
    #|,"right_weight":1},{"id":"b","left_weight":1,"right_weight":1}],"left_threshold":1,"right_threshold":1}
  @quorum.parse_json(before + token + after)
}

///|
test "fractional JSON weight cannot disappear through floating-point rounding" {
  for
    spelling in [
      "1.00000000000000001", "0.99999999999999999", "1e-9999", "-1e-9999",
    ] {
    let input = weight_request(spelling)
    try @quorum.analyze(input) |> ignore catch {
      @quorum.QuorumError(code, _) => assert_eq(code, "invalid_input")
    } noraise {
      _ => fail("accepted noninteger weight " + spelling)
    }
  }
}

///|
test "equivalent decimal integer spellings retain the same meaning" {
  let expected = @quorum.analyze(weight_request("1"))
  for token in ["1.0", "1.00e+0", "0.01e2", "10000000000e-10"] {
    assert_eq(@quorum.analyze(weight_request(token)), expected)
  }
}

///|
test "typed JSON representation must agree with its numeric value" {
  let input = weight_request("1")
  guard input is Object(root) &&
    root.get("members") is Some(Array(members)) &&
    members[0] is Object(voter_fields) else {
    fail("test input")
  }
  for bad in ["2", "01", "1 2", "1e+", "1.0000000000000001"] {
    voter_fields["left_weight"] = Json::number(1.0, repr=bad)
    try @quorum.analyze(input) |> ignore catch {
      @quorum.QuorumError(code, _) => assert_eq(code, "invalid_input")
    } noraise {
      _ => fail("accepted malformed or inconsistent representation")
    }
  }
  voter_fields["left_weight"] = Json::number(1.0, repr="10000000e-7")
  assert_eq(@quorum.analyze(input), @quorum.analyze(weight_request("1")))
}
