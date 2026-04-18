---
schema_version: 2
task_id: dd-hermes-smoke-all-progress-v1
owner: lead
experts:
  - expert-a
product_goal: Make shared-root `bash tests/smoke.sh all` emit trustworthy phase progress so a maintainer can tell whether the authoritative full regression gate is still advancing, and which section failed, without sacrificing the final stdout JSON contract.
user_value: A DD Hermes maintainer running the full smoke gate can distinguish “still running” from “hung”, and can see the last completed or failing section directly in stderr/log output instead of waiting through a silent long run.
task_class: T2
quality_requirement: degraded-allowed
task_class_rationale: 边界清晰、低风险写集的实现切片，允许 degraded 但必须显式确认。
non_goals:
  - Do not redesign the smoke coverage matrix or split `all` into a separate orchestration product.
  - Do not change the final stdout JSON success contract that existing callers rely on.
  - Do not treat this slice as a generic logging framework for every script in the repo.
product_acceptance:
  - `bash tests/smoke.sh all` emits per-section progress truth while running from the shared root.
  - When a section fails, the maintainer can see which section stopped the suite without adding `bash -x`.
  - The final stdout line remains the existing JSON pass payload so current success consumers do not regress.
drift_risk: This task could drift into generic smoke refactoring or external runner redesign if it stops serving the maintainer-visible question “is the full gate still moving, and where did it stop?”.
acceptance:
  - Shared-root full smoke progress is visible and task-bound verification passes.
blocked_if:
  - The slice cannot show a concrete shared-root observability gap in the current smoke gate.
  - The design would require rewriting unrelated verification surfaces.
memory_reads:
  - memory/world/no-destruction-without-confirmation.md
memory_writes:
  - memory/task/dd-hermes-smoke-all-progress-v1.md
---

# Sprint Contract

## Context

The repo has no active mainline and no remaining residue. The narrowest remaining maintainer-visible gap is the authoritative shared-root full regression gate: `bash tests/smoke.sh all` can stay silent for a long time, which makes it hard to tell whether the suite is still progressing or which section was last reached without switching to `bash -x`.

## Scope

- In scope: `tests/smoke.sh` orchestration progress truth, one narrow verification surface for that behavior, and the docs/task artifacts required to explain the contract.
- Out of scope: new smoke sections, router/gate/control-plane redesign, or unrelated runtime/provider work.

## Required Fields

- `task_id`
- `owner`
- `experts`
- `product_goal`
- `user_value`
- `task_class`
- `quality_requirement`
- `task_class_rationale`
- `non_goals`
- `product_acceptance`
- `drift_risk`
- `acceptance`
- `blocked_if`
- `memory_reads`
- `memory_writes`

## Acceptance

- `bash tests/smoke.sh all` emits visible section progress during shared-root execution.
- A failing section is identifiable without `bash -x`.
- The suite still ends with the same stdout JSON success line when it passes.

## Product Gate

- The task must remain tied to one clear DD Hermes product outcome.
- This slice defaults to `T2` with `degraded-allowed` so later gates know the intended quality-seat bar.
- If the work starts expanding into external runner redesign, stop and recalibrate before implementation.

## Verification

- `scripts/test-workflow.sh --task-id dd-hermes-smoke-all-progress-v1`
- `bash tests/smoke.sh entry`
- `bash tests/smoke.sh schema`
- shared-root smoke run with stderr capture shows section progress markers and still preserves the final stdout JSON line

## Open Questions

- Should progress truth stay stderr-only forever, or later graduate into a dedicated machine-readable wrapper for automation consumers?
