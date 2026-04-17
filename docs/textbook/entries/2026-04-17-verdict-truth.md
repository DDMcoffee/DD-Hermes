# Textbook Entry

## Date

- 2026-04-17

## Topic

- 把 gate 真相写进 `state.verdicts`，让维护者不用重新猜“现在到底卡在哪”。

## User Experience

- 用户这一天的实际体验，不再是“看完聊天再自己推理”，而是可以顺着 `state.json`、`state.read`、`context.build`、`quality-gate` 直接看到同一套 verdict。
- 主线程确认了一个很实用的变化：`execution_closeout` 也进入 verdict 层后，“模板写了”与“真的可以宣称 execution slice done”终于被分开了。
- 质量复核也不再是最后补一句“有人看过”，而是有 `quality_review_status: approved`、验证命令、closeout 语义和 archive 证据一起支撑。

## Input Links

- `workspace/contracts/dd-hermes-explicit-gate-verdicts-v1.md`
- `workspace/closeouts/dd-hermes-explicit-gate-verdicts-v1-expert-a.md`
- `openspec/archive/dd-hermes-explicit-gate-verdicts-v1.md`
- `docs/coordination-endpoints.md`
- `scripts/check-artifact-schemas.sh`
- `hooks/quality-gate.sh`

## Conclusions

- DD Hermes 已经证明：product gate、quality gate、degraded ack、quality seat、`execution_closeout` 这些关键判断，应该作为共享控制面真相持久化，而不是散落在不同脚本里临时计算。
- `execution_closeout` 是今天最关键的补课点，因为它把“完成态”也纳入了和其他 gate 一样的可恢复账本。
- 这条 proof 完成后，维护者读 repo 真相的成本明显下降：不用先翻多个聊天线程，先看 task state 和 archive 就能知道结论。

## Patterns

- 先把 verdict 落盘，再谈 resume / handoff / archive。
- gate 状态必须带原因和更新时间，不能只留 `true/false`。
- 完成态要有自己的 truth surface，不能只依赖瞬时 gate 逻辑。
- closeout、quality review、archive 必须彼此对齐，才能算“真的收口”。

## Next Lesson

- 下一课适合写《有了 verdict 还不够：怎样判断 closeout 是真实证据，不是模板占位》。
