---
status: design
owner: lead
scope: dd-hermes-successor-triage-v2
decision_log:
  - Treat successor selection as a first-class governance mainline again instead of letting “no active mainline” silently carry the whole decision burden.
  - Read committed repo truth from archive, state, successor-audit, and commander sources first, then explicitly demote any working-tree-only residue to non-evidence.
checks:
  - scripts/context-build.sh --task-id dd-hermes-successor-triage-v2 --agent-role commander
  - ./scripts/coordination-endpoint.sh --task-id dd-hermes-successor-evidence-audit-v1 --endpoint successor.audit
  - ./scripts/demo-entry.sh
links:
  - workspace/contracts/dd-hermes-successor-triage-v2.md
  - workspace/decisions/successor-triage-v2-routing/synthesis.md
  - 指挥文档/04-任务重校准与线程策略.md
  - 指挥文档/06-一期PhaseDone审计.md
---

# Design

## Summary

This task uses one bounded governance mainline to decide what should happen after `dd-hermes-successor-evidence-audit-v1` archive. The triage itself is the work: collect committed repo evidence, reject non-evidence such as untracked local residue, and either promote one successor task or record that the slot should stay empty.

## Interfaces

- Commander truth sources:
  - `指挥文档/04-任务重校准与线程策略.md`
  - `指挥文档/06-一期PhaseDone审计.md`
  - `scripts/demo-entry.sh`
- Evidence surface:
  - `scripts/coordination-endpoint.sh --endpoint successor.audit`
- Decision pack:
  - `workspace/decisions/successor-triage-v2-routing/*.md`
- Task package:
  - `workspace/contracts/dd-hermes-successor-triage-v2.md`
  - `workspace/state/dd-hermes-successor-triage-v2/state.json`

## Data Flow

1. Read the latest archived proof and current commander truth surfaces.
2. Call `successor.audit` to confirm the current committed candidate pool and residue set.
3. Record architecture, delivery, and curriculum perspectives under `workspace/decisions/successor-triage-v2-routing/`.
4. Write a synthesis that either names one bounded successor or records why no successor is yet justified.
5. Archive this triage under its own task id once the decision boundary is explicit.

## Edge Cases

- A local untracked artifact looks like a candidate:
  - Record it as working-tree residue, not repo evidence.
- No candidate is strong enough:
  - Keep the accepted path as `no-successor-yet` and avoid fabricating progress.
- A single candidate clearly dominates:
  - Promote that candidate only under a new task id with its own contract/state package.

## Acceptance

- The design explicitly separates committed evidence from local residue.
- The design allows an honest “still no successor” result.
- The slice stays inside triage/reporting/decision surfaces and does not expand into feature implementation.

## Verification

- `scripts/context-build.sh --task-id dd-hermes-successor-triage-v2 --agent-role commander`
- `./scripts/coordination-endpoint.sh --task-id dd-hermes-successor-evidence-audit-v1 --endpoint successor.audit`
- `./scripts/demo-entry.sh`
