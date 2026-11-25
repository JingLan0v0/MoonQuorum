# Changelog

## 0.3.0 — published, 2026-11-25

- Analyze simultaneous failure domains and produce exact minimum outage witnesses
  with the earliest failing migration stage.
- Reject fractional or inconsistent JSON number spellings that float conversion
  previously hid. Preserve exact integral exponent and decimal forms.
- Reproduce core scenarios with one command and verify them against independent
  subset enumeration and exact integer arithmetic.

## 0.2.0 — published, 2026-11-18

- Check each declared coexistence stage, including self-intersection.
- Identify the first failed stage with policy-specific disjoint witnesses or
  named outage capacity shortfalls.
- Share pair evaluations and a work budget across each report.
- Add typed API, JSON and CLI modes, three executable cases and an independent
  subset oracle. Retain the original two-policy interface.
- Rebuild and hash the verified CLI in both build modes. Match the pinned
  toolchain and verify the checked-out CI commit before recording success.

## 0.1.0 — published, 2026-11-16

- Exact intersection analysis for two bounded global weighted quorum policies.
- Deterministic disjoint witnesses and independent verifier.
- Outage capacity reports, bounded JSON/batch CLI, examples and exhaustive oracle.
- Published after actual-package extraction, Windows/Ubuntu CI and fresh registry installation checks.
