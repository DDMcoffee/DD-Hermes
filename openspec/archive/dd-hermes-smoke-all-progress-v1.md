---
status: archived
owner: lead
scope: dd-hermes-smoke-all-progress-v1
decision_log:
  - Promote smoke progress truth as a bounded phase-2 proof after the repo returned to no active mainline but the authoritative full smoke gate still looked silent while running.
  - Keep `bash tests/smoke.sh all` as the authoritative surface and add progress truth on stderr instead of inventing a replacement runner.
  - Archive the slice once shared-root verification confirmed visible section progress and the original stdout JSON success contract remained intact.
checks:
  - ./scripts/test-workflow.sh --task-id dd-hermes-smoke-all-progress-v1
  - ./scripts/context-build.sh --task-id dd-hermes-smoke-all-progress-v1 --agent-role commander
  - ./scripts/check-artifact-schemas.sh --task-id dd-hermes-smoke-all-progress-v1
  - ./hooks/quality-gate.sh --event Stop --state workspace/state/dd-hermes-smoke-all-progress-v1/state.json
  - ./scripts/demo-entry.sh
  - bash tests/smoke.sh all
links:
  - workspace/contracts/dd-hermes-smoke-all-progress-v1.md
  - workspace/handoffs/dd-hermes-smoke-all-progress-v1-lead-to-expert-a.md
  - workspace/handoffs/dd-hermes-smoke-all-progress-v1-expert-a-to-lead.md
  - workspace/handoffs/dd-hermes-smoke-all-progress-v1-lead-to-lead-archive.md
  - workspace/closeouts/dd-hermes-smoke-all-progress-v1-expert-a.md
  - workspace/state/dd-hermes-smoke-all-progress-v1/state.json
  - 指挥文档/03-产品介绍与使用说明.md
  - 指挥文档/04-任务重校准与线程策略.md
  - 指挥文档/06-一期PhaseDone审计.md
---

# Archive

## Result

`dd-hermes-smoke-all-progress-v1` closes as a bounded observability proof: DD Hermes now makes the authoritative full smoke gate legible while it is running, instead of leaving maintainers to guess whether `bash tests/smoke.sh all` is still advancing.

## Deviations

- This slice does not redesign smoke coverage or add a second runner.
- The product design philosophy update lives in `指挥文档/03-产品介绍与使用说明.md`; the proof itself stays focused on smoke progress truth.

## Risks

- Future automation consumers may still want a machine-readable streaming surface beyond stderr lines; that would need a new bounded task id.
- The latest governance slice remains `dd-hermes-residue-remediation-hints-v1`; this archive only updates the latest proof lineage.

## Acceptance

- `bash tests/smoke.sh all` emits top-level section progress truth on stderr.
- A maintainer can localize a stop or failure to one top-level section without `bash -x`.
- The final stdout success contract remains unchanged.

## Verification

- `./scripts/test-workflow.sh --task-id dd-hermes-smoke-all-progress-v1`
- `./scripts/context-build.sh --task-id dd-hermes-smoke-all-progress-v1 --agent-role commander`
- `./scripts/check-artifact-schemas.sh --task-id dd-hermes-smoke-all-progress-v1`
- `./hooks/quality-gate.sh --event Stop --state workspace/state/dd-hermes-smoke-all-progress-v1/state.json`
- `./scripts/demo-entry.sh`
- `bash tests/smoke.sh all`
