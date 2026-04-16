---
from: expert-a
to: lead
scope: dd-hermes-execution-bootstrap bootstrap artifact generation
files:
  - README.md
  - .codex/templates/EXECUTION-CLOSEOUT.md
  - docs/artifact-schemas.md
  - docs/coordination-endpoints.md
  - docs/long-term-agent-division.md
  - openspec/proposals/dd-hermes-endpoint-schema-v1.md
  - openspec/proposals/dd-hermes-endpoint-router-v1.md
  - openspec/proposals/dd-hermes-multi-agent-dispatch.md
  - scripts/check-artifact-schemas.sh
  - scripts/common.sh
  - scripts/coordination-endpoint.sh
  - scripts/dispatch-create.sh
  - scripts/state-init.sh
  - scripts/state-read.sh
  - scripts/state-update.sh
  - scripts/test-coordination-endpoint.sh
  - scripts/context-build.sh
  - scripts/team_governance.py
  - scripts/test-artifact-schemas.sh
  - scripts/runtime-report.sh
  - scripts/worktree-create.sh
  - scripts/worktree-remove.sh
  - scripts/worktree-status.sh
  - scripts/git-commit-task.sh
  - scripts/verify-loop.sh
  - scripts/sprint-init.sh
  - tests/smoke.sh
decisions:
  - Reworked `scripts/sprint-init.sh` to derive document structure from `.codex/templates/` instead of hardcoding markdown bodies.
  - Added `shared_repo_root()` so execution-thread scripts can resolve commander-side `workspace/` paths correctly from a linked worktree while preserving current-worktree defaults.
  - Added smoke assertions that fail on template placeholder leakage and missing required sections.
  - Stabilized `tests/smoke.sh schema` by seeding a memory journal entry inside `run_schema()` when schema is run standalone and by emitting explicit schema failure messages.
  - Added a long-term three-agent division spec with mandatory supervisor seat and supervisor scale-out triggers.
  - Operationalized role governance in `state-init.sh` / `state-update.sh` / `state-read.sh` / `context-build.sh` so `Supervisor` / `Executor` / `Skeptic` stop being doc-only concepts.
  - Materialized role governance into `scripts/dispatch-create.sh`, which now emits supervisor / executor / skeptic assignments and creates or confirms executor worktrees from `state.team`.
  - Switched `worktree-create.sh` and `worktree-remove.sh` to `shared_repo_root()` so dispatching from an execution worktree still targets the commander-side repo surface.
  - Added shared `scripts/team_governance.py` so state/context/dispatch all compute the same `Skeptic`-independence truth instead of drifting per script.
  - Default skeptic fallback now prefers a non-executor seat and explicitly marks `Supervisor`/`Skeptic` overlap as degraded via `role_conflicts` and `independent_skeptic=false`.
  - Exported `PYTHONDONTWRITEBYTECODE=1` from `scripts/common.sh` so helper imports do not dirty execution worktrees with `__pycache__`.
  - Added endpoint/schema documentation (`docs/coordination-endpoints.md`, `docs/artifact-schemas.md`) to map three-layer finish lines into executable control-plane contracts.
  - Added `.codex/templates/EXECUTION-CLOSEOUT.md` and extended `scripts/sprint-init.sh` to bootstrap `workspace/closeouts/<task_id>-<expert>.md` artifacts.
  - Added `scripts/check-artifact-schemas.sh` plus `scripts/test-artifact-schemas.sh`, and wired smoke schema checks to validate required fields across contract/handoff/state/closeout.
  - Added `scripts/coordination-endpoint.sh` as a unified control-plane router for `state.read/state.update/context.build/dispatch.create/closeout.check` and added endpoint smoke coverage.
