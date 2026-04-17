# Textbook Source Log

## Date

- 2026-04-17

## Source

- `workspace/closeouts/dd-hermes-explicit-gate-verdicts-v1-expert-a.md`
- `openspec/archive/dd-hermes-explicit-gate-verdicts-v1.md`
- `workspace/contracts/dd-hermes-quality-seat-escalation-rules-v1.md`
- `指挥文档/04-任务重校准与线程策略.md`
- `scripts/demo-entry.sh`

## Key Points

- `explicit-gate-verdicts` 这条 proof 已经不只是“代码写了”，而是有 execution commit、approved 质量复核、schema/gate/smoke 验证和 archive 收口。
- `quality-seat-escalation-rules` 把 `T0/T1/T2 => degraded-allowed`、`T3/T4 => requires-independent` 明确成控制面规则，说明质量位升级不再凭感觉决定。
- 当前策略页和入口脚本都强调同一件事：最新 proof 已经完成，当前没有 active mainline，下一步要先清 stale candidate truth。

## Reusable Lesson

- 写教材时要优先引用 archive、closeout、contract、入口脚本这类“仓库真相源”，不要只引用聊天结论。
- 一天的 lesson 可以拆成两类教材：一类讲“控制面新能力”，一类讲“主线裁决与诚实停点”。
