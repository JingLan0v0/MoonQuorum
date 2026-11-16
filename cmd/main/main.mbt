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
      "moon-quorum [--batch] <request.json|->\nChecks two global weighted threshold policies; does not execute consensus.\n",
    )
    return
  }
  let batch = args.length() == 2 && args[0] == "--batch"
  if !(args.length() == 1 || batch) {
    write_stderr("usage: moon-quorum [--batch] <request.json|->\n")
    set_exit(2)
    return
  }
  let path = args[if batch { 1 } else { 0 }]
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
    let result = if batch {
      @quorum.analyze_batch(value)
    } else {
      @quorum.analyze(value)
    }
    write_stdout(result.stringify() + "\n")
  } catch {
    @quorum.QuorumError(code, message) => {
      write_stderr(code + ": " + message + "\n")
      set_exit(2)
    }
  }
}
