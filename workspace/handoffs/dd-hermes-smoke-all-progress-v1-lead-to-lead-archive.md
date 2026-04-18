---
schema_version: 2
from: lead
to: lead
scope: stable checkpoint for dd-hermes-smoke-all-progress-v1 archive
product_rationale: Freeze the smoke-progress proof once the authoritative full regression gate became observable, so DD Hermes keeps this improvement as one bounded archive instead of a half-remembered shell trick.
goal_drift_risk: The repo would drift if it kept this slice active after shared-root verification had already proven the contract, or if later runner redesign work were silently folded into the same task id.
user_visible_outcome: A maintainer can now run the full smoke gate and immediately see whether it is moving and where it stopped, while still getting the old JSON success line on completion.
files:
  - openspec/archive/dd-hermes-smoke-all-progress-v1.md
  - workspace/contracts/dd-hermes-smoke-all-progress-v1.md
  - workspace/state/dd-hermes-smoke-all-progress-v1/state.json
  - workspace/closeouts/dd-hermes-smoke-all-progress-v1-expert-a.md
  - workspace/handoffs/dd-hermes-smoke-all-progress-v1-expert-a-to-lead.md
  - 指挥文档/03-产品介绍与使用说明.md
  - 指挥文档/04-任务重校准与线程策略.md
  - 指挥文档/06-一期PhaseDone审计.md
decisions:
  - Archive the slice after integrating execution commit `309e1472189d419a56e98e87271b4d2b582bc13e` through merge commit `a066124db6667ff4b83f0d7cb00dd972700dfc4d`.
  - Treat stderr progress truth as the bounded outcome, not as the start of a new runner product.
  - Return the repo to `no active mainline` after freezing this proof.
risks:
  - Any future machine-readable streaming progress surface needs its own task id.
  - The repo still has unrelated local deletions outside this task; they are not part of this archive.
next_checks:
  - Confirm `demo-entry` now reports `dd-hermes-smoke-all-progress-v1` as the latest proof after the archive commit lands.
  - Use this archive, not chat history, as the baseline if a later task wants richer smoke runner ergonomics.
---

# Lead Handoff

## Context

This handoff freezes the smoke-progress checkpoint after the expert execution slice was integrated and shared-root verification proved the new stderr contract.

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

- The smoke progress proof is archived under its own task id.
- `demo-entry` and commander truth can point to this proof instead of explaining the behavior from memory.
- The repo returns to an honest `no active mainline` state after archive.

## Product Check

- Confirm the archive keeps DD Hermes narrow: better smoke observability, no runner redesign, no fake active mainline.

## Verification

- `./scripts/check-artifact-schemas.sh --task-id dd-hermes-smoke-all-progress-v1` -> pass
- `./hooks/quality-gate.sh --event Stop --state workspace/state/dd-hermes-smoke-all-progress-v1/state.json` -> pass
- `./scripts/demo-entry.sh` -> pass
- `bash tests/smoke.sh all` -> pass

## Open Questions

- None. Any richer smoke-runner productization belongs to a future bounded task.
