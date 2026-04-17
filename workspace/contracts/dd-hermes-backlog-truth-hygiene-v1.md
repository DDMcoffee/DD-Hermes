---
schema_version: 2
task_id: dd-hermes-backlog-truth-hygiene-v1
owner: lead
experts:
  - expert-a
product_goal: Advance DD Hermes through task dd-hermes-backlog-truth-hygiene-v1 without drifting from the current product focus.
user_value: Let a DD Hermes maintainer trust that proposal backlog, paused experiments, and commander docs all describe the same current reality instead of stale candidate noise.
task_class: T0
quality_requirement: degraded-allowed
task_class_rationale: 治理/裁决/归档/trace 收口任务，不进入 execution slice。
non_goals:
  - Do not reopen runtime/provider/gateway work.
  - Do not promote a new phase-2 feature mainline unless repo evidence clearly favors one.
  - Do not resume the paused two-expert experiment as if it were already product work.
product_acceptance:
  - Proposal-only and paused experiment artifacts that no longer reflect repo truth are archived or explicitly marked as absorbed.
  - Commander truth sources can still say `no active mainline` after candidate-pool cleanup, without leaving stale backlog ambiguity behind.
  - The next maintainer can tell which candidate directions are real, which are archived, and which are still experiments.
drift_risk: This task could drift into generic documentation cleanup if it stops tightening backlog truth around stale candidates and paused experiments.
acceptance:
  - Complete the bounded backlog-truth cleanup with runnable verification.
blocked_if:
  - Missing repo facts or missing verification.
memory_reads:
  - memory/world/no-destruction-without-confirmation.md
memory_writes:
  - memory/task/dd-hermes-backlog-truth-hygiene-v1.md
---

# Sprint Contract

## Context

`dd-hermes-explicit-gate-verdicts-v1` is archived, and the repo truth now says there is no active phase-2 mainline. Two stale artifacts still blur that truth: `dd-hermes-commander-doc-consolidation-v1` already appears completed in the docs surface but remains proposal-only, and `dd-hermes-s5-2expert-20260416` is a paused experiment whose state still reads like an unfinished execution task.

## Scope

- In scope:
  - Archive `dd-hermes-commander-doc-consolidation-v1` as absorbed docs work.
  - Archive `dd-hermes-s5-2expert-20260416` as a paused experiment that produced bootstrap evidence but no execution slice.
  - Update task-triage truth so maintainers can see that candidate-pool hygiene was completed without fabricating a new feature mainline.
- Out of scope:
  - Any new runtime, provider, endpoint, or routing feature.
  - Resuming the two-expert experiment.
  - Creating a new phase-2 feature mainline before repo evidence clearly favors one.

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

- `openspec/archive/dd-hermes-commander-doc-consolidation-v1.md` truthfully records that the docs-consolidation proposal was absorbed by the current command-doc layout.
- `dd-hermes-s5-2expert-20260416` no longer presents itself as an active execution task; its archive trail and state describe a paused experiment with no claimed execution slice.
- `指挥文档/04-任务重校准与线程策略.md` records that candidate-pool hygiene is complete while `current_mainline_task_id` still remains empty.

## Product Gate

- The only user-visible outcome is cleaner repo truth: a maintainer should stop mistaking absorbed proposals and paused experiments for live successor candidates.
- This task is `T0` governance work; it must not mutate into a hidden feature sprint.
- If the slice starts inventing a new mainline instead of cleaning stale candidate truth, stop and recalibrate.

## Verification

- Commands:
  - `./scripts/test-workflow.sh --task-id dd-hermes-backlog-truth-hygiene-v1`
  - `./scripts/test-workflow.sh --task-id dd-hermes-s5-2expert-20260416`
  - `./scripts/state-read.sh --task-id dd-hermes-s5-2expert-20260416`
  - `./scripts/demo-entry.sh`
- User-visible proof: archived/absorbed candidates are explicitly marked as such, and the commander docs still truthfully show no active mainline.

## Open Questions

- After stale candidate cleanup, which next bounded DD Hermes task actually has enough repo evidence to become the real successor mainline?
