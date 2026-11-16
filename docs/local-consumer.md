# Local library consumer (source development)

For the published version use `moon add JingLan0v0/quorum@0.1.0` without a
workspace override. The steps below deliberately test local source.

Create a separate directory with moon.mod:

```moonbit
name = "local/quorum_consumer"
version = "0.0.0"
preferred_target = "js"
import { "JingLan0v0/quorum@0.1.0" }
```

Add moon.pkg:

```moonbit
import { "JingLan0v0/quorum" }
pkgtype(kind: "executable")
```

Copy examples/library/main.mbt. From the consumer directory run:

```sh
moon work init . /absolute/path/to/moonbit-quorum
moon run . --target js --deny-warn
moon run . --target js --release --deny-warn
```

The workspace deliberately substitutes local source. It is not a download from
Mooncakes. Do not commit its absolute paths. For future publication, validate a
separate fresh consumer with no workspace/path substitution.
