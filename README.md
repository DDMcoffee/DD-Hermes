# DD Hermes

DD Hermes 是一个面向 Codex IDE 的 workspace-first 工程 harness。它不是新的 agent runtime、聊天产品或调度器；它做的事，是把复杂 agent 工作压成可读、可执行、可验收的仓库内控制面。

## 它解决什么问题

没有 DD Hermes 时，复杂任务很容易退化成下面几种状态：

- 任务边界只存在聊天里，几轮之后就漂
- 执行和验收脱节，代码写了但没人知道是否真的完成
- `memory`、`state`、`runtime`、`handoff` 混成一层，恢复时只能靠回忆
- target repo 已经动了，但控制面、closeout、归档没有跟上

DD Hermes 用显式工件把这些问题拆开：

- `contract`
- `state`
- `context`
- `handoff`
- `worktree`
- `verification`
- `closeout`

## 它不是什么

明确不是：

- 新的 Hermes runtime
- 新的 provider / gateway / plugin loader
- 用聊天总结替代工程控制面的文档系统
- 一个要求用户手工管理多个聊天线程的外壳

## 典型工作方式

### 对外一个线程，对内多角色

对用户和项目负责人，默认只暴露一个主线程。

对内可以切换 `Lead / Explorer / Executor / Skeptic / Product Anchor / Quality Anchor`，也可以使用隔离 worktree 和 handoff，但这些复杂度应该留在协议层，不应该变成用户的线程负担。

### 大多数真实代码不在本仓

DD Hermes 常见的运行形态是跨仓：

- DD Hermes 仓
  - 负责 `contract / state / context / handoff / closeout / memory`
- target repo
  - 负责真实业务代码、测试、构建和集成

也就是说，本仓是控制面，不是业务实现主仓。

### 真相先看运行态入口

仓库 landing 文档不直接承诺“当前主线是谁”或“最新 proof 是什么”。

这些运行态真相统一从 `./scripts/demo-entry.sh` 开始看，再转到：

1. `指挥文档/06-一期PhaseDone审计.md`
2. `指挥文档/04-任务重校准与线程策略.md`

## 最短操作路径

### 1. 只想判断现在是什么状态

先运行：

```bash
./scripts/demo-entry.sh
```

然后读：

1. `指挥文档/06-一期PhaseDone审计.md`
2. `指挥文档/04-任务重校准与线程策略.md`

这一步只回答三件事：

- 现在能不能用
- 当前有没有 active mainline
- 最近一次真实 proof 证明了什么

### 2. 继续当前主线

如果 `demo-entry.sh` 显示存在 active mainline，最小读取集合是：

1. `workspace/contracts/<task_id>.md`
2. `workspace/state/<task_id>/state.json`
3. `workspace/handoffs/<task_id>-lead-to-<expert>.md`
4. 如果已有执行结果，再读对应 `workspace/closeouts/`

常用命令：

```bash
./scripts/state-read.sh --task-id <task_id>
./scripts/context-build.sh --task-id <task_id> --agent-role commander
./hooks/quality-gate.sh --event Stop --state workspace/state/<task_id>/state.json
```

### 3. 起一条新的 bounded slice

如果当前没有 active mainline，不要直接凭聊天记忆或 residue 立新任务。

先回到：

1. `指挥文档/04-任务重校准与线程策略.md`
2. 最近 proof 的 `openspec/archive/*.md`

只有在 repo evidence 明确支持下一条窄主线时，才进入：

- 新 contract
- 新 state
- 新 handoff
- 新 context
- target repo worktree

### 4. 收口与归档

“代码写完”不等于“任务完成”。

最小收口动作是：

1. fresh verification
2. closeout
3. state writeback
4. `quality-gate`
5. archive / integration 决策

## 当前最常用的文件

- [指挥文档/03-产品介绍与使用说明.md](/Volumes/Coding/Hermes%20agent%20for%20mine/%E6%8C%87%E6%8C%A5%E6%96%87%E6%A1%A3/03-%E4%BA%A7%E5%93%81%E4%BB%8B%E7%BB%8D%E4%B8%8E%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E.md)
  - 产品定位和操作手册
- [指挥文档/04-任务重校准与线程策略.md](/Volumes/Coding/Hermes%20agent%20for%20mine/%E6%8C%87%E6%8C%A5%E6%96%87%E6%A1%A3/04-%E4%BB%BB%E5%8A%A1%E9%87%8D%E6%A0%A1%E5%87%86%E4%B8%8E%E7%BA%BF%E7%A8%8B%E7%AD%96%E7%95%A5.md)
  - 当前主线或下一决策面
- [指挥文档/06-一期PhaseDone审计.md](/Volumes/Coding/Hermes%20agent%20for%20mine/%E6%8C%87%E6%8C%A5%E6%96%87%E6%A1%A3/06-%E4%B8%80%E6%9C%9FPhaseDone%E5%AE%A1%E8%AE%A1.md)
  - 当前阶段能不能直接使用
- [docs/context-runtime-state-memory.md](/Volumes/Coding/Hermes%20agent%20for%20mine/docs/context-runtime-state-memory.md)
  - 四层模型和最小读取集合
- [docs/coordination-endpoints.md](/Volumes/Coding/Hermes%20agent%20for%20mine/docs/coordination-endpoints.md)
  - 协调端点与控制面协议

## 最常用命令

```bash
./scripts/demo-entry.sh
./scripts/state-read.sh --task-id <task_id>
./scripts/context-build.sh --task-id <task_id> --agent-role commander
./scripts/dispatch-create.sh --task-id <task_id>
./scripts/check-artifact-schemas.sh --task-id <task_id>
./hooks/quality-gate.sh --event Stop --state workspace/state/<task_id>/state.json
bash tests/smoke.sh schema
```

## 文档分层

- `README.md`
  - 稳定入口，不承载当前任务状态
- `指挥文档/`
  - 给主线程和项目负责人看的中文入口
- `docs/`
  - 长期稳定协议
- `workspace/` + `openspec/`
  - 任务级真相源
- `memory/`
  - 跨会话长期知识

## 一个简单判断标准

如果你不看聊天历史，也能回答下面这些问题，说明 DD Hermes 处在正确形态：

- 当前有没有 active mainline
- 这条任务的边界是什么
- 现在谁在负责
- 最近 proof 证明了什么
- 这条 execution slice 有没有真的完成

如果这些问题仍然只能靠聊天回忆来答，说明控制面还没有收口好。
