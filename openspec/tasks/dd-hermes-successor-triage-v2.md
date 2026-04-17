---
status: active
owner: lead
scope: dd-hermes-successor-triage-v2
decision_log:
  - Use the successor-audit baseline to run one explicit successor-triage pass after the latest proof archive.
checks:
  - scripts/test-workflow.sh --task-id dd-hermes-successor-triage-v2
  - scripts/context-build.sh --task-id dd-hermes-successor-triage-v2 --agent-role commander
  - ./scripts/coordination-endpoint.sh --task-id dd-hermes-successor-evidence-audit-v1 --endpoint successor.audit
  - ./scripts/demo-entry.sh
links:
  - workspace/contracts/dd-hermes-successor-triage-v2.md
  - workspace/decisions/successor-triage-v2-routing/synthesis.md
  - 指挥文档/04-任务重校准与线程策略.md
  - 指挥文档/06-一期PhaseDone审计.md
---

# Task

## Steps

1. Collect committed repo evidence from the latest proof archive, commander truth sources, successor-audit output, and committed task/state surfaces.
2. Record explorer findings for architecture, delivery, and curriculum perspectives under `workspace/decisions/successor-triage-v2-routing/`.
3. Write a synthesis that either names one bounded successor or records why no successor is yet justified.
4. Archive this triage task once the decision boundary is explicit.
5. Re-run workflow/context/entry verification after commander truth updates.

## Dependencies

- `openspec/archive/dd-hermes-successor-evidence-audit-v1.md`
- `workspace/state/dd-hermes-successor-evidence-audit-v1/state.json`
- `workspace/decisions/successor-evidence-audit-routing/synthesis.md`
- `指挥文档/04-任务重校准与线程策略.md`
- `指挥文档/06-一期PhaseDone审计.md`

## Done Definition

- A maintainer can tell what evidence was considered and why a successor was or was not chosen.
- The next transition boundary is explicit: either hand off to a new successor task package or archive this triage as `no-successor-yet`.
- Commander truth surfaces remain honest throughout the process.

## Acceptance

- The task remains about successor triage, not latent feature implementation.
- Working-tree-only artifacts are not promoted into repo truth.
- The result is a clear archive or successor selection, not a vague “继续观察”.

## Verification

- `scripts/test-workflow.sh --task-id dd-hermes-successor-triage-v2`
- `scripts/context-build.sh --task-id dd-hermes-successor-triage-v2 --agent-role commander`
- `./scripts/coordination-endpoint.sh --task-id dd-hermes-successor-evidence-audit-v1 --endpoint successor.audit`
- `./scripts/demo-entry.sh`
