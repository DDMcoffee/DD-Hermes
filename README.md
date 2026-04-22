# DD Hermes

DD Hermes is a workspace-first engineering harness for complex agent work in Codex-style development environments.
It is not a new runtime, provider, or chat product. Its job is to turn long, fragile, chat-driven execution into explicit, reviewable, and reusable control-plane artifacts inside the repository.

> V1 release position: this repository is being published as a reusable control-plane skeleton with task artifacts, scripts, hooks, and cross-repo execution guidance. Ongoing `V2/` drafts are intentionally outside the stability promise of this release.

## Language Support

- Primary language: English
- Release summary support: Japanese, Korean, Chinese
- Some deeper operational materials under `指挥文档/` and parts of `docs/` remain Chinese-first for now

## GitHub Release Surface

- Stable entry: `README.md`
- Quick start: [`docs/quickstart.md`](docs/quickstart.md)
- Release scope and publishing notes: [`docs/github-release-v1.md`](docs/github-release-v1.md)
- Full release copy: [`docs/releases/github-v1.0.0.md`](docs/releases/github-v1.0.0.md)
- Short release copy: [`docs/releases/github-v1.0.0-short.md`](docs/releases/github-v1.0.0-short.md)
- Contributor guide: [`CONTRIBUTING.md`](CONTRIBUTING.md)
- License: `MIT` via [`LICENSE`](LICENSE)
- Runtime entrypoint: `./scripts/demo-entry.sh`

## What V1 Includes

- Explicit task artifacts such as `contract`, `state`, `context`, `handoff`, `verification`, and `closeout`
- A single-thread external workflow with protocol-level internal roles
- Scripts and hooks for guardrails, workflow control, state management, and validation
- Cross-repo execution patterns that keep control-plane artifacts separate from target business code
- A repository structure designed to be inspectable, auditable, and reusable

## What DD Hermes Is Not

- A new agent runtime
- A provider, gateway, or plugin loader
- A replacement for your application repository
- A documentation system that substitutes chat summaries for engineering control-plane artifacts
- A framework that requires users to manually manage multiple chat threads

## Quick Start

### 1. Check current runnable status

Run:

```bash
./scripts/demo-entry.sh
```

Then read:

1. `指挥文档/06-一期PhaseDone审计.md`
2. `指挥文档/04-任务重校准与线程策略.md`

This answers three questions:

- Is DD Hermes currently usable?
- Is there an active mainline?
- What did the latest real proof demonstrate?

### 2. Continue an existing mainline

If `demo-entry.sh` shows an active mainline, the minimum read set is:

1. `workspace/contracts/<task_id>.md`
2. `workspace/state/<task_id>/state.json`
3. `workspace/handoffs/<task_id>-lead-to-<expert>.md`
4. matching `workspace/closeouts/` artifacts if execution already happened

Common commands:

```bash
./scripts/state-read.sh --task-id <task_id>
./scripts/context-build.sh --task-id <task_id> --agent-role commander
./hooks/quality-gate.sh --event Stop --state workspace/state/<task_id>/state.json
```

### 3. Start a new bounded slice

If there is no active mainline, do not create a new task from chat memory alone.

Start from:

1. `指挥文档/04-任务重校准与线程策略.md`
2. the latest proof under `openspec/archive/*.md`

Only open a new slice when repository evidence supports it.

### 4. Close out correctly

"Code is written" is not the same as "task is complete".

Minimum closeout flow:

1. fresh verification
2. closeout artifact
3. state writeback
4. `quality-gate`
5. archive or integration decision

## Commonly Used Files

- [`docs/quickstart.md`](docs/quickstart.md)
  - English-first getting-started guide
- [`docs/context-runtime-state-memory.md`](docs/context-runtime-state-memory.md)
  - core model for context, runtime, state, and memory
- [`docs/cross-repo-execution.md`](docs/cross-repo-execution.md)
  - how DD Hermes coordinates work in a separate target repository
- [`docs/coordination-endpoints.md`](docs/coordination-endpoints.md)
  - coordination endpoints and control-plane protocol
- [`指挥文档/03-产品介绍与使用说明.md`](指挥文档/03-产品介绍与使用说明.md)
  - Chinese product and usage guide

## Common Commands

```bash
./scripts/demo-entry.sh
./scripts/state-read.sh --task-id <task_id>
./scripts/context-build.sh --task-id <task_id> --agent-role commander
./scripts/dispatch-create.sh --task-id <task_id>
./scripts/check-artifact-schemas.sh --task-id <task_id>
./hooks/quality-gate.sh --event Stop --state workspace/state/<task_id>/state.json
bash tests/smoke.sh schema
```

## Repository Layers

- `README.md`
  - stable public entrypoint
- `docs/`
  - long-lived protocol and usage documentation
- `指挥文档/`
  - Chinese operational landing docs for the main control thread
- `workspace/` + `openspec/`
  - task-level truth sources
- `memory/`
  - cross-session long-term knowledge

## A Simple Health Check

If someone can answer the following without reading chat history, DD Hermes is in a healthy shape:

- Is there an active mainline?
- What is the task boundary?
- Who currently owns the work?
- What did the latest proof establish?
- Is the execution slice actually complete?

If those answers still depend on chat memory, the control plane is not closed properly yet.
