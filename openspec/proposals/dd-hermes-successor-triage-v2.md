---
status: superseded-by-archive
owner: lead
scope: dd-hermes-successor-triage-v2
decision_log:
  - Promote successor triage itself into the next bounded mainline because `dd-hermes-successor-evidence-audit-v1` is archived and no committed feature successor currently dominates the repo evidence.
checks:
  - scripts/test-workflow.sh --task-id dd-hermes-successor-triage-v2
  - scripts/context-build.sh --task-id dd-hermes-successor-triage-v2 --agent-role commander
  - ./scripts/coordination-endpoint.sh --task-id dd-hermes-successor-evidence-audit-v1 --endpoint successor.audit
  - ./scripts/demo-entry.sh
links:
  - openspec/archive/dd-hermes-successor-evidence-audit-v1.md
  - workspace/decisions/successor-evidence-audit-routing/synthesis.md
  - 指挥文档/04-任务重校准与线程策略.md
  - 指挥文档/06-一期PhaseDone审计.md
---

# Proposal

## What

Create one explicit successor-triage mainline that rereads committed DD Hermes repo truth after `dd-hermes-successor-evidence-audit-v1` archive, decides whether a next bounded successor actually exists, and keeps the entry surface honest while that decision is in progress.

## Why

The repo can now honestly say “当前没有 active mainline”, and `successor.audit` can prove why. But that proof alone does not decide what to do next. Current committed evidence shows:

- the latest proof is already archived as `dd-hermes-successor-evidence-audit-v1`
- there are zero committed live successor candidates
- `review-policy-demo` remains only working-tree residue, not repo truth

That means the next bounded DD Hermes task is not obviously a feature slice. The honest next step is a new triage governance slice that either chooses one justified successor under a new task id or records `no-successor-yet` again with explicit evidence.

## Non-goals

- Do not reopen archived proof tasks just because they are recent.
- Do not promote `review-policy-demo` or any other working-tree residue into repo-level successor evidence.
- Do not invent a feature mainline purely to avoid an empty slot.
- Do not expand into unrelated runtime, provider, scheduler, or plugin-loader work.

## Acceptance

- The repo names `dd-hermes-successor-triage-v2` as the current bounded mainline while triage is active.
- Triage evidence distinguishes committed repo facts from local residue and archive history explicitly.
- The task concludes with one honest output: either a clearly justified successor mainline under a new task id, or a documented `no-successor-yet` archive result.

## Verification

- `scripts/test-workflow.sh --task-id dd-hermes-successor-triage-v2`
- `scripts/context-build.sh --task-id dd-hermes-successor-triage-v2 --agent-role commander`
- `./scripts/coordination-endpoint.sh --task-id dd-hermes-successor-evidence-audit-v1 --endpoint successor.audit`
- `./scripts/demo-entry.sh`
