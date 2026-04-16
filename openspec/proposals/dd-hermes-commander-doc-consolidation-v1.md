# DD Hermes 指挥文档收口提案

## What

- 把 `指挥文档/` 从 10 份 Markdown 收口到不超过 7 份。
- 合并重复主题：
  - `03-执行线程干到底说明.md` 并入 `02-三层终点定义.md`
  - `05-体验版本路线图.md` 与 `07-体验入口任务说明.md` 并入 `06-一期PhaseDone审计.md`
- 把“现在能不能用 DD Hermes”和“恒定锚点是否被关掉”写成仓库事实，而不是留在聊天里口头解释。

## Why

- 当前 `指挥文档/` 出现了同一件事分散在多页里重复讲述的情况，导致入口不清、当前阶段判断漂移。
- 用户已经明确要求该目录长期保持在 7 份以内，并把它作为唯一中文指挥入口。
- 这轮需要把 phase-1 可用性、phase-2 主线和恒定锚点语义压成单一形状，避免再次靠聊天补解释。

## Non-goals

- 不改 DD Hermes 的 runtime、provider、gateway 或插件机制。
- 不启动新的 execution thread，也不在这轮实现 phase-2 锚点治理代码。
- 不重写历史 archive / handoff 的叙述，只修正当前有效入口。

## Acceptance

- `指挥文档/` 下 Markdown 文件数不超过 7。
- `指挥文档/README.md` 能给出单一阅读顺序。
- `指挥文档/06-一期PhaseDone审计.md` 能直接回答“现在能不能用、能用到什么程度、下一步是什么”。
- `指挥文档/08-恒定锚点策略.md` 能直接回答“恒定锚点有没有被关掉、是否存在常驻管理 agent”。
- 根 README 与体验入口指向收口后的文档结构。

## Verification

- 运行 `find '指挥文档' -maxdepth 1 -type f -name '*.md' | wc -l`
- 运行 `./scripts/demo-entry.sh`
