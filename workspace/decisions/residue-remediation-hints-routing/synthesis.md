---
decision_id: residue-remediation-hints-routing
task_id: dd-hermes-residue-remediation-hints-v1
owner: lead
status: synthesized
---

# Decision Synthesis

## Goal

Choose the next bounded mainline after triage-v2 archived with `no-successor-yet`.

## Accepted Path

- Promote `dd-hermes-residue-remediation-hints-v1` as the next bounded mainline.
- Keep successor selection unchanged; instead, make residue actionable by adding shared remediation hints to `successor.audit` and `demo-entry`.
- Treat `review-policy-demo` as the proving example for the first residue-remediation hint class.

## Rejected Paths

- Re-run successor triage again: rejected because triage-v2 just archived and the candidate pool did not change.
- Promote `review-policy-demo`: rejected because it remains working-tree residue without a committed task package.
- Auto-delete residue: rejected because deletion is a stronger operational action than this slice can justify safely.
- Add a separate residue endpoint first: rejected because the existing audit surface can carry the first remediation contract with lower complexity.

## Execution Boundary

- The slice may change `scripts/successor-evidence-audit.sh`, `scripts/demo-entry.sh`, `docs/coordination-endpoints.md`, `tests/smoke.sh`, and task-bound governance artifacts.
- It must not mutate local residue, reopen archived proof scope, or create a fake active successor from residue.

## Executor Handoff

- Implement one stable residue-remediation contract, prove it with smoke coverage, and keep the user-facing result compressed to existing entry/audit surfaces.
