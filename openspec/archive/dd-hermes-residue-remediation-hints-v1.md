---
status: archived
owner: lead
scope: dd-hermes-residue-remediation-hints-v1
decision_log:
  - Promote residue remediation hints as a bounded control-plane slice after successor-audit and triage-v2 left one maintainer-visible residue gap.
  - Keep residue as non-evidence and add remediation guidance instead of auto-cleanup or another successor loop.
  - Archive the slice once the expert execution commit was integrated and shared-root verification confirmed the new hint contract.
checks:
  - ./scripts/test-workflow.sh --task-id dd-hermes-residue-remediation-hints-v1
  - ./scripts/context-build.sh --task-id dd-hermes-residue-remediation-hints-v1 --agent-role commander
  - ./scripts/check-artifact-schemas.sh --task-id dd-hermes-residue-remediation-hints-v1
  - ./scripts/coordination-endpoint.sh --task-id dd-hermes-successor-evidence-audit-v1 --endpoint successor.audit
  - ./scripts/demo-entry.sh
  - bash tests/smoke.sh all
links:
  - workspace/contracts/dd-hermes-residue-remediation-hints-v1.md
  - workspace/decisions/residue-remediation-hints-routing/synthesis.md
  - workspace/handoffs/dd-hermes-residue-remediation-hints-v1-lead-to-expert-a.md
  - workspace/handoffs/dd-hermes-residue-remediation-hints-v1-expert-a-to-lead.md
  - workspace/handoffs/dd-hermes-residue-remediation-hints-v1-lead-to-lead-archive.md
  - workspace/closeouts/dd-hermes-residue-remediation-hints-v1-expert-a.md
  - workspace/state/dd-hermes-residue-remediation-hints-v1/state.json
  - 指挥文档/04-任务重校准与线程策略.md
  - 指挥文档/06-一期PhaseDone审计.md
---

# Archive

## Result

`dd-hermes-residue-remediation-hints-v1` closes as the bounded governance/execution slice that turned residue from a passive warning into explicit operator guidance.

## Deviations

- This slice does not delete or promote residue; it only exposes the next safe action.
- The latest end-to-end proof task remains `dd-hermes-successor-evidence-audit-v1`; this archive captures a narrower follow-up governance/control-plane improvement.

## Risks

- `review-policy-demo` still exists as local residue after this archive; the system now explains what to do with it, but does not resolve it automatically.
- Future residue classes may require a broader contract than the first `working-tree-only-task-package` hint.

## Acceptance

- `successor.audit` emits structured remediation hints for local residue.
- `demo-entry` summarizes the recommended residue action.
- Shared-root verification passes after integrating the execution branch.

## Verification

- `./scripts/test-workflow.sh --task-id dd-hermes-residue-remediation-hints-v1`
- `./scripts/context-build.sh --task-id dd-hermes-residue-remediation-hints-v1 --agent-role commander`
- `./scripts/check-artifact-schemas.sh --task-id dd-hermes-residue-remediation-hints-v1`
- `./scripts/coordination-endpoint.sh --task-id dd-hermes-successor-evidence-audit-v1 --endpoint successor.audit`
- `./scripts/demo-entry.sh`
- `bash tests/smoke.sh all`
