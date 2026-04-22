# DD Hermes Quick Start

This guide is the fastest English-first path to understanding and using DD Hermes.

## What DD Hermes Does

DD Hermes is a repository-based control plane for complex agent work.
It separates execution intent, short-term task state, reusable memory, and closeout evidence so that work remains inspectable without depending on chat history.

## Fastest First Run

Run:

```bash
./scripts/demo-entry.sh
```

Then read:

1. `指挥文档/06-一期PhaseDone审计.md`
2. `指挥文档/04-任务重校准与线程策略.md`

Those two documents tell you:

- whether the harness is currently usable
- whether there is an active mainline
- what the latest real proof demonstrated

## If There Is An Active Mainline

Read, in order:

1. `workspace/contracts/<task_id>.md`
2. `workspace/state/<task_id>/state.json`
3. `workspace/handoffs/<task_id>-lead-to-<expert>.md`
4. matching `workspace/closeouts/` files if execution already happened

Useful commands:

```bash
./scripts/state-read.sh --task-id <task_id>
./scripts/context-build.sh --task-id <task_id> --agent-role commander
./hooks/quality-gate.sh --event Stop --state workspace/state/<task_id>/state.json
```

## If There Is No Active Mainline

Do not start from chat memory alone.

Instead:

1. read `指挥文档/04-任务重校准与线程策略.md`
2. inspect the latest archive under `openspec/archive/`
3. only create a new bounded slice if repository evidence supports it

## Core Model

- `runtime`
  - current execution facts
- `state`
  - short-term task control plane
- `context`
  - rebuilt execution packet for a specific run
- `memory`
  - cross-session long-term knowledge

For the full model, read [`docs/context-runtime-state-memory.md`](context-runtime-state-memory.md).

## Minimum Validation

```bash
bash tests/smoke.sh schema
./scripts/demo-entry.sh
```

## Related Docs

- [`README.md`](../README.md)
- [`docs/context-runtime-state-memory.md`](context-runtime-state-memory.md)
- [`docs/cross-repo-execution.md`](cross-repo-execution.md)
- [`docs/github-release-v1.md`](github-release-v1.md)
