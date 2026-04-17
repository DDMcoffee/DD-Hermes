---
decision_id: successor-evidence-audit-routing
task_id: dd-hermes-successor-evidence-audit-v1
owner: lead
status: synthesized
---

# Decision Synthesis

## Goal

Decide what the next honest phase-2 mainline should be after the repo confirmed that no committed successor is currently active.

## Accepted Path

- Start `dd-hermes-successor-evidence-audit-v1` as the next bounded mainline.
- Keep the mainline scoped to one maintainer-visible gap: successor evidence still requires manual repo sweeps to distinguish committed candidates from local residue.
- Implement one audit surface that reports committed live candidates, local residue, verdict, and reasons, then reuse that surface in `demo-entry` when no active mainline exists.

## Rejected Paths

- Keep the repo at “no active mainline” with no new task: rejected because the repeated manual successor sweep has become a concrete control-plane gap of its own.
- Promote `review-policy-demo`: rejected because it is working-tree residue, not committed repo truth.
- Reopen `dd-hermes-backlog-truth-hygiene-v1` or `dd-hermes-successor-triage-v1`: rejected because both are archived governance slices with already-closed boundaries.

## Execution Boundary

- `dd-hermes-successor-evidence-audit-v1` may change audit/reporting surfaces such as `scripts/coordination-endpoint.sh`, a successor-audit script, `scripts/demo-entry.sh`, docs, and smoke tests.
- It must not reopen archived proof scope, invent a feature successor, or expand into runtime/provider/plugin-loader work.
- The user-facing interaction stays on one thread; any audit remains an internal control-plane surface.

## Executor Handoff

- Freeze this synthesis as the reason the repo moved from an empty slot to one explicit audit mainline.
- The implementation must prove that committed evidence and local residue are reported separately, not merely described separately in docs.
