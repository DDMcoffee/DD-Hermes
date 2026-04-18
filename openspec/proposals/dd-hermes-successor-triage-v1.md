---
status: superseded-by-archive
owner: lead
scope: dd-hermes-successor-triage-v1
decision_log:
  - Promote successor triage itself into the current bounded mainline because archive normalization is complete and no committed-repo feature successor is yet clearly favored.
checks:
  - scripts/test-workflow.sh --task-id dd-hermes-successor-triage-v1
  - scripts/context-build.sh --task-id dd-hermes-successor-triage-v1 --agent-role commander
  - scripts/demo-entry.sh
links:
  - workspace/contracts/dd-hermes-successor-triage-v1.md
  - workspace/exploration/exploration-lead-dd-hermes-successor-triage-v1.md
  - 指挥文档/04-任务重校准与线程策略.md
  - 指挥文档/06-一期PhaseDone审计.md
---

# Proposal

## What

Create one explicit successor-triage mainline that re-reads committed DD Hermes repo truth, decides whether a next bounded successor actually exists, and keeps the entry surface honest while that decision is in progress.

## Why

`dd-hermes-legacy-archive-normalization-v1` already closed the archive-truth proof. What remains is not “keep coding that proof,” but “decide what the next bounded mainline should be, if any.” Leaving that decision only in chat or in a vague “暂无” state makes the repo harder to resume.

## Non-goals

- Do not reopen archived proof tasks.
- Do not invent a feature successor without committed repo evidence.
- Do not treat local untracked artifacts as if they were committed backlog candidates.

## Acceptance

- The repo names successor triage as the current bounded mainline.
- Triage evidence distinguishes committed repo facts from working-tree residue.
- The task concludes with either a clearly justified successor or a documented no-successor-yet decision.

## Verification

- Run `scripts/test-workflow.sh --task-id dd-hermes-successor-triage-v1`.
- Run `scripts/context-build.sh --task-id dd-hermes-successor-triage-v1 --agent-role commander`.
- Run `./scripts/demo-entry.sh`.
