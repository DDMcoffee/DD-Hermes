---
schema_version: 2
task_id: dd-hermes-successor-evidence-audit-v1
owner: lead
experts:
  - expert-a
  - expert-b
product_goal: Expose successor evidence as an executable DD Hermes control-plane surface so maintainers can distinguish committed next-task candidates from working-tree residue without redoing manual repo sweeps.
user_value: Let a DD Hermes maintainer answer “为什么现在没有主线 / 下一个候选到底算不算证据” from one callable audit result instead of chat memory or ad hoc shell inspection.
task_class: T3
quality_requirement: requires-independent
task_class_rationale: 控制面与入口真相主线；需要把 successor 证据审计压成共享 endpoint/entry truth，而不是继续停留在手工裁决。
non_goals:
  - Do not expand into unrelated runtime, provider, or gateway work.
  - Do not promote working-tree residue into committed successor evidence.
  - Do not reopen archived proof tasks or mutate their archive boundaries.
  - Do not turn this slice into a generic repo linter unrelated to successor truth.
product_acceptance:
  - DD Hermes exposes one audit result that separates live committed candidates, archived proof history, and local residue.
  - `demo-entry` can reuse that audit when there is no active mainline, so “暂无主线” stops depending on manual repo sweeps.
  - The task package explains why executable successor evidence, not another feature slice, is the next bounded mainline.
drift_risk: This task could drift into generic repository cleanup if it stops serving the maintainer-visible question of whether a next bounded mainline actually exists in committed repo truth.
acceptance:
  - Complete sprint artifacts and verification.
blocked_if:
  - Missing evidence that manual successor sweeps and residue rejection are still the current maintainer-visible gap.
  - Scope expands into unrelated runtime/provider work or generic backlog gardening.
memory_reads:
  - memory/world/no-destruction-without-confirmation.md
memory_writes:
  - memory/task/dd-hermes-successor-evidence-audit-v1.md
---

# Sprint Contract

## Context

`dd-hermes-independent-skeptic-dispatch-v1` is archived and the repo again has no active mainline. The next real DD Hermes gap is no longer another archived proof boundary; it is that successor evidence still lives in manual shell sweeps and decision prose. Repeated committed docs and triage artifacts insist that committed repo evidence must be separated from working-tree residue such as `review-policy-demo`, but there is not yet one executable control-plane surface that performs that audit and feeds the entry layer.

## Scope

- In scope: successor-evidence audit script, coordination endpoint wiring, entry-surface reuse, docs, tests, and task-bound decision synthesis.
- Out of scope: feature delivery beyond audit/reporting, runtime/provider changes, reopening archived proofs, or promoting residue into repo truth.

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

- The mainline package is internally consistent and tied to one clear control-plane gap.
- One callable audit result distinguishes committed candidates from local residue and explains the current successor verdict.
- The slice stays bounded to audit/reporting truth rather than generic repository cleanup.

## Product Gate

- The task must remain tied to one clear DD Hermes product outcome.
- This bootstrap defaults to `T3` with `requires-independent` so later gates know the intended quality-seat bar.
- If the work stops helping the system answer “what committed successor evidence actually exists right now?”, stop and recalibrate before implementation.

## Verification

- Commands: `scripts/test-workflow.sh --task-id dd-hermes-successor-evidence-audit-v1`
- Commands: `scripts/context-build.sh --task-id dd-hermes-successor-evidence-audit-v1 --agent-role commander`
- Commands: `./scripts/spec-first.sh --changed-files scripts/successor-evidence-audit.sh,scripts/coordination-endpoint.sh,scripts/demo-entry.sh,tests/smoke.sh,docs/coordination-endpoints.md,openspec/proposals/dd-hermes-successor-evidence-audit-v1.md --spec-path openspec/proposals/dd-hermes-successor-evidence-audit-v1.md --task-id dd-hermes-successor-evidence-audit-v1`
- Commands: `./scripts/coordination-endpoint.sh --task-id dd-hermes-successor-evidence-audit-v1 --endpoint successor.audit`
- Commands: `bash tests/smoke.sh endpoint`
- Commands: `bash tests/smoke.sh all`
- User-visible proof: DD Hermes points to this task as the active mainline, and the audit surface can explain why committed candidates do or do not justify a successor without reading chat history.

## Open Questions

- Should future candidate-pool cleanup work be absorbed into this audit surface, or remain separate bounded tasks that the audit only reports?
