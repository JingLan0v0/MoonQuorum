///|
fn main {
  initialize_output()
  let args = arguments()
  if args.length() == 1 && args[0] == "--version" {
    write_stdout(@quorum.version() + "\n")
    return
  }
  if args.length() == 1 && args[0] == "--help" {
    write_stdout(
      "moon-quorum [--batch|--migration|--migration-batch|--resilience|--resilience-batch] <request.json|->\nChecks quorum intersections, staged migration and fault domains.\n",
    )
    return
  }
  let mode = if args.length() == 1 {
    ""
  } else if args.length() == 2 {
    args[0]
  } else {
    "invalid"
  }
  if !(args.length() == 1 ||
    (
      args.length() == 2 &&
      (
        mode == "--batch" ||
        mode == "--migration" ||
        mode == "--migration-batch" ||
        mode == "--resilience" ||
        mode == "--resilience-batch"
      )
    )) {
    write_stderr(
      "usage: moon-quorum [--batch|--migration|--migration-batch|--resilience|--resilience-batch] <request.json|->\n",
    )
    set_exit(2)
    return
  }
  let path = args[args.length() - 1]
  if path != "-" && path.has_prefix("-") {
    write_stderr("invalid option\n")
    set_exit(2)
    return
  }
  let input = read_utf8(path)
  if input[0] != "" {
    write_stderr("io: " + input[0] + "\n")
    set_exit(2)
    return
  }
  try {
    let value = @quorum.parse_json(input[1])
    let result = match mode {
      "--batch" => @quorum.analyze_batch(value)
      "--migration" => @quorum.analyze_migration(value)
      "--migration-batch" => @quorum.analyze_migration_batch(value)
      "--resilience" => @quorum.analyze_resilience(value)
      "--resilience-batch" => @quorum.analyze_resilience_batch(value)
      _ => @quorum.analyze(value)
    }
    write_stdout(result.stringify() + "\n")
  } catch {
    @quorum.QuorumError(code, message) => {
      write_stderr(code + ": " + message + "\n")
      set_exit(2)
    }
  }
}
