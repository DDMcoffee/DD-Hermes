# DD Hermes: Context / Runtime / State / Memory

These four layers must stay separate. Once an agent mixes task control state, execution facts, and long-term memory together, the workflow quickly becomes hard to recover, audit, or extend safely.

## Definitions

- `runtime`
  - a snapshot of current execution facts
  - examples: repo root, current worktree, git branch, available hooks, available tests, shell, dirty files
  - properties: ephemeral, recomputable, not a source of policy
- `state`
  - the short-term control plane for the current task
  - examples: current mode, blockers, latest verification, latest context packet, latest runtime snapshot
  - should also contain role-governance truth such as `team.role_integrity`, whether an `independent_skeptic` exists, and whether scale-out is needed
  - should also contain the fields consumed directly by discussion gates and execution gates such as `discussion.*`, `lease.*`, `contract_path`, `handoff_paths`, `exploration_paths`, and `openspec`
  - should persist the two constant anchors explicitly:
    - `product`
      - product goal, user value, non-goals, and drift signals
      - `task_class`, `quality_requirement`, and `task_class_rationale` are first-class control-plane fields
    - `quality`
      - quality-anchor review state, key findings, and examples
  - stored at `workspace/state/<task_id>/state.json` and `events.jsonl`
  - properties: mutable, task-scoped, shorter-lived than memory
- `context`
  - the assembled input packet for a specific execution pass
  - sources: contract, handoff, exploration, OpenSpec, state, runtime, and relevant memory
  - stored at `workspace/state/<task_id>/context.json`
  - properties: derived, disposable, rebuildable
- `memory`
  - cross-session knowledge cards
  - examples: user preferences, world constraints, task lessons, self-error patterns
  - stored at `memory/{user,task,world,self}/` and `memory/journal/`
  - properties: governance-first, conflict-tolerant, not overwritten by short-term state

## Invariants

- `runtime -> state`
  - runtime can update observational state fields such as the latest runtime snapshot path
- `state -> context`
  - state determines which control information is exposed to the execution thread
  - role degradation must not stay hidden inside state; if `Skeptic` is not independent, context must expose that fact too
  - product goals must not stay hidden in a north-star note; if `product.goal` is missing or drifting, context and gates must expose it
- `memory -> context`
  - memory enters context through retrieval, but context does not automatically rewrite memory
- `policy != memory mutation`
  - policy may be referenced by memory, but policy must not be rewritten through the memory-write path
- `context != truth`
  - context is an assembled view at a moment in time, not the final source of truth

## Thread Model

- default: single thread
  - one thread handles planning, decomposition, implementation, review, acceptance, and state progression
  - `Lead`, `Explorer`, `Executor`, `Skeptic`, and `Judge` are logical roles, not separate chat threads by default
  - `Product Anchor` maps to `Supervisor` by default and owns goal boundaries and user value
  - `Quality Anchor` maps to `Skeptic` by default and owns architecture consistency, error handling, performance, safety, and evidence gaps
- worktree
  - still used as a code-isolation mechanism to keep intermediate implementation states out of the main workspace
  - `.worktrees/` now represents implementation isolation, not external chat-thread isolation
- explicit artifact sync
  - multi-agent coordination depends on explicit artifacts, not chat memory
  - minimum sync set: `contract + state + context + handoff`

## Lease / Pause / Resume

- Long-running tasks should not assume the same thread will stay available forever.
- `state.lease` records:
  - `goal`
  - `status`
  - `duration_hours`
  - `started_at`
  - `deadline_at`
  - `paused_at`
  - `pause_reason`
  - `resume_after`
  - `resume_checkpoint`
  - `dispatch_cursor`
- When the host reports a Codex quota hit, the current thread only needs to write back:
  - `lease.status=paused`
  - `pause_reason=codex_quota`
  - `resume_after=<next window>`
- On resume, return to the current thread, read state, rebuild context, and continue implementation without depending on old chat context still being complete.

## Scripts

- `scripts/runtime-report.sh`
  - generate an execution-surface capability snapshot
- `scripts/state-init.sh`
  - initialize short-term task state
- `scripts/state-read.sh`
  - read state and emit a derived summary
- `scripts/state-update.sh`
  - update short-term state and append a state event
- `scripts/context-build.sh`
  - assemble the context packet consumed before execution
- `scripts/memory-refresh-views.sh`
  - refresh long-term knowledge views

## Minimum Read Set To Continue Development

If you already know the current mainline task id, the minimum files to continue safely are:

1. `workspace/contracts/<task_id>.md`
2. `workspace/state/<task_id>/state.json`
3. `workspace/handoffs/<task_id>-lead-to-<expert>.md`
4. `workspace/handoffs/<task_id>-expert-to-lead.md` if it already exists
5. `docs/coordination-endpoints.md`
6. `docs/artifact-schemas.md`
