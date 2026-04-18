# DD Hermes 指挥文档

这个目录只保留给当前主线程和项目负责人阅读的中文入口文档。

硬规则：

- 这里的 Markdown 文件数长期不得超过 `8`。
- 新判断优先并入现有页面，不再为同一主题额外开新页。

## 当前文件

- `01-项目目标对齐.md`
  - 项目级北极星、边界和文档分层，不讲当前任务细节。
- `02-三层终点定义.md`
  - execution slice、task、phase 三层完成定义。
- `03-产品介绍与使用说明.md`
  - 产品定位和操作手册；回答“DD Hermes 是什么、对外暴露什么表面、第一次或回流时最短怎么操作”。
- `04-任务重校准与线程策略.md`
  - 当前主线或下一决策面、当前下一步、线程裁决和继续开发起点。
- `06-一期PhaseDone审计.md`
  - 回答“现在能不能用 DD Hermes、一期完成到了哪里、phase-2 当前处于什么位置”。
- `08-恒定锚点策略.md`
  - 定义 `Product Anchor` / `Quality Anchor` 的长期协议地位，也是对抗式思辨的制度入口。
- `09-今日输入整理.md`
  - 用户输入归纳；回答“这个项目为什么这样设计、你强调过哪些不可漂移的要求”，不是当前主线状态页。

## 建议阅读顺序

### 第一次接手这个仓库

1. 先读 `01-项目目标对齐.md`
2. 再读 `03-产品介绍与使用说明.md`
3. 再读 `09-今日输入整理.md`
4. 需要看控制面边界时，再读 `docs/context-runtime-state-memory.md`
5. 最后再看 `08-恒定锚点策略.md`

### 判断当前运行态

1. 运行 `./scripts/demo-entry.sh`
2. 读 `06-一期PhaseDone审计.md`
3. 读 `04-任务重校准与线程策略.md`
4. 如果是架构、控制面或高风险任务，再回到 `3-explorer-then-execute`

### 进入执行

1. 读 `02-三层终点定义.md`
2. 如果当前存在 active mainline，再读对应 `workspace/contracts/<task_id>.md`
3. 如果当前存在 active mainline，再读 `workspace/state/<task_id>/state.json`
4. 如果当前没有 active mainline，就先读最近 proof 的 archive，再决定下一条窄主线
5. 有 execution slice 时，再读对应 `workspace/handoffs/` 与 `workspace/closeouts/`
