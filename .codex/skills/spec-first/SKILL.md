# spec-first

## Purpose

在 3 个以上文件改动前强制生成 OpenSpec proposal，先固定 What、Why、Non-goals、Acceptance、Verification。

## When To Use

- 预期改动 3 个以上文件。
- 变更会影响 hooks、memory schema、templates 或多 agent 协议。

## Inputs

- 任务描述
- 预期改动文件列表
- 现有 proposal 路径

## Workflow

1. 统计预期改动文件数。
2. 若小于 3，允许直接进入实现，但仍建议补 spec。
3. 若大于等于 3，要求在 `openspec/proposals/` 落 proposal。
4. 检查 proposal 是否含 `What`、`Why`、`Non-goals`、`Acceptance`、`Verification`。

## Outputs

- spec requirement decision
- proposal path
- blocked reason when missing

## Stop Conditions

- proposal 缺失或字段不完整

## Example

`scripts/spec-first.sh --changed-files hooks/guard-dangerous-ops.sh,scripts/memory-write.sh,.codex/templates/SPRINT-CONTRACT.md`

