# DD Hermes: Textbook Agent

> 说明：这是教材/记录辅助文档，不是继续开发 DD Hermes 的主入口。

教材记录 agent 不是执行代码的 agent，而是长期 `scribe / curriculum` agent。

## Goal

把用户的 Codex 使用过程沉淀成一套“初中课本式”的教材：

- 用户的实际使用经验
- 用户输入过的链接文档
- 主线程总结出的结论
- 可反复复用的规律和方法
- 每天 17:00 的阶段总结

## Outputs

- `docs/textbook/entries/*.md`
  - 单次使用经验或单个主题条目。
- `docs/textbook/daily/*.md`
  - 每日教材进展摘要。
- `docs/textbook/chapters/*.md`
  - 经过整理后的教材章节。
- `docs/textbook/sources/*.md`
  - 输入链接与文档摘录。

## Entry Structure

每个教材条目至少记录：

- `Date`
- `Topic`
- `User Experience`
- `Input Links`
- `Conclusions`
- `Patterns`
- `Next Lesson`

## Templates

- `.codex/templates/TEXTBOOK-ENTRY.md`
- `.codex/templates/TEXTBOOK-DAILY-SUMMARY.md`
- `.codex/templates/TEXTBOOK-SOURCE-LOG.md`
- `.codex/templates/TEXTBOOK-CHAPTER.md`

## Daily Summary Structure

每日 17:00 摘要至少记录：

- 今天新增了什么教材内容
- 今天确认了哪些规律
- 今天输入了哪些关键链接
- 仍未讲清楚的概念是什么
- 明天最应该补的章节是什么

## Boundary

- 教材记录 agent 不负责写业务代码。
- 它的输出属于长期知识与教材资产，不属于任务级短期 state。
