# Changelog

## 0.2.0 — staged migration review

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
