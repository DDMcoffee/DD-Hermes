---
decision_id: successor-triage-routing
task_id: dd-hermes-successor-triage-v1
role: delivery
status: proposed
---

# Explorer Finding

## Goal

Decide what the maintainer/operator actually needs next in order to keep DD Hermes resumable after the latest archived proof.

## Findings

- The current entry surface can already say “latest proof archived, no active mainline,” but it still leaves the next decision implicit.
- A bounded successor-triage mainline is itself user-visible progress: it tells the maintainer what is being decided now and where the evidence lives.
- No committed feature slice currently has stronger delivery value than clarifying successor selection itself.

## Recommended Path

- Set `dd-hermes-successor-triage-v1` as the active mainline and route 04/06/demo-entry through it until a stronger successor exists.

## Rejected Paths

- Keep `current_mainline_task_id` empty while silently doing triage: rejected because it hides live work.
- Promote a feature successor just to fill the slot: rejected because it would recreate fake progress.

## Risks

- Triage as a mainline can look like bureaucracy unless its output is explicit and bounded.
- Entry/docs can drift again if they are not updated in the same turn as the task package.

## Evidence

- `scripts/demo-entry.sh`
- `指挥文档/06-一期PhaseDone审计.md`
- `workspace/contracts/dd-hermes-legacy-archive-normalization-v1.md`
- `workspace/state/dd-hermes-legacy-archive-normalization-v1/state.json`
