# Exploration Log

## Context

- Task: dd-hermes-backlog-truth-hygiene-v1
- Role: lead
- Goal: decide whether stale candidate artifacts should be archived or kept as live successor candidates.

## Facts

- `指挥文档/04-任务重校准与线程策略.md` and `./scripts/demo-entry.sh` both say there is currently no active mainline.
- `openspec/proposals/dd-hermes-commander-doc-consolidation-v1.md` is proposal-only, but its acceptance is already reflected by the current `指挥文档/` layout: the directory has `7` Markdown files and `README.md` gives a single reading order.
- `workspace/state/dd-hermes-s5-2expert-20260416/state.json` still says `status=in_progress` and `mode=execution`, while the same state also shows `lease.status=paused`.
- `./scripts/test-workflow.sh --task-id dd-hermes-s5-2expert-20260416` passes, but `./scripts/dispatch-create.sh --task-id dd-hermes-s5-2expert-20260416` is now blocked by missing product/anchor truth, so the experiment is not a resumable mainline slice in its current form.
- `openspec/proposals/dd-hermes-explicit-gate-verdicts-v1.md` and its archive explicitly rejected promoting the paused two-expert experiment into the mainline.

## Hypotheses

- The strongest current maintainer-visible gap is not a new feature slice, but stale candidate truth.
- `dd-hermes-commander-doc-consolidation-v1` should be archived as absorbed work.
- `dd-hermes-s5-2expert-20260416` should be archived as a paused experiment with bootstrap evidence but no execution slice claim.

## Evidence

- `openspec/proposals/dd-hermes-commander-doc-consolidation-v1.md`
- `openspec/proposals/dd-hermes-s5-2expert-20260416.md`
- `workspace/state/dd-hermes-s5-2expert-20260416/state.json`
- `workspace/handoffs/dd-hermes-s5-2expert-20260416-lead-to-lead-separation.md`
- `workspace/closeouts/dd-hermes-s5-2expert-20260416-expert-a.md`
- `workspace/closeouts/dd-hermes-s5-2expert-20260416-expert-b.md`
- `指挥文档/04-任务重校准与线程策略.md`
- `指挥文档/06-一期PhaseDone审计.md`
- `./scripts/demo-entry.sh`
- `./scripts/test-workflow.sh --task-id dd-hermes-s5-2expert-20260416`
- `./scripts/dispatch-create.sh --task-id dd-hermes-s5-2expert-20260416`

## Acceptance

- There is no lingering artifact that makes maintainers misread absorbed docs work or paused experiments as live successor candidates.

## Verification

- `./scripts/test-workflow.sh --task-id dd-hermes-backlog-truth-hygiene-v1`
- `./scripts/test-workflow.sh --task-id dd-hermes-s5-2expert-20260416`
- `./scripts/state-read.sh --task-id dd-hermes-s5-2expert-20260416`
- `./scripts/demo-entry.sh`

## Open Questions

- Which real maintainer-visible gap remains once stale candidate truth is cleaned?
