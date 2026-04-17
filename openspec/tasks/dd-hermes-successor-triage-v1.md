---
status: active
owner: lead
scope: dd-hermes-successor-triage-v1
decision_log:
  - Use the archive-normalized baseline to run one explicit successor-triage pass.
checks:
  - scripts/test-workflow.sh --task-id dd-hermes-successor-triage-v1
  - scripts/context-build.sh --task-id dd-hermes-successor-triage-v1 --agent-role commander
  - scripts/demo-entry.sh
links:
  - workspace/contracts/dd-hermes-successor-triage-v1.md
  - workspace/decisions/successor-triage-routing/synthesis.md
  - 指挥文档/04-任务重校准与线程策略.md
  - 指挥文档/06-一期PhaseDone审计.md
---

# Task

## Steps

1. Collect committed repo evidence from the latest proof archive, commander truth sources, and committed task/state surfaces.
2. Record explorer findings for architecture, delivery, and curriculum perspectives under `workspace/decisions/successor-triage-routing/`.
3. Write a synthesis that either names one bounded successor or records why no successor is yet justified.
4. Expose `dd-hermes-successor-triage-v1` as the current mainline while this governance task is active.
5. Re-run workflow/context/entry verification after commander truth updates.

## Dependencies

- `openspec/archive/dd-hermes-legacy-archive-normalization-v1.md`
- `workspace/state/dd-hermes-legacy-archive-normalization-v1/state.json`
- `指挥文档/04-任务重校准与线程策略.md`
- `指挥文档/06-一期PhaseDone审计.md`

## Done Definition

- A maintainer can tell what evidence was considered and why a successor was or was not chosen.
- Commander truth surfaces show this triage task as the live mainline while it remains active.
- The next transition boundary is explicit: either hand off to a successor task package or archive this triage.

## Acceptance

- The task remains about successor triage, not latent feature implementation.
- Working-tree-only artifacts are not promoted into repo truth.
- Entry and strategy pages point at this task while it is active.

## Verification

- `scripts/test-workflow.sh --task-id dd-hermes-successor-triage-v1`
- `scripts/context-build.sh --task-id dd-hermes-successor-triage-v1 --agent-role commander`
- `./scripts/demo-entry.sh`