risks:
  - `sprint-init.sh` maps template sections through a small renderer; if template headings change, this script must be kept in sync.
  - Existing commander-generated bootstrap artifacts are not auto-regenerated; lead should rerun `scripts/sprint-init.sh` if it wants updated docs for an already initialized task.
  - Scripts that intentionally operate on branch-local tracked files still use the current worktree root; future shared-control-plane scripts must opt into `shared_repo_root()` explicitly.
  - Current archived task still degrades to `lead` acting as both `Supervisor` and `Skeptic`; the harness now tells the truth about that state, but it does not invent an independent skeptic by itself.
  - `coordination-endpoint.sh` 路由层目前只做 endpoint 级别分发，不做 payload 语义校验；字段约束仍由各子脚本负责。
next_checks:
  - Integrate the worktree diff and rerun `./tests/smoke.sh all` from the target branch.
  - Integrate and prefer `scripts/coordination-endpoint.sh` as orchestrator entrypoint for endpoint invocations.
  - Regenerate sprint artifacts on the lead side if template-aligned bootstrap docs are required for this task record.
  - Use the new `independent_skeptic` / `role_conflicts` fields to gate the next multi-assignee task instead of assuming a nominal skeptic seat is independent.
---

# Expert Handoff

## Context

Implemented the bootstrap slice so sprint initialization now follows repository templates and emits fuller task-bound artifacts. Verification was extended to lock the new structure in place.

Follow-up patch closed a regression where `./tests/smoke.sh schema` and `./scripts/test-schema.sh` failed in standalone mode because `run_schema()` required pre-existing `memory/journal/*.jsonl` data.

## Required Fields

- `from`
- `to`
- `scope`
- `files`
- `decisions`
- `risks`
- `next_checks`

## Acceptance

- `scripts/sprint-init.sh` now reads `.codex/templates/SPRINT-CONTRACT.md`, `HANDOFF-LEAD.md`, `EXPLORATION-LOG.md`, and `OPENSPEC-PROPOSAL.md` to determine the generated document structure.
- Generated bootstrap docs include the previously missing sections such as `Required Fields`, `Acceptance`, `Verification`, and `Open Questions`.
- Smoke tests now fail if placeholder text like `sprint-000`, `subsystem-or-slice`, or `TBD` leaks into initialized artifacts.
- Linked worktree executions can now call `state-read.sh`, `state-update.sh`, `git-commit-task.sh`, `worktree-status.sh`, `runtime-report.sh`, and `verify-loop.sh` without manually overriding `REPO_ROOT`.
- Repository docs now include a persistent three-agent operating model (`Supervisor` / `Executor` / `Skeptic`) with explicit rule: supervisor count is `>= 1`, and can scale out based on risk/concurrency.
- Task state and context packets now surface role-governance fields: `team.supervisors`, `team.executors`, `team.skeptics`, `team.scale_out_recommended`, and `team.scale_out_triggers`.
- The repository can now turn `state.team` into runnable assignment output instead of stopping at metadata: `dispatch-create.sh` returns role packets for `Supervisor`, `Executor`, and `Skeptic`, and it creates or confirms executor worktrees automatically.
- `state/context/dispatch` now also surface whether the `Skeptic` is actually independent (`independent_skeptic`) or only a degraded fallback (`role_conflicts`, `role_integrity.degraded`).
- Python-backed harness helpers no longer leave `__pycache__` behind in execution worktrees, so the `execution commit -> clean worktree` path remains valid after role-governance scripts run.
- DD Hermes now has explicit coordination endpoint/schema docs and an execution closeout template that is materialized during sprint bootstrap instead of staying as a documentation TODO.
- Schema validation now has a dedicated checker (`check-artifact-schemas.sh`) and smoke enforces contract/handoff/state/closeout required fields end-to-end.
- DD Hermes endpoint contract now also has a unified executable入口 (`scripts/coordination-endpoint.sh`) so orchestration can call one surface instead of manually fan-out scripts.

## Verification

