# Revision after initial review — 2026-11-18

The MoonQuorum notice supplied by the participant cites insufficient in-season
GitHub submissions and asks for a runnable MVP before resubmission. It permits
updating the original form before 2026-11-30. The notice does not specify the
counting rule or a numeric minimum. The current November homepage calls for
traceable public development and substantial project work. Detailed charter/form
contents were unavailable through the retrieval tools on November 18.

At diagnosis, public main had four commits dated November 16, including the
initial implementation. The revision keeps that history and adds a concrete
rollout review workflow. Commits record real implementation, integration,
verification and release changes.

| Item | Review evidence |
|---|---|
| Runnable MVP | Typed migration API, CLI, and three documented stage/outage fixtures |
| Material work | Named stage model, self/cross-policy checks, pair reuse, global work and per-policy outages |
| Reproduction | Independent oracle, backward-compatibility cases, PowerShell and Windows/Ubuntu CI |
| Public links | Original GitHub repository and versioned Mooncakes package |
| Resubmission | Participant updates the existing form with the desktop proposal before the notice deadline |
| Organizer decision | Initial application rejected. Revised submission and re-review are separate from technical release. |

Sources: participant's MoonQuorum notice and the November text of
https://github.com/moonbitlang/Hackathon2026/blob/main/src/App.tsx .
Earlier competition evidence follows.

# November 2026 requirements — retrieved 2026-11-16

Official homepage https://moonbitlang.github.io/Hackathon2026/ and its current
source https://github.com/moonbitlang/Hackathon2026/blob/main/src/App.tsx were
checked. Chinese text identifies November; some English labels still say October.
Dates are subject to organizer notice. Do not infer a deadline from stale labels.
Charter https://bxup9uklfcb.feishu.cn/wiki/Dx4Bwd6D1i3GfHkajQCcF7SznEd and form
https://bxup9uklfcb.feishu.cn/share/base/form/shrcnWUMlgpbwHaXgzV7HmNhNhg could not
be retrieved. Detailed current form fields/extra rules remain unverified.

| Requirement | Source/stage | Evidence/status | Next action |
|---|---|---|---|
| MoonBit primary implementation | Official homepage / engineering | Core and JSON in MoonBit | Retain boundary |
| Public traceable repository | Homepage / development | Public repository uploaded with preserved history; Windows/Ubuntu CI passed | See acceptance.md |
| README/examples/tests | Homepage / engineering | Bilingual README, three scenarios, independent oracle | See acceptance receipts |
| Recognized license/provenance | Homepage / open source | Apache-2.0 and attribution | Preserve notices |
| One-page proposal | Homepage / application | Desktop Markdown proposal | Actual repository root added |
| AI work understood by participant | Homepage / participant | AI assistance disclosed | Read architecture and explain limitations |
| Event group with GitHub ID nickname | Homepage / participant | Not verified | Participant confirms |
| Deadlines/form/eligibility | Charter and notice / organizer | Retrieval unavailable | Confirm official notice |
| Mooncakes | User / published | JingLan0v0/quorum@0.1.0 verified | See publication-0.1.0.json |
| Qualification/final acceptance | Organizer | No receipt | Submit personally and await review |

The official homepage permits AI-assisted code/interfaces/tests/docs and rejects
repeat/split/superficial submissions. MoonQuorum is a separate weighted-policy
analysis core, not a rename of MoonSTN/MoonJMES. No automatic form submission,
messages or invented Issues/PRs. Technical checks do not guarantee acceptance.
