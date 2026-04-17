---
status: active
owner: lead
scope: dd-hermes-legacy-archive-normalization-v1
decision_log:
  - Normalize archived proof truth instead of inventing a new feature mainline, because repo evidence now clearly favors archive-control-plane repair.
  - Treat `T0/T1` archived tasks as `execution_closeout = not-required` so no-execution history stops surfacing fake blocked slices.
  - Backfill representative legacy archived execution tasks to schema v2 rather than accepting permanently broken archive checks.
checks:
  - ./scripts/test-workflow.sh --task-id dd-hermes-legacy-archive-normalization-v1
  - ./scripts/context-build.sh --task-id dd-hermes-legacy-archive-normalization-v1 --agent-role commander
  - bash tests/smoke.sh all
links:
  - workspace/contracts/dd-hermes-legacy-archive-normalization-v1.md
  - openspec/tasks/dd-hermes-legacy-archive-normalization-v1.md
  - workspace/exploration/exploration-lead-dd-hermes-legacy-archive-normalization-v1.md
---

# Design

## Problem

Archived DD Hermes proof tasks are split across two incompatible eras. Newer tasks speak in schema-v2 product / quality / verdict terms, while several older proof tasks still expose empty v1 state, missing product anchors, or placeholder closeout truth. The result is that archive history is technically present but operationally misleading.

## Decision

Normalize archive truth in three layers:

1. Shared semantics:
   `scripts/artifact_semantics.py` must treat `task_class_bucket = no-execution` as `execution_closeout = not-required`.
2. Legacy task metadata:
   Archived proof contracts that still lack schema-v2 product metadata must be backfilled with explicit `product_goal / user_value / task_class / quality_requirement / task_class_rationale / non_goals / product_acceptance / drift_risk`.
3. Representative execution proof repair:
   Archived execution tasks whose closeouts are still missing schema-v2 quality-review fields must gain real `quality_review_status / quality_findings_summary / Quality Review` sections, and their state must refresh against those anchors.

## Non-goals

- Reopening archived product scope or re-implementing historical features.
- Treating archive hygiene as a license for generic README or commander-doc cleanup.
- Inventing a new phase-2 mainline while archive truth is the actual unresolved gap.

## Acceptance

- No-execution archived tasks stop surfacing fake blocked execution-closeout truth.
- Representative legacy archived execution tasks regain coherent schema/state/closeout truth.
- The normalization task itself remains a bounded control-plane slice with explicit verification.

## Verification

- `./scripts/test-workflow.sh --task-id dd-hermes-legacy-archive-normalization-v1`
- `./scripts/context-build.sh --task-id dd-hermes-legacy-archive-normalization-v1 --agent-role commander`
- `./scripts/check-artifact-schemas.sh --task-id dd-hermes-demo-entry-v1`
- `./scripts/check-artifact-schemas.sh --task-id dd-hermes-s5-2expert-20260416`
- `bash tests/smoke.sh all`
