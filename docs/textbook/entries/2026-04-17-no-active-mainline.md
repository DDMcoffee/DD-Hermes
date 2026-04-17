# Textbook Entry

## Date

- 2026-04-17

## Topic

- 为什么仓库可以诚实地说“当前没有 active mainline”，而不是硬造一个 successor。

## User Experience

- 今天主线程没有继续追着“下一条主线是什么”跑，而是先接受一个更真实的状态：上一条 phase-2 proof 已经 archive，下一条任务还没有被证据压胜。
- 用户的实际收益反而更高，因为入口文档、archive、`demo-entry.sh` 和当前策略页开始说同一句话，不再一个地方写“已完成”，另一个地方又像“还在执行中”。
- 这也暴露出一个常见坑：proposal-only 的 docs consolidation 和 paused 的 S5 实验，如果不处理，就会让后来的人误以为它们还是 live candidate。

## Input Links

- `指挥文档/04-任务重校准与线程策略.md`
- `指挥文档/06-一期PhaseDone审计.md`
- `openspec/archive/dd-hermes-explicit-gate-verdicts-v1.md`
- `workspace/contracts/dd-hermes-backlog-truth-hygiene-v1.md`
- `openspec/proposals/dd-hermes-backlog-truth-hygiene-v1.md`
- `scripts/demo-entry.sh`

## Conclusions

- “没有 active mainline” 不是停工，而是一种更高级的控制面诚实：只有当 `contract + state + synthesis` 真正齐备时，才配叫当前主线。
- archive 的职责是划清已经证明完的边界，而不是顺手替下一条任务拍板。
- candidate pool 里的 stale truth 要先清掉，否则 successor triage 会一直被旧提案和暂停实验污染。

## Patterns

- proof 归档后，如果证据不够，就保持空位，不要伪造连续剧情。
- 入口脚本、策略页、archive、state 必须讲同一个故事。
- `BLOCKED`、`暂无结论`、`没有 active mainline` 都是有效状态，不是失败。
- 先做 backlog truth hygiene，再做下一轮 successor selection。

## Next Lesson

- 下一课适合写《怎么给候选池做真相卫生：吸收、归档、暂停实验分别怎么写》。
