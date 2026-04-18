# Exploration Log

## Context

- Task: dd-hermes-residue-remediation-hints-v1
- Role: lead
- Status: SUCCESSOR_AFTER_TRIAGE_V2

## Facts

- `dd-hermes-successor-evidence-audit-v1` and `dd-hermes-successor-triage-v2` are archived; the repo still has no active mainline.
- `./scripts/coordination-endpoint.sh --task-id dd-hermes-successor-evidence-audit-v1 --endpoint successor.audit` returns one remaining residue item: `review-policy-demo`.
- `successor.audit` already distinguishes residue from committed candidates, but it does not yet tell maintainers whether to delete, promote, or ignore that residue.
- `demo-entry` only reports residue counts and task ids, so maintainers still need archive prose to infer the next action.

## Hypotheses

- The narrowest maintainer-visible gap is no longer successor selection itself; it is residue remediation guidance.
- Updating the existing audit and entry surfaces is sufficient; a new endpoint is not yet required.

## Evidence

- `scripts/successor-evidence-audit.sh`
- `scripts/demo-entry.sh`
- `tests/smoke.sh`
- `openspec/archive/dd-hermes-successor-evidence-audit-v1.md`
- `openspec/archive/dd-hermes-successor-triage-v2.md`
- `指挥文档/04-任务重校准与线程策略.md`

## Acceptance

- The task package explains why residue remediation hints are now the next bounded mainline.

## Verification

- Confirm `scripts/test-workflow.sh --task-id dd-hermes-residue-remediation-hints-v1` passes after package updates.
- Confirm `scripts/context-build.sh --task-id dd-hermes-residue-remediation-hints-v1 --agent-role commander` passes once synthesis and state updates are wired.

## Open Questions

- Should the first hint vocabulary be fully structured, or should it start with one stable recommended-action enum plus human-readable text?
