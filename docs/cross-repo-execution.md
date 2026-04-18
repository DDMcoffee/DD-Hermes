# DD Hermes: Cross-Repo Execution

DD Hermes 指挥工件（contract / state / verdicts / closeout / memory）固定落在本仓；真实业务代码在另一个仓（"target repo"）执行。跨仓 slice 必须显式声明手柄、执行位置和证据边界。

## Why

- DD Hermes 仓只负责指挥层，不应含具体业务实现或业务敏感数据。
- 被指挥的业务仓（如 XC-BaoXiaoAuto）有自己的分支模型、CI、依赖和敏感样本，不能被 DD Hermes 的 git 历史绑架。
- 两个仓的事实源必须各自独立；DD Hermes 只记录对 target_repo 的"引用"和"verdict"，不 mirror 代码。
- PII 的原始业务数据（姓名、发票号、金额等）只能停留在 target_repo，绝不进入 DD Hermes tracked 文件。

## Roles

- DD Hermes repo
  - 产 contract / state / handoff / exploration / closeout / verdicts / memory。
  - 运行 `hooks/quality-gate.sh` 等 gate 脚本。
  - 记录对 target_repo 的引用（commit SHA、path 占位符）。
  - 不直接 commit / push target_repo。
- Target repo
  - 实际业务代码落地仓（例如 `/Volumes/Coding/XC-BaoXiaoAuto`）。
  - 自己管理 baseline commit、worktree、分支、push。
  - 自己运行真实 test / build / lint。
  - 提供 evidence 摘要回 DD Hermes（经 redaction）。

## Required Contract Fields

每个 `target_repo != self` 的 S1/S2/S3 contract 必须声明：

- `target_repo`
  - 目标仓绝对路径或规范化名称。例：`/Volumes/Coding/XC-BaoXiaoAuto`。
  - `self` 表示 DD Hermes 自身 harness 任务，触发 `AGENTS.md` 的 `Self-Reference Ops` 规则。
- `execution_host`
  - `target-repo`：所有命令在 target_repo 里执行（最常见）。
  - `dd-hermes`：仅限只读 target_repo / 构造 instruction / 不写 target_repo。
  - `both`：两边都有动作，必须在 contract 的 `action_plan` 里分开写，不能混。
- `target_repo_ref`
  - target_repo 是 git repo 则记 commit SHA 或 tag，用于追溯。
  - 不是 git repo 则为 `not-applicable`。
- `cross_repo_boundary`
  - 显式声明哪些 evidence 允许回流，哪些不允许（见 Redaction Rules）。

## Data Flow

```
DD Hermes repo                          Target repo
──────────────                          ───────────
contract ─┐                             ┌─ code changes
state     ├─ instruction ──────────────▶│  tests run
handoff  ─┘                             │  build / lint
          ┌──── evidence summary ──────┬┘ (test exit, sample count,
          │     (redacted)             │  coverage %, commit SHA)
verdicts ◀┘                            │
closeout                               └─ commit / push (target-side)
memory ◀── cross-session knowledge ────
```

- DD Hermes 侧 instruction 用 **占位路径**（`$XC_INPUT_ROOT/<employee_dir>/`）而非真实路径。
- Target repo 侧产生的原始 evidence（含 PII 可能）留在本地。
- 只有 redacted summary 才允许跨边界进入 DD Hermes tracked 文件。

## Redaction Rules

回流 evidence 不得携带：

- 真实姓名（员工、客户、联系人）
- 金额（报销金额、发票金额）
- 发票号 / 订单号 / 流水号
- 手机号 / 邮箱 / 身份证号
- 完整日期（`2026-04-18` 需要模糊到 `2026-04`）
- 完整目录名（如 `input/input-<real_name>/` 必须写为 `input/input-<employee_dir>/`）

允许回流的汇总字段：

- test exit code / pass / fail 次数
- coverage 百分比 / uncovered file 列表（路径 OK，内容不 OK）
- sample count / processed count
- commit SHA（target_repo 的引用）
- lint error 计数（不含错误正文）

## Typical Flow

以 `xc-baoxiao-web-gate-green-v1` slice 为例：

1. DD Hermes 立 contract：`target_repo=/Volumes/Coding/XC-BaoXiaoAuto`、`execution_host=target-repo`、`target_repo_ref=<current-HEAD>`、`cross_repo_boundary` 列明只收 `npm typecheck / test / build` 的 exit code。
2. DD Hermes 生成 instruction 写进 handoff，包含具体要改哪些文件的相对路径（相对于 target_repo）。
3. 用户在 target_repo 里开 worktree / 跑命令 / commit。
4. 用户把 evidence 摘要（三条命令的 exit code + 产物路径占位）贴回 DD Hermes state。
5. DD Hermes 侧 `quality-gate.sh` 消费 state 里的 `verified_steps / last_test_exit_code`，产 verdict。
6. DD Hermes 侧 closeout、archive、memory 沉淀。

## Invariants

- `target_repo != self` 的 slice，DD Hermes 侧 `workspace/state/<task_id>/state.json` 不含 target_repo 的原始数据样本；只含 SHA / 摘要。
- `hooks/quality-gate.sh` 的 `changed_code_files` 字段在跨仓 slice 中指向 target_repo 下的相对路径，不指向 DD Hermes 本仓。
- DD Hermes 的 git history 里搜不到真实姓名 / 金额 / 发票号。
- target_repo 的 `.gitignore` 保护的路径（如 `XC-BaoXiaoAuto/input/`）下的文件内容，绝不被 DD Hermes 读取并落盘。

## Anti-patterns

- 把 target_repo 作为 DD Hermes 的 submodule 或 mirror（破坏边界）。
- 把真实姓名 / 金额写进 DD Hermes contract / state / handoff（违反 redaction）。
- DD Hermes 自己 `git push` target_repo（越界）。
- target_repo 侧写完代码但 DD Hermes 侧 state 里没有 commit SHA（追溯断链）。
- `execution_host=both` 但 contract 的 `action_plan` 里两边动作混写（责任不清）。

## Related

- `AGENTS.md` 的 `Cross-Repo Execution` 段与 `Git Rules` 扩展项
- `memory/world/xc-baoxiao-sample-data-location.md`（样本位置与处理约束）
- `memory/user/user-pref-xc-baoxiao-integrations-placeholder.md`（集成占位偏好）
- `hooks/quality-gate.sh`（evidence 消费端）
