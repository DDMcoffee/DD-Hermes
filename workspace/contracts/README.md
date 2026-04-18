# workspace/contracts/

活跃 contract 的落盘目录。此目录只含：

- 当前活跃 mainline 对应的 contract（每个 active task_id 一份）
- `_archive/`：已归档完成的 contract
- `_template.md`：新建 contract 的模板

## 当前状态

截至 2026-04-18 DD Hermes M3/M4 重校准：

- 无 active mainline
- 18 份历史 harness contract 已移至 `_archive/`（参见 commit `3be33fa`）
- `_template.md` 含跨仓 slice 字段骨架（M4c 引入）

## 新建 contract 流程

1. 复制 `_template.md` 为 `<task-id>.md`
2. 按 `AGENTS.md` 的 `Task Size Gradation` 声明 `size`
3. 若 `target_repo != self`，按 `AGENTS.md` 的 `Cross-Repo Execution` 段填 `target_repo / execution_host / cross_repo_boundary / target_repo_ref`
4. 按 `schema_version: 2` 对应的字段顺序填写
5. 填完后用 `scripts/check-artifact-schemas.sh --task-id <task-id>` 校验

## Size 快速参照

- **S0 chore**：无需 contract，只需 state.json + commit。
- **S1 slice**：极简 contract（`id / size / intent / acceptance`）即可。
- **S2 task**：完整 contract（当前 `_template.md` 覆盖场景）。
- **S3 phase**：S2 全套 + 3-explorer-then-execute 证据链。

## 跨仓 slice 附加规则

若 `target_repo` 不是 `self`，必须：

- 显式声明 `cross_repo_boundary`，列明哪些 evidence 可以回流 DD Hermes
- 原始业务数据（含 PII）不进任何 DD Hermes tracked 文件
- 真实姓名、金额、发票号、完整日期需 redaction

详见 `docs/cross-repo-execution.md`。

## 自指规则

若 contract 主题是 DD Hermes 自身 harness 能力（runtime / router / dispatch / memory runtime / 新脚本 / 新协议 / 新 schema），必须附 `provable_need` 字段；否则按 `Self-Reference Ops` 自动降级 `deferred`，不得进 mainline。
