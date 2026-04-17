---
schema_version: 2
task_id: dd-hermes-experience-demo-v1
from: expert-a
to: lead
scope: dd-hermes-experience-demo-v1 execution slice closeout
execution_commit: 687ffa823672e42cf67a3431d9aa4b640abf2e22
state_path: workspace/state/dd-hermes-experience-demo-v1/state.json
context_path: workspace/state/dd-hermes-experience-demo-v1/context.json
runtime_path: workspace/state/dd-hermes-experience-demo-v1/runtime.json
verified_steps:
  - ./scripts/spec-first.sh --changed-files scripts/state-init.sh,scripts/sprint-init.sh,hooks/thread-switch-gate.sh,tests/smoke.sh,docs/decision-discussion.md,README.md,workspace/contracts/dd-hermes-experience-demo-v1.md,openspec/proposals/dd-hermes-experience-demo-v1.md --spec-path openspec/proposals/dd-hermes-experience-demo-v1.md --task-id dd-hermes-experience-demo-v1
  - bash -n scripts/state-init.sh scripts/sprint-init.sh hooks/thread-switch-gate.sh tests/smoke.sh
  - ./tests/smoke.sh discussion
  - ./tests/smoke.sh workflow
  - ./tests/smoke.sh all
verified_files:
  - scripts/state-init.sh
  - scripts/sprint-init.sh
  - hooks/thread-switch-gate.sh
  - tests/smoke.sh
  - docs/decision-discussion.md
  - README.md
quality_review_status: approved
quality_findings_summary:
  - Independent quality review accepted the experience-demo slice because architecture-task auto-routing and synthesis gating were both explicitly verified.
  - Heuristic routing remains intentionally narrow and is documented as a follow-up product decision rather than hidden scope creep.
open_risks:
  - Auto-routing currently infers from `task_id` and `current_focus`, which is intentionally narrow but may need explicit metadata later.
  - The stricter gate will correctly block callers that skip `context-build` or `dispatch-create`; downstream automation must respect that order.
next_actions:
  - Lead should integrate branch `dd-hermes-experience-demo-v1-expert-a` into `main`.
  - After integration, lead should archive the task and record the experience-demo proof point.
---

# Execution Closeout

## Context

Execution closeout for the first DD Hermes experience-demo slice, which tightened discussion-policy routing and execution gating.

## Required Fields

- `task_id`
- `from`
- `to`
- `scope`
- `execution_commit`
- `state_path`
- `context_path`
- `runtime_path`
- `verified_steps`
- `verified_files`
- `quality_review_status`
- `quality_findings_summary`
- `open_risks`
- `next_actions`

## Completion

- Added automatic discussion-policy routing at task initialization time.
- Propagated `current_focus` and explicit `discussion_policy` through sprint initialization.
- Hardened `thread-switch-gate` so execution requires state, contract, handoff, context, worktree, and non-placeholder synthesis.
- Added smoke coverage for missing-state, architecture-discussion, placeholder-synthesis, and direct-delivery paths.

## Verification

- `./scripts/spec-first.sh --changed-files scripts/state-init.sh,scripts/sprint-init.sh,hooks/thread-switch-gate.sh,tests/smoke.sh,docs/decision-discussion.md,README.md,workspace/contracts/dd-hermes-experience-demo-v1.md,openspec/proposals/dd-hermes-experience-demo-v1.md --spec-path openspec/proposals/dd-hermes-experience-demo-v1.md --task-id dd-hermes-experience-demo-v1` => pass
- `bash -n scripts/state-init.sh scripts/sprint-init.sh hooks/thread-switch-gate.sh tests/smoke.sh` => pass
- `./tests/smoke.sh discussion` => pass
- `./tests/smoke.sh workflow` => pass
- `./tests/smoke.sh all` => pass

## Quality Review

- Independent quality review accepted this slice because the architecture-task routing rule and the execution gate both had explicit smoke coverage and a real synthesis boundary.
- The remaining finding is product-facing, not correctness-breaking: heuristic routing should stay narrow until explicit metadata is introduced by a later task.

## Open Questions

- Whether heuristic routing should remain the phase-1 default or evolve into explicit task metadata is a follow-up product decision.
