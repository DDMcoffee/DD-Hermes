---
status: design
owner: lead
scope: dd-hermes-successor-evidence-audit-v1
decision_log: []
checks:
  - ./scripts/context-build.sh --task-id dd-hermes-successor-evidence-audit-v1 --agent-role commander
  - ./scripts/demo-entry.sh
links:
  - workspace/contracts/dd-hermes-successor-evidence-audit-v1.md
  - workspace/decisions/successor-evidence-audit-routing/synthesis.md
---

# Design

## Summary

DD Hermes already has the policy that only committed repo evidence may justify a successor mainline, and it already teaches that local residue must not be promoted into repo truth. This task adds the missing operational layer: one executable audit result that reports live committed candidates, archived proof coverage, local residue, and the current successor verdict, then lets `demo-entry` reuse that truth instead of relying only on manually curated prose.

## Interfaces

- `scripts/successor-evidence-audit.sh`
- `scripts/coordination-endpoint.sh`
- `scripts/demo-entry.sh`
- `docs/coordination-endpoints.md`
- `tests/smoke.sh`

## Data Flow

1. Read landing truth from `指挥文档/06-一期PhaseDone审计.md` to locate `latest_proof_task_id` and `current_mainline_task_id`.
2. Enumerate task-package surfaces under `workspace/contracts/`, `workspace/state/`, and `openspec/{proposals,designs,tasks,archive}/`.
3. For each discovered task id, distinguish tracked/committed surfaces from untracked working-tree-only residue.
4. Classify task ids into archived proof history, live committed candidates, and local residue candidates.
5. Emit one audit payload with `verdict`, `reasons`, candidate lists, residue lists, and summary counts.
6. Let `demo-entry` consume the audit summary when there is no current active mainline.

## Edge Cases

- If `current_mainline_task_id` is set, the audit should report that active mainline instead of inventing a no-mainline verdict.
- Archived tasks should not be reclassified as live candidates just because they still have proposal/task/state artifacts on disk.
- Working-tree residue may include non-`dd-hermes-*` task ids; the audit must label them explicitly as local residue rather than silently dropping them.
- The audit must stay informative even when there are zero live candidates and zero residue items.

## Acceptance

- The design explicitly separates committed candidate truth from local residue truth.
- The slice stays inside audit/reporting/entry surfaces and does not reopen archived proof scope.
- The design keeps “no active mainline” as a legal verdict, but makes the evidence behind it executable.

## Verification

- `./scripts/context-build.sh --task-id dd-hermes-successor-evidence-audit-v1 --agent-role commander`
- `./scripts/demo-entry.sh`
