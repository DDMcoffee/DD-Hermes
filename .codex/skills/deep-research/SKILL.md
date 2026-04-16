# deep-research

## Purpose

用 Lead 规划、子 agent 并行调查、Evaluator 复核的方式做多阶段调研。

## When To Use

- 需求存在多个事实源或设计路径。
- 需要并行收集 hooks、memory、workflow、upstream 约束。

## Inputs

- 问题定义
- 研究边界
- 预期证据格式

## Workflow

1. Lead 定义研究问题、产物格式和非目标。
2. Subagent 并行调查不同子问题。
3. Evaluator 交叉核对事实与缺口。
4. 产出 exploration logs 和 design recommendation。

## Outputs

- exploration logs
- decision summary
- unresolved gaps

## Stop Conditions

- 关键事实源无法访问且会改变设计结论

## Example

研究 Hermes 上游工作区原语与本仓库 harness 的兼容边界。

