---
schema_version: 2
task_id: dd-hermes-successor-triage-v1
owner: lead
experts:
  - expert-a
product_goal: Run one explicit successor-triage mainline from the archive-normalized baseline so DD Hermes can justify what should happen after the latest archived proof.
user_value: Let a DD Hermes maintainer see one explicit current mainline again while keeping successor selection tied to committed repo evidence instead of chat memory or local residue.
task_class: T1
quality_requirement: degraded-allowed
task_class_rationale: 单线程探查/裁决任务；先核对 committed repo truth，再决定是否设立下一条 bounded successor mainline。
non_goals:
  - Do not expand into unrelated runtime, provider, or gateway work.
  - Do not reopen archived proof tasks just because they are recent.
  - Do not promote untracked local residue or working-tree-only artifacts into repo-level successor evidence.
  - Do not silently leave the repo in a fake “no task” state once successor triage itself has become the bounded next step.
product_acceptance:
  - The committed repo candidate pool is re-read from archive, state, and commander truth sources instead of chat-only recollection.
  - The task ends with one of two honest outputs: either a clearly justified successor mainline is chosen under a new task id, or DD Hermes records why no successor is yet justified.
  - Entry and strategy surfaces point to this triage mainline while it is active, rather than pretending there is no current work.
drift_risk: This task could drift into generic cleanup or premature feature planning if it stops discriminating between committed repo truth and local working-tree noise.
acceptance:
  - Complete sprint artifacts and verification.
blocked_if:
  - Missing committed repo facts.
  - Missing commander truth-source updates after task creation.
memory_reads:
  - memory/world/no-destruction-without-confirmation.md
memory_writes:
  - memory/task/dd-hermes-successor-triage-v1.md
---

# Sprint Contract

## Context

`dd-hermes-legacy-archive-normalization-v1` is archived and the repo truth surfaces now honestly say there is no active mainline. The next real DD Hermes task is not obviously a feature slice; it is a bounded successor-triage pass that must decide whether a next mainline exists in committed repo evidence at all.

## Scope

- In scope: committed-repo successor triage, decision synthesis, candidate rejection logs, and commander truth updates that expose this triage as the current mainline.
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

- The triage task is itself traceable as the current bounded mainline.
- The final decision distinguishes committed repo evidence from local untracked residue.
- The repo can either name the next successor honestly or explain why the slot should remain empty after this triage.

## Product Gate

- The task must remain tied to one clear DD Hermes product outcome.
- This bootstrap defaults to `T1` with `degraded-allowed` so later gates know the intended quality-seat bar.
- If the slice starts inventing feature scope before the candidate evidence is strong enough, stop and recalibrate before implementation.

## Verification

- Commands: `scripts/test-workflow.sh --task-id dd-hermes-successor-triage-v1`
- Commands: `scripts/context-build.sh --task-id dd-hermes-successor-triage-v1 --agent-role commander`
- Commands: `scripts/demo-entry.sh`
- User-visible proof: the repo exposes `dd-hermes-successor-triage-v1` as the current active mainline and the task package records why successor triage, not a feature slice, is the honest next step.

## Open Questions

- After committed-repo triage, is there one bounded successor strong enough to replace this governance mainline immediately?
