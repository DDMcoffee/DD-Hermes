---
schema_version: 2
task_id: dd-hermes-successor-triage-v2
owner: lead
experts:
  - expert-a
product_goal: Run one explicit successor-triage mainline from the successor-audit baseline so DD Hermes can justify what should happen after the latest archived proof.
user_value: Let a DD Hermes maintainer see whether any new bounded mainline now exists in committed repo truth, instead of inferring it from residue or chat memory.
task_class: T1
quality_requirement: degraded-allowed
task_class_rationale: 单线程探查/裁决任务；先核对 successor-audit 之后的 committed repo truth，再决定是否设立下一条 bounded successor mainline。
non_goals:
  - Do not expand into unrelated runtime, provider, or gateway work.
  - Do not reopen archived proof tasks just because they are recent.
  - Do not promote untracked local residue or working-tree-only artifacts into repo-level successor evidence.
  - Do not invent a feature successor purely to avoid an empty mainline slot.
product_acceptance:
  - The committed repo candidate pool is re-read from archive, state, successor-audit, and commander truth sources instead of chat-only recollection.
  - The task ends with one of two honest outputs: either a clearly justified successor mainline is chosen under a new task id, or DD Hermes records why no successor is yet justified.
  - Entry and strategy surfaces stay truthful throughout the triage, even if the outcome remains “no active mainline”.
drift_risk: This task could drift into generic cleanup or premature feature planning if it stops discriminating between committed repo truth and local working-tree noise.
acceptance:
  - Complete sprint artifacts and verification.
blocked_if:
  - Missing committed repo facts.
  - Missing decision synthesis or commander truth-source updates after the triage result is known.
memory_reads:
  - memory/world/no-destruction-without-confirmation.md
memory_writes:
  - memory/task/dd-hermes-successor-triage-v2.md
---

# Sprint Contract

## Context

`dd-hermes-successor-evidence-audit-v1` is archived and the repo truth surfaces now honestly say there is no active mainline. `successor.audit` confirms there are zero committed live candidates and one working-tree residue (`review-policy-demo`). The next real DD Hermes task is therefore not obviously a feature slice; it is a bounded successor-triage pass that must decide whether any new mainline exists in committed repo evidence at all.

## Scope

- In scope: committed-repo successor triage, candidate rejection logs, decision synthesis, and commander truth updates that explain whether a new mainline exists.
- Out of scope: new runtime/provider/plugin-loader functionality, reopening archived proof tasks, or promoting working-tree-only residue into repo truth.

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

- The triage task is itself traceable and bounded.
- The final decision distinguishes committed repo evidence from local untracked residue.
- The repo either names a justified new successor honestly or records why the slot should remain empty after this triage.

## Product Gate

- The task must remain tied to one clear DD Hermes product outcome.
- This bootstrap defaults to `T1` with `degraded-allowed` so later gates know the intended quality-seat bar.
- If the slice starts inventing feature scope before candidate evidence is strong enough, stop and recalibrate before implementation.

## Verification

- Commands: `scripts/test-workflow.sh --task-id dd-hermes-successor-triage-v2`
- Commands: `scripts/context-build.sh --task-id dd-hermes-successor-triage-v2 --agent-role commander`
- Commands: `./scripts/coordination-endpoint.sh --task-id dd-hermes-successor-evidence-audit-v1 --endpoint successor.audit`
- Commands: `./scripts/demo-entry.sh`
- User-visible proof: the repo records why a successor was or was not chosen from committed evidence only.

## Open Questions

- After committed-repo triage, is there one bounded successor strong enough to replace the empty mainline state immediately?
