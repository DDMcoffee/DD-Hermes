---
schema_version: 2
from: lead
to: lead
scope: stable checkpoint for dd-hermes-successor-triage-v1 archive
product_rationale: Freeze successor triage once the next active mainline is explicit, so DD Hermes no longer keeps the selection step half in chat and half in docs.
goal_drift_risk: The repo would drift if triage stayed open after a successor was already chosen, or if archived proof tasks were quietly reused as active mainlines.
user_visible_outcome: A maintainer can see one concrete current mainline and one archived triage record explaining why that task was chosen.
files:
  - openspec/archive/dd-hermes-successor-triage-v1.md
  - workspace/contracts/dd-hermes-successor-triage-v1.md
  - workspace/decisions/successor-triage-routing/synthesis.md
  - workspace/state/dd-hermes-successor-triage-v1/state.json
  - workspace/contracts/dd-hermes-independent-skeptic-dispatch-v1.md
  - workspace/decisions/independent-skeptic-dispatch-routing/synthesis.md
  - 指挥文档/04-任务重校准与线程策略.md
  - 指挥文档/06-一期PhaseDone审计.md
decisions:
  - Archive triage after it has named a real next mainline under a new task id.
  - Reject reopening archived proof tasks as fake successors.
  - Promote `dd-hermes-independent-skeptic-dispatch-v1` as the next bounded mainline.
risks:
  - The new mainline is still planning-first; do not overclaim that independent skepticism is already operational.
  - Future successor changes must use new task ids instead of mutating this archive.
next_checks:
  - Validate the new mainline package and commander truth sources.
  - Use this archive as the decision baseline for why `dd-hermes-independent-skeptic-dispatch-v1` became active.
---

# Lead Handoff

## Context

This handoff freezes the successor-triage checkpoint after the repo moved from undecided successor state to one concrete next mainline.

## Required Fields

- `from`
- `to`
- `scope`
- `product_rationale`
- `goal_drift_risk`
- `user_visible_outcome`
- `files`
- `decisions`
- `risks`
- `next_checks`

## Acceptance

- Successor triage is archived under its own task id.
- The next mainline is explicit and uses a separate task package.
- Commander truth no longer depends on remembering the triage outcome from chat.

## Product Check

- Confirm the archive keeps DD Hermes honest: triage chooses the next task and then gets out of the way.

## Verification

- `./scripts/test-workflow.sh --task-id dd-hermes-successor-triage-v1` -> pass
- `./scripts/context-build.sh --task-id dd-hermes-successor-triage-v1 --agent-role commander` -> pass
- `./scripts/check-artifact-schemas.sh --task-id dd-hermes-successor-triage-v1` -> pass
- `./scripts/demo-entry.sh` -> points to `dd-hermes-independent-skeptic-dispatch-v1`
- `bash tests/smoke.sh all` -> pass

## Open Questions

- Which first implementation boundary should `dd-hermes-independent-skeptic-dispatch-v1` take: skeptic worktree, skeptic handoff/context, or both?
