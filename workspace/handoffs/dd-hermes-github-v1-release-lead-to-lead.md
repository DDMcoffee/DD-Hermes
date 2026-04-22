# Handoff: dd-hermes-github-v1-release lead -> lead

## Scope

- 整理一版适合公开发布到 GitHub 的 DD Hermes V1。
- 补齐 README / CONTRIBUTING / RELEASE 说明。
- 根据用户确认补充 MIT LICENSE 与首个 GitHub Release 多语言发布文案。
- 不触碰用户现有 V2 草稿删除/改写轨迹。

## Decided

- 任务按 S2 执行。
- `target_repo=self`，只在本仓完成。
- 以稳定入口为先，不把运行态真相硬编码进 README。
- 许可证采用 `MIT`。
- 首个 GitHub Release 默认版本号采用 `v1.0.0`。

## Risks

- README 当前已有未提交改动，修改时需避免冲掉用户整理中的版本。
- 仓库中文内容较多，GitHub 公开读者需要额外的英文优先发布文案来降低理解门槛。

## Next Checks

- 补齐 LICENSE 与发布文案文件。
- 更新已有发布说明中的许可证状态。
- 跑最小验证并回写 closeout/state。
