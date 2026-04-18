---
schema_version: 2
task_id: dd-hermes-residue-remediation-hints-v1
owner: lead
experts:
  - expert-a
product_goal: Expose residue remediation hints through the DD Hermes control plane so maintainers know how to resolve working-tree residue after successor audit says there is no active mainline.
user_value: Let a DD Hermes maintainer see the next safe action for residue such as `review-policy-demo` directly from `successor.audit` and `demo-entry`, instead of reconstructing policy from old archive prose.
task_class: T2
quality_requirement: degraded-allowed
task_class_rationale: 边界清晰的控制面实现切片；只收口 residue remediation truth 到 endpoint/entry/docs/tests，不重写线程模型或任务选择逻辑。
non_goals:
  - Do not expand into unrelated runtime, provider, or gateway work.
  - Do not promote residue into repo-level successor evidence automatically.
  - Do not auto-delete local residue or mutate the working tree as a side effect of audit.
  - Do not reopen archived proof tasks or rerun successor triage inside this slice.
  - Do not turn residue handling into a generic repo janitor framework.
product_acceptance:
  - `successor.audit` emits residue remediation guidance that distinguishes observation from action.
  - `demo-entry` surfaces a concise residue action summary whenever local residue exists.
  - Smoke tests cover both generic residue and `working-tree-mainline-only` remediation paths.
drift_risk: This task could drift into generic cleanup or another empty successor loop if it stops improving the maintainer-visible question “what should I do with the residue I just saw?”.
acceptance:
  - Complete sprint artifacts and verification.
blocked_if:
  - Missing repo evidence that residue is still a maintainer-visible gap after successor-audit and triage-v2 archive.
  - Scope expands into auto-cleanup, deletion, or feature successor promotion.
memory_reads:
  - memory/world/no-destruction-without-confirmation.md
memory_writes:
  - memory/task/dd-hermes-residue-remediation-hints-v1.md
---

# Sprint Contract

## Context

`dd-hermes-successor-evidence-audit-v1` and `dd-hermes-successor-triage-v2` are both archived. The repo now honestly reports `no active mainline`, but `successor.audit` still returns local residue like `review-policy-demo` without telling the maintainer what action is expected. The next bounded gap is therefore not another selection loop; it is turning residue from a passive warning into actionable control-plane guidance.

## Scope

- In scope: residue classification/remediation hints in `successor.audit`, entry-surface reuse, docs, tests, and task-bound decision synthesis.
- Out of scope: auto-deleting residue, promoting residue to live candidate status, rerunning successor selection, or broader repo cleanup.

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

- Residue handling remains task-bound and improves one maintainer-visible outcome.
- The final implementation distinguishes “what residue exists” from “what safe action is recommended”.
- Entry, endpoint, docs, and tests tell the same residue-remediation story.

## Product Gate

- The task must remain tied to one clear DD Hermes product outcome.
- This bootstrap defaults to `T2` with `degraded-allowed` so later gates know the intended quality-seat bar.
- If the slice starts expanding into auto-cleanup, new successor selection, or unrelated repo janitor work, stop and recalibrate before implementation.

## Verification

- Commands: `scripts/test-workflow.sh --task-id dd-hermes-residue-remediation-hints-v1`
- Commands: `scripts/context-build.sh --task-id dd-hermes-residue-remediation-hints-v1 --agent-role commander`
- Commands: `./scripts/coordination-endpoint.sh --task-id dd-hermes-successor-evidence-audit-v1 --endpoint successor.audit`
- Commands: `./scripts/demo-entry.sh`
- Commands: `bash tests/smoke.sh endpoint`
- Commands: `bash tests/smoke.sh all`
- User-visible proof: DD Hermes can explain not only that residue exists, but what the maintainer should do next.

## Open Questions

- Should residue guidance stay embedded inside `successor.audit`, or later graduate into a dedicated residue endpoint once more than one residue policy exists?
