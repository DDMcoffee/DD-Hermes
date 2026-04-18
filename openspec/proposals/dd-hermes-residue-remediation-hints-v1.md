---
status: superseded-by-archive
owner: lead
scope: dd-hermes-residue-remediation-hints-v1
decision_log:
  - Promote residue remediation hints as the next bounded mainline because successor audit still reports local residue but does not tell maintainers what to do with it.
checks:
  - scripts/test-workflow.sh --task-id dd-hermes-residue-remediation-hints-v1
  - scripts/context-build.sh --task-id dd-hermes-residue-remediation-hints-v1 --agent-role commander
links:
  - workspace/contracts/dd-hermes-residue-remediation-hints-v1.md
  - workspace/exploration/exploration-lead-dd-hermes-residue-remediation-hints-v1.md
  - workspace/decisions/residue-remediation-hints-routing/synthesis.md
---

# Proposal

## What

Start `dd-hermes-residue-remediation-hints-v1` as the active phase-2 mainline and teach DD Hermes to emit remediation guidance for working-tree residue instead of only ignoring it.

## Why

The repo no longer lacks successor evidence audit; that proof is already archived. The maintainer-visible gap that remains is narrower: `successor.audit` and `demo-entry` can identify residue such as `review-policy-demo`, but they still force maintainers to infer the correct next action from older archive prose. DD Hermes should expose that remediation advice directly in the control plane.

## Non-goals

- Do not promote residue into repo-level successor evidence automatically.
- Do not auto-delete local files or mutate the working tree as a side effect of audit.
- Do not reopen successor selection, runtime/provider work, or archived proof boundaries.
- Do not turn this slice into a generic repo janitor outside successor residue handling.

## Acceptance

- `successor.audit` reports residue-specific remediation guidance in addition to verdict/count data.
- `demo-entry` can summarize the recommended residue action when local residue exists.
- Smoke coverage proves both plain residue and `working-tree-mainline-only` paths expose actionable guidance.
- The task package explains why residue remediation hints, not another empty triage loop, are the next bounded mainline.

## Verification

- Run `scripts/test-workflow.sh --task-id dd-hermes-residue-remediation-hints-v1`.
- Run `scripts/context-build.sh --task-id dd-hermes-residue-remediation-hints-v1 --agent-role commander`.
- Run `./scripts/spec-first.sh --changed-files scripts/successor-evidence-audit.sh,scripts/demo-entry.sh,tests/smoke.sh,docs/coordination-endpoints.md,openspec/proposals/dd-hermes-residue-remediation-hints-v1.md --spec-path openspec/proposals/dd-hermes-residue-remediation-hints-v1.md --task-id dd-hermes-residue-remediation-hints-v1`.
- Run `./scripts/coordination-endpoint.sh --task-id dd-hermes-successor-evidence-audit-v1 --endpoint successor.audit`.
- Run `./scripts/demo-entry.sh`.
- Run `bash tests/smoke.sh endpoint`.
- Run `bash tests/smoke.sh all`.
