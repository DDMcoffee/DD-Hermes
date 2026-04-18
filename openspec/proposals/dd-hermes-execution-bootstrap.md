---
status: superseded-by-archive
owner: lead
scope: dd-hermes-execution-bootstrap
decision_log:
  - Bootstrap task now closes around template-aligned generation and worktree-safe control-plane writes.
checks:
  - ./scripts/test-workflow.sh --task-id dd-hermes-execution-bootstrap
  - ./tests/smoke.sh all
links:
  - workspace/contracts/dd-hermes-execution-bootstrap.md
  - workspace/handoffs/dd-hermes-execution-bootstrap-expert-a-to-lead.md
  - 指挥文档/02-三层终点定义.md
---

# Proposal

## What

Close the bootstrap task around template-driven sprint generation and worktree-safe control-plane integration.

## Why

Turn the initial bootstrap scaffolding into a real, integrated execution slice that can be merged and accepted.

## Non-goals

- New runtime features outside the bootstrap and integration path.

## Acceptance

- Bootstrap artifacts are task-bound and template-aligned.
- Execution-thread script changes are integrated.
- Verification and git state are sufficient to call the task done.

## Verification

- Run `./scripts/test-workflow.sh --task-id dd-hermes-execution-bootstrap`.
- Run `./tests/smoke.sh all`.
