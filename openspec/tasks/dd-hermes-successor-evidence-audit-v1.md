---
status: active
owner: lead
scope: dd-hermes-successor-evidence-audit-v1
decision_log:
  - Start a new bounded mainline that turns successor evidence discrimination into a callable control-plane capability.
checks:
  - scripts/test-workflow.sh --task-id dd-hermes-successor-evidence-audit-v1
  - scripts/context-build.sh --task-id dd-hermes-successor-evidence-audit-v1 --agent-role commander
  - ./scripts/demo-entry.sh
links:
  - workspace/contracts/dd-hermes-successor-evidence-audit-v1.md
  - workspace/decisions/successor-evidence-audit-routing/synthesis.md
  - 指挥文档/04-任务重校准与线程策略.md
  - 指挥文档/06-一期PhaseDone审计.md
---

# Task

## Steps

1. Materialize routing findings and synthesis for why successor evidence audit is now the bounded phase-2 mainline.
2. Add one audit script that classifies live committed candidates, archived proof history, and working-tree residue.
3. Wire the audit through `scripts/coordination-endpoint.sh` as `successor.audit`.
4. Materialize an independent skeptic lane for this `T3` task so later execution/quality review is not stuck in degraded supervision.
5. Reuse the audit summary from `scripts/demo-entry.sh` when there is no active mainline.
6. Update commander docs and endpoint docs so the mainline and the new audit surface tell the same story.
7. Prove the endpoint, entry behavior, and independent-execution-readiness path in verification.

## Dependencies

- `openspec/archive/dd-hermes-independent-skeptic-dispatch-v1.md`
- `workspace/decisions/successor-triage-routing/architecture.md`
- `workspace/contracts/dd-hermes-successor-evidence-audit-v1.md`

## Done Definition

- A maintainer can call one control-plane surface and see whether any committed successor candidate exists.
- Working-tree residue is reported explicitly as residue instead of being silently treated as repo truth.
- `demo-entry` no longer depends only on static prose to explain a no-mainline state.

## Acceptance

- The task remains about successor evidence audit, not feature planning or archive mutation.
- The audit distinguishes committed repo evidence from local residue in a way future triage can reuse.
- Entry and strategy pages point at this task while it is active.
- The task does not claim execution-ready until an actual independent skeptic lane exists for this `T3` mainline.

## Verification

- `scripts/test-workflow.sh --task-id dd-hermes-successor-evidence-audit-v1`
- `scripts/context-build.sh --task-id dd-hermes-successor-evidence-audit-v1 --agent-role commander`
- `./scripts/coordination-endpoint.sh --task-id dd-hermes-successor-evidence-audit-v1 --endpoint successor.audit`
- `bash tests/smoke.sh endpoint`
- `bash tests/smoke.sh all`
