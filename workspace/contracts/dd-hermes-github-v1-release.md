---
id: dd-hermes-github-v1-release
size: S2
reason_not_lower: 需要跨多个公开入口与发布工件整理，并做最小验证，属于标准跨文件发布任务。
status: active
target_repo: self
execution_host: dd-hermes
target_repo_ref: 0e42f814a413233d0ad5de387bbbdd1488627b7f
cross_repo_boundary:
  allowed_inbound:
    - smoke test exit code
    - file presence
    - script verification summary
  disallowed_inbound:
    - none
product_goal: 将当前 DD Hermes 仓整理为一份可直接发布到 GitHub 的 V1 版本，提供清晰定位、最小上手路径、发布说明与基础开源仓信息。
user_value: 外部读者进入仓库后能快速理解 DD Hermes 是什么、怎么跑、看哪里、如何验证仓库是否健康。
non_goals:
  - 不重写 DD Hermes 核心协议
  - 不清理用户已有的 V2 草稿或历史任务档案
  - 不把内部运行态真相硬编码进稳定 landing 文档
drift_risk: 容易把任务扩展成方法论重构或大规模历史归档，不做这类结构性扩写。
acceptance:
  - README 具备公开发布所需的定位、能力、目录、快速开始与验证路径
  - 补齐至少一份面向 GitHub 的发布说明文档
  - 补齐基础开源仓必要元信息（MIT LICENSE 与 CONTRIBUTING）
  - 产出可直接用于首个 GitHub Release 的提交说明与多语言发布文案
  - 最小验证命令可运行且结果已记录
---

## Intent

把当前仓库整理成适合公开发布的 DD Hermes V1，不改动用户正在进行的 V2 草稿与既有任务状态。

## Action Plan

1. 审核当前公开入口和最小可运行路径。
2. 梳理 GitHub 发布需要的稳定说明文档与仓库元信息。
3. 增补 V1 发布工件并尽量避免覆盖 README 现有内容。
4. 运行最小验证，确保入口与 smoke 路径可用。
5. 记录结果与后续可选动作。

## Verification

- `bash tests/smoke.sh schema`
- `./scripts/demo-entry.sh`
