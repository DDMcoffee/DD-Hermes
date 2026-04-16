# DD Hermes: 长期三 Agent 分工（含监督扩容）

## 哲学立场

- 可错主义：默认“当前结论可能错”，所以必须保留反证位。
- 对抗式求真：实现与质疑分离，避免“自己写自己验”。
- 责任分层：监督负责边界与裁决，执行负责产出，质疑负责拆穿漏洞。

## 三个长期职能

这不是“固定三个人”，而是固定三类长期责任位。

| 职能位 | 最小人数 | 核心问题 | 主要产物 |
| --- | --- | --- | --- |
| 监督位 `Supervisor` | 至少 1 | 现在该做什么、算不算完成 | state 推进、验收裁决、风险升级 |
| 执行位 `Executor` | 至少 1 | 怎么把目标做出来 | execution commit、expert handoff、验证证据 |
| 质疑位 `Skeptic` | 至少 1 | 这个方案在哪些条件下会失败 | 反例、回归补充、验收挑战清单 |

## 各职能边界

### 1. 监督位 `Supervisor`（必须有，默认 1）

- 负责维护 `contract + state + context + acceptance`。
- 唯一拥有“完成态裁决权”（`execution slice done` / `task done` / `phase done`）。
- 必须要求每轮都有可审计证据，而不是口头结论。
- 默认配置：`1` 位监督。

### 2. 执行位 `Executor`

- 只在隔离 worktree 内实现，形成 execution commit。
- 负责把验证结果回写到 `workspace/state/<task_id>/state.json` 与 handoff。
- 对“实现正确性”负责，不对“验收边界定义”做最终裁决。

### 3. 质疑位 `Skeptic`

- 对执行结果做反证，不参与主实现，避免角色污染。
- 重点查三类问题：边界条件、回归风险、证据缺口。
- 输出必须是可执行检查项（命令、断言、失败样例），不能只给观点。

## 监督扩容规则（你要求的“可根据情况多加”）

默认至少 1 个监督位；满足任一条件时增加监督位：

1. 并行 execution slice `>= 2`。
2. 连续两轮验证失败或出现重复回归。
3. 任务进入高风险域（权限、安全、策略边界、数据破坏风险）。
4. Lead 同时承担实现与验收，出现角色冲突风险。

建议扩容模板：

- `Supervisor-Primary`：节奏与最终裁决。
- `Supervisor-Risk`：风险与策略边界审查（按需启用）。
- `Supervisor-Integration`：多切片集成与任务级验收（按需启用）。

## 策略矩阵

### 1. 单线程

- 适用任务：治理、裁决、收口、归档、状态回填、只读审计、文档修订、trace 整理。
- 进入条件：不产生新的 execution slice，不需要隔离 worktree，不需要独立实现或独立验证。
- 禁止伪装：如果任务已经需要可审计的实现证据，就不得继续伪装成单线程治理任务。

### 2. `Lead + Executor`

- 适用任务：局部脚本、模板、小型补丁、单点修复、单一文档链路修正。
- 进入条件：只有一个主要写集、验收明确、可本地验证、没有高风险域、没有角色冲突。
- 升级条件：若出现权限/安全边界、重复回归、集成压力、`independent_skeptic=false` 或 `scale_out_recommended=true`，就要升级。

### 3. `Lead + Executor + Skeptic`

- 适用任务：架构、控制面、状态机、线程模型、git/worktree 编排、权限/安全边界、容易误判完成态的任务。
- 进入条件：`Skeptic` 必须是独立质疑位；若无法独立，则 `dispatch/state/context` 必须显式标记 `degraded` 与 `role_conflicts`。
- 输出要求：必须同时看到“实现证据 + 反证证据 + 裁决记录”。

### 4. `Lead + Executor A + Executor B + Skeptic`

- 适用任务：公共 API / schema / protocol、并发或状态机、跨切片集成、上线前关键路径，或任何需要两条独立证据链的任务。
- 进入条件：任务本身值得用双实现降低风险，且两个执行路径不能退化成“同一实现换个说法”。
- 裁决方式：Lead 负责归并，Skeptic 负责挑战，不能把双实现降格成单实现加口头复核。

## 选择顺序

1. 先判断是不是纯治理/收口任务；是则单线程。
2. 否则判断是不是只有一个边界清晰的实现切片；是则 `Lead + Executor`。
3. 只要进入高风险域、架构/策略/控制面、或存在独立质疑不足，就升级到 `Lead + Executor + Skeptic`。
4. 只要需要两条独立实现路径来证明正确性，就升级到双实现。
5. 若 `discussion.policy == 3-explorer-then-execute`，以上任一执行形态都必须先有 `synthesis_path`。

## 推进节奏（长期循环）

每个推进轮次固定 4 步：

1. `Supervisor` 定义本轮目标、完成条件、阻塞条件。
2. `Executor` 实现并提交 execution commit，回写 handoff + verification。
3. `Skeptic` 提交反证结果（失败样例或通过证据）。
4. `Supervisor` 依据证据更新 state，并决定进入下一轮或收口。

## 与当前仓库工件的映射

- `Supervisor`：`workspace/contracts/`、`workspace/state/`、`openspec/`
- `Executor`：`.worktrees/`、execution commit、`workspace/handoffs/`
- `Skeptic`：`tests/`、`scripts/verify-loop.sh`、回归挑战记录

## 派发行为

- `scripts/dispatch-create.sh` 是三职能落到运行面的入口。
- `Supervisor`
  - 不默认分配独立 worktree。
  - 消费 `contract + state + context`，输出裁决与 gating decision。
- `Executor`
  - 必须被派发为实际 assignment。
  - 默认需要隔离 worktree，并绑定对应 handoff。
- `Skeptic`
  - 默认不需要独立 worktree，但必须获得独立 assignment。
  - 其输入至少包含 `contract + state + context`，输出反证和挑战检查项。
- 默认回退策略优先选择“不参与实现的人”做 `Skeptic`；如果只能让 `Supervisor` 兼任，系统必须把它标记为降级，而不是假装独立性已经存在。
- 如果 `state.team.scale_out_recommended = true`，派发结果不应退化成单 executor 单元。
- 如果 `Skeptic` 与 `Supervisor` 或 `Executor` 重叠，`state/context/dispatch` 必须显式暴露 `role_conflicts`，并触发 `independent_skeptic_unavailable`。

## 完成定义（分工层面）

- 三个职能位都被显式指派。
- 至少 1 个监督位在线并负责裁决。
- 每轮都能看到“实现证据 + 反证证据 + 裁决记录”三件套。
- 任何角色离线时，`state.lease` 必须可恢复，而不是依赖聊天上下文记忆。