- `bash -n scripts/sprint-init.sh` -> pass
- `./scripts/test-workflow.sh --task-id dd-hermes-execution-bootstrap` -> pass
- `./tests/smoke.sh workflow` -> pass
- `./tests/smoke.sh context` -> pass
- `./tests/smoke.sh git` -> pass
- `./tests/smoke.sh schema` -> pass
- `./scripts/test-schema.sh` -> pass
- `./tests/smoke.sh all` -> pass
- `bash -n scripts/dispatch-create.sh scripts/worktree-create.sh scripts/worktree-remove.sh tests/smoke.sh` -> pass
- `./tests/smoke.sh workflow` -> pass
- `./scripts/dispatch-create.sh --task-id dd-hermes-execution-bootstrap` -> pass (`3` assignments: `1` supervisor, `1` executor, `1` skeptic)
- `bash -n scripts/common.sh scripts/state-init.sh scripts/state-update.sh scripts/state-read.sh scripts/context-build.sh scripts/dispatch-create.sh tests/smoke.sh` -> pass
- `./tests/smoke.sh dispatch` -> pass
- `./scripts/state-init.sh --task-id dd-hermes-execution-bootstrap` -> pass
- `./scripts/context-build.sh --task-id dd-hermes-execution-bootstrap --agent-role commander` -> pass
- `./scripts/dispatch-create.sh --task-id dd-hermes-execution-bootstrap` -> pass (`independent_skeptic=false`, `role_conflicts=["supervisor_skeptic_overlap:lead"]`)
- `./scripts/spec-first.sh --changed-files docs/coordination-endpoints.md,docs/artifact-schemas.md,.codex/templates/EXECUTION-CLOSEOUT.md,scripts/sprint-init.sh,scripts/check-artifact-schemas.sh,scripts/test-artifact-schemas.sh,tests/smoke.sh,README.md --spec-path openspec/proposals/dd-hermes-endpoint-schema-v1.md --task-id dd-hermes-endpoint-schema-v1` -> pass
- `bash -n scripts/sprint-init.sh scripts/check-artifact-schemas.sh scripts/test-artifact-schemas.sh tests/smoke.sh` -> pass
- `./scripts/test-artifact-schemas.sh` -> pass
- `./scripts/spec-first.sh --changed-files scripts/coordination-endpoint.sh,tests/smoke.sh,scripts/test-coordination-endpoint.sh,docs/coordination-endpoints.md,README.md --spec-path openspec/proposals/dd-hermes-endpoint-router-v1.md --task-id dd-hermes-endpoint-router-v1` -> pass
- `bash -n scripts/coordination-endpoint.sh scripts/test-coordination-endpoint.sh tests/smoke.sh` -> pass
- `./tests/smoke.sh endpoint` -> pass
- `./scripts/test-coordination-endpoint.sh` -> pass
- execution commits on branch `dd-hermes-execution-bootstrap-expert-a`:
  - `cb232e6` (`task(dd-hermes-execution-bootstrap): align sprint bootstrap with templates`)
  - `9d23c0c` (`task(dd-hermes-execution-bootstrap): stabilize schema smoke checks`)
  - `4ec0d01` (`docs(dd-hermes-execution-bootstrap): define long-term three-agent division`)
  - `27bb1bb` (`feat(dd-hermes-execution-bootstrap): operationalize long-term role governance`)
  - `034d6ce` (`feat(dd-hermes-multi-agent-dispatch): materialize role assignments`)
  - `740acba` (`feat(dd-hermes-role-integrity): expose skeptic independence truth`)
  - `ef8d12b` (`feat(dd-hermes-endpoint-schema-v1): add closeout schema and endpoint contracts`)
  - `4ea93ab` (`feat(dd-hermes-endpoint-router-v1): add unified coordination endpoint router`)

## Open Questions

- Current archived task now truthfully reports itself as degraded: `lead` still occupies both `Supervisor` and `Skeptic`, so the next proof point should be a follow-up task with a real independent skeptic assignee rather than more metadata tweaks on this archived task.
