# DD Hermes Coordination Endpoints (v1)

本文档把 `指挥文档/02-三层终点定义.md` 与 `指挥文档/03-执行线程干到底说明.md` 落成可执行的 endpoint/schema 约定。

## 三层终点映射

- `execution slice done`
  - Expert 在隔离 worktree 产出 execution commit。
  - 回写 expert handoff、verification 证据和 state git 锚点。
- `task done`
  - Lead 完成 integration commit，并通过任务级验收。
  - state 切到 `done`，且可追溯到 integration 证据。
- `project phase done`
  - OpenSpec 与项目目标文档收口，阶段边界和完成标准明确。
  - 不再是“脚手架存在”，而是“阶段契约已验证”。

## Endpoint Surface

DD Hermes 当前用脚本表达 endpoint，等价于以下控制面接口。
统一入口脚本：`scripts/coordination-endpoint.sh --endpoint <name> --task-id <task_id>`。

### 1) `state.read`

- Router entry: `scripts/coordination-endpoint.sh --endpoint state.read --task-id <task_id>`
- Implementation: `scripts/state-read.sh --task-id <task_id>`
- Purpose: 读取任务控制面与派生摘要。
- Response required fields:
  - `state`
  - `summary`
  - `summary.verification_complete`
  - `summary.has_context`
  - `summary.has_runtime_report`
  - `summary.has_supervisor`
  - `summary.independent_skeptic`
  - `summary.role_conflicts`

### 2) `state.update`

- Router entry: `scripts/coordination-endpoint.sh --endpoint state.update --task-id <task_id> < payload.json`
- Implementation: `scripts/state-update.sh --task-id <task_id> < payload.json`
- Purpose: 更新控制面并写入 `events.jsonl`。
- Request common fields:
  - `status`, `mode`, `current_focus`, `active_expert`
  - `append_verified_steps`, `append_verified_files`, `last_pass`
  - `commit_sha`, `commit_branch`, `context_path`, `runtime_report_path`
  - `supervisors`, `executors`, `skeptics`

### 3) `context.build`

- Router entry: `scripts/coordination-endpoint.sh --endpoint context.build --task-id <task_id> --agent-role <role>`
- Implementation: `scripts/context-build.sh --task-id <task_id> --agent-role <role>`
- Purpose: 组装执行输入包。
- Response required fields:
  - `context_path`
  - `runtime_path`
  - `state_path`
  - `memory_count`

### 4) `dispatch.create`

- Router entry: `scripts/coordination-endpoint.sh --endpoint dispatch.create --task-id <task_id>`
- Implementation: `scripts/dispatch-create.sh --task-id <task_id>`
- Purpose: 从 `state.team` 物化 supervisor/executor/skeptic assignment。
- Response required fields:
  - `task_id`, `state_path`, `context_path`, `runtime_path`
  - `independent_skeptic`, `degraded`, `role_conflicts`
  - `summary.supervisor_count`, `summary.executor_count`, `summary.skeptic_count`
  - `assignments`

### 5) `closeout.check`

- Router entry: `scripts/coordination-endpoint.sh --endpoint closeout.check --task-id <task_id>`
- Implementation: `scripts/check-artifact-schemas.sh --task-id <task_id>`
- Purpose: 校验 `contract/handoff/state/closeout` 必填字段是否完整。
- Response required fields:
  - `task_id`
  - `checked`
  - `artifacts`
  - `errors`
  - `valid`

## Closeout Flow

1. `scripts/sprint-init.sh` 初始化 sprint 时，自动生成 `workspace/closeouts/<task_id>-<expert>.md`。
2. Expert 在 execution slice 收尾时补充 closeout 内容、提交 execution commit。
3. `scripts/check-artifact-schemas.sh` 与 `tests/smoke.sh schema` 负责字段级护栏。

## Gate Rules

- 若 `summary.independent_skeptic == false`，不得宣称“独立质疑位已覆盖”，应标注为 degraded。
- 若 closeout 缺少 required fields，不得判定 `execution slice done`。
- 若 state 未写入 commit 锚点和 verification 证据，不得判定 `task done`。
