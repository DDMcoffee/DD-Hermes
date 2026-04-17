---
schema_version: 2
from: lead
to: lead
scope: stable checkpoint for dd-hermes-legacy-archive-normalization-v1 task archive
product_rationale: Freeze the archive-normalization proof after archived DD Hermes tasks regained truthful v2 semantics and the repo no longer needs to pretend this maintenance slice is still an active mainline.
goal_drift_risk: The repo would drift if it archived this proof but kept advertising a fake active mainline or silently rolled a successor into the same task id.
user_visible_outcome: DD Hermes now shows a completed archive-truth proof and honestly reports that phase-2 currently has no active mainline.
files:
  - openspec/archive/dd-hermes-legacy-archive-normalization-v1.md
  - workspace/contracts/dd-hermes-legacy-archive-normalization-v1.md
  - workspace/handoffs/dd-hermes-legacy-archive-normalization-v1-lead-to-expert-a.md
  - workspace/handoffs/dd-hermes-legacy-archive-normalization-v1-expert-a-to-lead.md
  - workspace/handoffs/dd-hermes-legacy-archive-normalization-v1-lead-to-lead-archive.md
  - workspace/closeouts/dd-hermes-legacy-archive-normalization-v1-expert-a.md
  - workspace/state/dd-hermes-legacy-archive-normalization-v1/state.json
  - scripts/demo-entry.sh
  - 指挥文档/04-任务重校准与线程策略.md
  - 指挥文档/06-一期PhaseDone审计.md
decisions:
  - Freeze `dd-hermes-legacy-archive-normalization-v1` as the latest phase-2 proof after recording execution commit `c0237e5163a9cb8d5477765b586f8571bb7370d6`.
  - Clear `current_mainline_task_id` after archive instead of fabricating a successor from the cleaner backlog.
  - Keep the archive boundary narrow: this task proves archive-truth normalization, not future successor selection.
risks:
  - The repo still needs a fresh successor-triage pass, but no single next mainline is yet justified strongly enough to predeclare here.
  - The expert worktree contains excluded smoke-test artifacts that should be cleaned separately from this archived proof boundary.
next_checks:
  - Use this archive as the new baseline before choosing any successor phase-2 task.
  - If a successor is chosen later, create a new task package rather than mutating this archived proof.
---

# Lead Handoff

## Context

This handoff captures the stable archive checkpoint after `dd-hermes-legacy-archive-normalization-v1` closed its bounded proof. The repository now has truthful archive semantics for historical proofs and an entry surface that can say “latest proof archived, no active mainline” without fabricating progress.

## Required Fields

- `from`
- `to`
- `scope`
- `product_rationale`
- `goal_drift_risk`
- `user_visible_outcome`
- `files`
- `decisions`
- `risks`
- `next_checks`

## Acceptance

- The archive-normalization proof is frozen under the correct task id with execution-anchor-backed archive evidence.
- Commander truth surfaces no longer describe this task as an active mainline.
- The repo returns to an honest “no active mainline” state after archive.

## Product Check

- Confirm the closeout keeps DD Hermes honest: a bounded maintenance proof becomes an archive, and the next successor remains undecided until repo evidence supports it.

## Verification

- `./scripts/check-artifact-schemas.sh --task-id dd-hermes-legacy-archive-normalization-v1` -> pass
- `./scripts/state-read.sh --task-id dd-hermes-legacy-archive-normalization-v1` shows `status=done`, `mode=archive`, and `openspec.archive_path` set
- `./scripts/demo-entry.sh` shows the latest proof and succeeds with no current mainline
- `bash tests/smoke.sh all` -> pass

## Open Questions

- Which next bounded DD Hermes task, if any, now has enough repo evidence to become the successor phase-2 mainline?
