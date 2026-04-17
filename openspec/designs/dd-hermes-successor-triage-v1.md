---
status: design
owner: lead
scope: dd-hermes-successor-triage-v1
decision_log:
  - Treat successor selection as a first-class governance mainline instead of a hidden precondition outside the repo.
  - Read committed repo truth from archive/state/entry sources first, then explicitly demote any working-tree-only residue to non-evidence.
checks:
  - scripts/context-build.sh --task-id dd-hermes-successor-triage-v1 --agent-role commander
  - scripts/demo-entry.sh
links:
  - workspace/contracts/dd-hermes-successor-triage-v1.md
  - workspace/decisions/successor-triage-routing/synthesis.md
  - 指挥文档/04-任务重校准与线程策略.md
  - 指挥文档/06-一期PhaseDone审计.md
---

# Design

## Summary

This task uses one bounded governance mainline to decide what should happen after archive normalization. The mainline is the triage itself: collect committed repo evidence, reject non-evidence such as untracked local residue, and either promote a successor task or record that the slot should stay empty.

## Interfaces

- Commander truth sources:
  - `指挥文档/04-任务重校准与线程策略.md`
  - `指挥文档/06-一期PhaseDone审计.md`
  - `scripts/demo-entry.sh`
- Decision pack:
  - `workspace/decisions/successor-triage-routing/*.md`
- Task package:
  - `workspace/contracts/dd-hermes-successor-triage-v1.md`
  - `workspace/state/dd-hermes-successor-triage-v1/state.json`

## Data Flow

1. Read the latest archived proof and current commander truth surfaces.
2. Compare candidate directions against committed repo evidence only.
3. Record accepted/rejected paths in `workspace/decisions/successor-triage-routing/synthesis.md`.
4. Expose `dd-hermes-successor-triage-v1` as the current active mainline while the decision is live.
5. Either hand off to a new successor task or archive this triage with a no-successor-yet decision.

## Edge Cases

- A local untracked artifact looks like a candidate:
  - Record it as working-tree residue, not repo evidence.
- No candidate is strong enough:
  - Keep the accepted path as “no successor yet” and avoid fabricating progress.
- A single candidate clearly dominates:
  - Promote that candidate only under a new task id with its own contract/state package.

## Acceptance

- Triage is visible as the current mainline instead of being hidden in chat.
- The design explicitly separates committed evidence from local residue.
- The design allows an honest “still no successor” result.

## Verification

- `scripts/context-build.sh --task-id dd-hermes-successor-triage-v1 --agent-role commander`
- `./scripts/demo-entry.sh`
