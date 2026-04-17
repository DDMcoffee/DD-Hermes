---
status: active
owner: lead
scope: dd-hermes-legacy-archive-normalization-v1
decision_log:
  - Choose archive-proof normalization as the next bounded mainline because the candidate pool is now clean and repo evidence points to stale archived truth as the next real gap.
checks:
  - ./scripts/test-workflow.sh --task-id dd-hermes-legacy-archive-normalization-v1
  - ./scripts/context-build.sh --task-id dd-hermes-legacy-archive-normalization-v1 --agent-role commander
  - bash tests/smoke.sh all
links:
  - openspec/designs/dd-hermes-legacy-archive-normalization-v1.md
  - workspace/contracts/dd-hermes-legacy-archive-normalization-v1.md
---

# Task

## Steps

1. Mark `T0/T1` archived tasks as `execution_closeout = not-required` in shared semantics.
2. Update docs/tests so no-execution archive truth is treated as a valid finish state.
3. Backfill schema-v2 product/task-class metadata on legacy archived proof contracts that still expose empty v1 surfaces.
4. Repair representative archived execution closeouts so they carry schema-v2 quality review truth instead of placeholder fields.
5. Refresh the affected archived states and re-run schema/state/context validation.
6. Archive this normalization task if the repo returns to a truthful “no active mainline” state afterward.

## Dependencies

- `workspace/contracts/dd-hermes-legacy-archive-normalization-v1.md`
- archived proof tasks under `workspace/contracts/` and `workspace/state/`
- `scripts/artifact_semantics.py`

## Done Definition

- Archived proof history is usable again through `state.read` and `closeout.check`.
- No-execution archive tasks no longer pretend they owe an execution closeout.
- Representative legacy execution tasks pass current schema checks with coherent product/quality truth.

## Acceptance

- The slice stays inside archive truth normalization.
- Shared semantics, docs/tests, and representative legacy artifacts all agree on the same no-execution rule.
- Repo truth sources can honestly say there is still no active mainline after this normalization completes.

## Verification

- `./scripts/test-workflow.sh --task-id dd-hermes-legacy-archive-normalization-v1`
- `./scripts/context-build.sh --task-id dd-hermes-legacy-archive-normalization-v1 --agent-role commander`
- `./scripts/check-artifact-schemas.sh --task-id dd-hermes-demo-entry-v1`
- `./scripts/check-artifact-schemas.sh --task-id dd-hermes-s5-2expert-20260416`
- `bash tests/smoke.sh all`
