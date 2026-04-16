---
status: archived
owner: lead
scope: dd-hermes-anchor-governance-v1
decision_log:
  - Closed the phase-2 anchor-governance task by freezing the integrated execution slice on `main` and backfilling the archive record around it.
  - Kept degraded supervision explicit and truthful instead of pretending an independent skeptic seat existed for this phase.
checks:
  - bash -n scripts/team_governance.py scripts/state-init.sh scripts/state-update.sh scripts/state-read.sh scripts/context-build.sh scripts/dispatch-create.sh hooks/thread-switch-gate.sh hooks/quality-gate.sh scripts/check-artifact-schemas.sh tests/smoke.sh
  - python3 -m py_compile scripts/team_governance.py
  - ./scripts/test-workflow.sh --task-id dd-hermes-anchor-governance-v1
  - ./scripts/check-artifact-schemas.sh --task-id dd-hermes-anchor-governance-v1
  - ./scripts/dispatch-create.sh --task-id dd-hermes-anchor-governance-v1
  - ./hooks/thread-switch-gate.sh --task-id dd-hermes-anchor-governance-v1 --target execution
  - ./scripts/demo-entry.sh
  - ./tests/smoke.sh all
links:
  - openspec/proposals/dd-hermes-anchor-governance-v1.md
  - workspace/contracts/dd-hermes-anchor-governance-v1.md
  - workspace/handoffs/dd-hermes-anchor-governance-v1-lead-to-expert-a.md
  - workspace/closeouts/dd-hermes-anchor-governance-v1-expert-a.md
  - workspace/state/dd-hermes-anchor-governance-v1/state.json
  - workspace/decisions/anchor-governance-routing/synthesis.md
  - scripts/artifact_semantics.py
  - scripts/team_governance.py
  - hooks/quality-gate.sh
  - docs/artifact-schemas.md
  - docs/coordination-endpoints.md
  - README.md
  - 指挥文档/04-任务重校准与线程策略.md
  - 指挥文档/06-一期PhaseDone审计.md
  - 指挥文档/08-恒定锚点策略.md
---

# Archive

## Result

`dd-hermes-anchor-governance-v1` now closes the first phase-2 anchor-governance slice with integrated gate enforcement, explicit degraded supervision acknowledgement, and a truthful archive record under the correct task id.

## Deviations

- The task remains degraded by design because lead still overlaps supervisor and skeptic for this phase-2 slice.
- The archive records an execution-ready completion proof rather than a new runtime, scheduler, or provider layer.

## Risks

- Future phase-2 work should not infer that degraded supervision is the long-term target; it is only the accepted truth for this slice.
- Readers must use the execution closeout and the archive record together when tracing the integrated evidence.

## Acceptance

- Product and quality anchors are visible in state, context, dispatch, thread gate, and completion gate.
- The task now has contract, state, proposal, handoff, decision synthesis, closeout, and archive evidence.
- The integrated execution slice is frozen on `main` and can be identified by commit anchors in the task state and closeout.

## Verification

- `bash -n scripts/team_governance.py scripts/state-init.sh scripts/state-update.sh scripts/state-read.sh scripts/context-build.sh scripts/dispatch-create.sh hooks/thread-switch-gate.sh hooks/quality-gate.sh scripts/check-artifact-schemas.sh tests/smoke.sh`
- `python3 -m py_compile scripts/team_governance.py`
- `./scripts/test-workflow.sh --task-id dd-hermes-anchor-governance-v1`
- `./scripts/check-artifact-schemas.sh --task-id dd-hermes-anchor-governance-v1`
- `./scripts/dispatch-create.sh --task-id dd-hermes-anchor-governance-v1`
- `./hooks/thread-switch-gate.sh --task-id dd-hermes-anchor-governance-v1 --target execution`
- `./scripts/demo-entry.sh`
- `./tests/smoke.sh all`
