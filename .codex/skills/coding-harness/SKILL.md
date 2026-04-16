# coding-harness

## Purpose

把 Lead/Expert 模式和 git worktree 隔离标准化，保证并行实现时不互相踩文件。

## When To Use

- 需要并行执行多个实现子任务。
- 需要明确 handoff、验收和风险归属。

## Inputs

- task id
- owner
- expert list
- contract / handoff paths

## Workflow

1. Lead 生成 Sprint Contract。
2. 为每个 Expert 创建 worktree。
3. Lead 发出 HANDOFF-LEAD。
4. Expert 在独立 worktree 实现并回传 HANDOFF-EXPERT。
5. Lead 验收并决定记忆升降级与归档。

## Outputs

- contract
- worktree paths
- handoffs
- status summary

## Stop Conditions

- worktree 未绑定 contract 或 handoff

## Example

`scripts/sprint-init.sh --task-id sprint-001 --owner lead --experts expert-a,expert-b,expert-c`

