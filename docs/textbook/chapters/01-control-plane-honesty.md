# Textbook Chapter

## Chapter Goal

- 教清楚 DD Hermes 为什么要把关键判断写进可恢复的控制面真相里，以及为什么“当前没有 active mainline”可以是正确结论。

## Core Idea

- 仓库的控制面不能靠聊天记忆或临时推导维持一致。真正稳定的系统，要把“现在卡在哪、为什么卡、能不能继续、是不是已经收口”写成可审计事实。
- 这意味着两件事必须同时成立：
- 第一，gate verdict 要落进 `state.verdicts`，并被 `state.read`、`context.build`、`quality-gate`、schema check 复用。
- 第二，当下一条主线还没被证据压胜时，入口必须诚实地说“没有 active mainline”，而不是拿旧 proposal 或暂停实验充数。

## Examples

- `dd-hermes-explicit-gate-verdicts-v1` 把 `product_gate`、`quality_review`、`degraded_ack`、`quality_seat`、`execution_closeout` 压成共享 truth surface，维护者不再需要从多个脚本和聊天片段重新拼结论。
- `workspace/closeouts/dd-hermes-explicit-gate-verdicts-v1-expert-a.md` 证明了“完成态”不只是模板存在，而是 execution commit、quality review、schema/gate/smoke 验证和 archive 证据对齐。
- `指挥文档/04-任务重校准与线程策略.md` 和 `scripts/demo-entry.sh` 一起把 repo 停在真实位置：最新 proof 已归档，但 successor 还没有被证据明确压出来，所以当前 active mainline 为空。
- `dd-hermes-backlog-truth-hygiene-v1` 说明空位并不等于停工；它表示下一步先清理 stale candidate truth，再做下一轮裁决。

## Common Mistakes

- 把 gate 判断留在瞬时脚本逻辑里，导致 handoff、resume、archive 时每个人都要重新猜一遍。
- 看到 proof 刚归档，就急着立一条 successor，结果把 proposal-only 文档或 paused experiment 写成既成事实。
- 把 “有 closeout 文件” 错当成 “可以宣称 execution slice done”，忽略质量复核、验证覆盖和 archive 对齐。
- 让入口页、state、archive、策略页分别讲不同故事，最后维护者不知道该信哪一处。

## Rules

- 关键 gate 一律落盘；不要把共享真相藏在瞬时逻辑里。
- verdict 不只要有状态，还要有原因、更新时间和语义边界。
- `execution_closeout` 必须作为独立完成态 truth，对齐 closeout、quality review 和 archive。
- 没有被 `contract + state + synthesis` 压胜的新任务，就不要宣称存在 active mainline。
- `BLOCKED`、`暂无结论`、`没有 active mainline` 都是合法控制面状态。
- 先做 backlog truth hygiene，再做 successor selection。

## Next Chapter

- 下一章写《怎样识别真实 closeout：模板占位、验证通过、归档完成分别有什么不同》。
