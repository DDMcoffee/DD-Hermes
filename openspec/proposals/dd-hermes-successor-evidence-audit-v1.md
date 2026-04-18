---
status: superseded-by-archive
owner: lead
scope: dd-hermes-successor-evidence-audit-v1
decision_log:
  - Promote successor evidence audit as the new bounded mainline because repeated committed repo truth still depends on manual candidate/residue discrimination.
checks:
  - scripts/test-workflow.sh --task-id dd-hermes-successor-evidence-audit-v1
  - scripts/context-build.sh --task-id dd-hermes-successor-evidence-audit-v1 --agent-role commander
links:
  - workspace/contracts/dd-hermes-successor-evidence-audit-v1.md
  - workspace/exploration/exploration-lead-dd-hermes-successor-evidence-audit-v1.md
  - workspace/decisions/successor-evidence-audit-routing/synthesis.md
---

# Proposal

## What

Start `dd-hermes-successor-evidence-audit-v1` as the active phase-2 mainline and expose one executable audit of successor evidence through the DD Hermes control plane.

## Why

The repo can honestly say “当前没有 active mainline”, but it still takes manual shell sweeps and decision prose to prove why. Committed artifacts repeatedly distinguish committed repo evidence from working-tree residue like `review-policy-demo`, yet there is no single callable audit result that surfaces that distinction for maintainers or for `demo-entry`.

## Non-goals

- Do not invent a feature successor that committed repo evidence does not support.
- Do not promote untracked or working-tree-only residue into repo truth.
- Do not reopen archived proof tasks or mutate their archive boundaries.
- Do not turn this slice into a generic repo lint/audit framework unrelated to successor truth.

## Acceptance

- DD Hermes exposes one audit result that reports committed live candidates, archived proof coverage, local residue, verdict, and reasons.
- `demo-entry` can reuse that audit when there is no active mainline, instead of relying only on static prose.
- The task package explains why executable successor evidence is the next mainline, rather than another feature slice or another empty triage loop.

## Verification

- Run `scripts/test-workflow.sh --task-id dd-hermes-successor-evidence-audit-v1`.
- Run `scripts/context-build.sh --task-id dd-hermes-successor-evidence-audit-v1 --agent-role commander`.
- Run `./scripts/spec-first.sh --changed-files scripts/successor-evidence-audit.sh,scripts/coordination-endpoint.sh,scripts/demo-entry.sh,tests/smoke.sh,docs/coordination-endpoints.md,openspec/proposals/dd-hermes-successor-evidence-audit-v1.md --spec-path openspec/proposals/dd-hermes-successor-evidence-audit-v1.md --task-id dd-hermes-successor-evidence-audit-v1`.
- Run `./scripts/coordination-endpoint.sh --task-id dd-hermes-successor-evidence-audit-v1 --endpoint successor.audit`.
- Run `bash tests/smoke.sh endpoint`.
- Run `bash tests/smoke.sh all`.
