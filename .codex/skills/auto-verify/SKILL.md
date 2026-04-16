# auto-verify

## Purpose

把技术层验证和用户层验证串成最多 5 轮的闭环，避免“改完但没验证”。

## When To Use

- 有代码、脚本或规范产物更新。
- 进入准备完成、验收或 handoff 阶段。

## Inputs

- task id
- checks
- user gate
- max rounds

## Workflow

1. 运行技术层检查。
2. 若失败，记录轮次并修复。
3. 运行用户层或场景层 gate。
4. 最多 5 轮；超限则保持 blocked。

## Outputs

- rounds used
- passed / blocked
- remaining failures

## Stop Conditions

- 超过最大轮数仍失败

## Example

`scripts/verify-loop.sh --task-id sprint-001 --max-rounds 5 --checks tests/smoke.sh`

