---
schema_version: 2
from: lead
to: lead
scope: stable checkpoint for dd-hermes-residue-remediation-hints-v1 archive
product_rationale: Freeze the residue-remediation slice once the system can explain what to do with residue, so DD Hermes stops carrying this gap as half-code and half-chat memory.
goal_drift_risk: The repo would drift if this slice stayed active after the hint contract and shared-root verification were already complete, or if later residue cleanup were silently treated as part of the same task.
user_visible_outcome: A maintainer can now see residue action guidance directly from DD Hermes without reopening archived proof docs.
files:
  - openspec/archive/dd-hermes-residue-remediation-hints-v1.md
  - workspace/contracts/dd-hermes-residue-remediation-hints-v1.md
  - workspace/decisions/residue-remediation-hints-routing/synthesis.md
  - workspace/state/dd-hermes-residue-remediation-hints-v1/state.json
  - workspace/closeouts/dd-hermes-residue-remediation-hints-v1-expert-a.md
  - workspace/handoffs/dd-hermes-residue-remediation-hints-v1-expert-a-to-lead.md
  - 指挥文档/04-任务重校准与线程策略.md
  - 指挥文档/06-一期PhaseDone审计.md
decisions:
  - Archive the slice after integrating execution commit `2317c71f793723bf81756b7d4c5e58fd0262e690` through merge commit `74896f6226eefa68bf66c7485f3af87ece35a2ba`.
  - Keep residue as non-evidence and leave cleanup/promotion as an explicit future operator choice.
  - Return the repo to `no active mainline` after the archive.
risks:
  - `review-policy-demo` still requires operator action; DD Hermes now explains that action but does not perform it.
  - If future residue classes appear, they need a new bounded task id instead of mutating this archive silently.
next_checks:
  - Confirm `successor.audit` now reports only the remaining real residue and its hint.
  - Use this archive as the decision baseline before any future residue cleanup or successor selection work.
---

# Lead Handoff

## Context

This handoff freezes the residue-remediation checkpoint after the expert execution slice was integrated and the shared root verified the new hint contract.

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

- Residue remediation hints are archived under their own task id.
- The repo returns to an honest `no active mainline` state after this bounded improvement.
- Commander truth no longer depends on remembering residue policy from chat or archive prose alone.

## Product Check

- Confirm the archive keeps DD Hermes honest: the system now explains residue action, but still refuses to promote residue into live successor evidence.

## Verification

- `./scripts/check-artifact-schemas.sh --task-id dd-hermes-residue-remediation-hints-v1` -> pass
- `./scripts/coordination-endpoint.sh --task-id dd-hermes-successor-evidence-audit-v1 --endpoint successor.audit` -> pass
- `./scripts/demo-entry.sh` -> pass
- `bash tests/smoke.sh all` -> pass

## Open Questions

- Should the next bounded task be actual normalization of `review-policy-demo`, or should the repo wait until a stronger committed mainline appears?
