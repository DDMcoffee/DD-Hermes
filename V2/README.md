# DD Hermes V2

V2 是 DD Hermes 在"给 Codex APP 套马具 + 沉淀用户知识/经验"这个北极星下的下一代扩展空间。它**不是** V1 的补丁，也**不替代** V1 的任何协议；V2 以独立顶层目录并行存在，V1 的所有文件（`AGENTS.md` / `README.md` / `CLAUDE.md` / `docs/` / `指挥文档/` / `hooks/` / `scripts/` / `tests/` / `workspace/` / `memory/` / `openspec/`）保持稳定不动。

## 北极星

- 为了更好地使用 Codex APP
- 给 Codex 套上**马具**（harness 的本义：缰绳 + 挽具，让强大的马匹朝用户方向稳定产出）
- 在使用过程中**沉淀用户个人的知识/经验**，形成不可复制的 Context
- 顶层语言：`Goal + Context + Constraints` 三元组（GCC）

## V2 不是什么

明确不是：

- V1 的补丁、修订版、或迁移目标
- 一个新的 Hermes runtime / provider / gateway
- 一个会把 V1 文件改写或重命名的升级
- 一个要求用户手工维护"V1 线程"和"V2 线程"的双轨系统
- 一个把 docx《Agentic 之道 V2》主张全盘吸收的空间（见 `00-哲学总纲.md` §8 "不吸收 / 谨慎借鉴"）

## V2 目录结构（当前阶段）

```
V2/
├── README.md                # 本文件，稳定入口
├── 00-哲学总纲.md            # V2 顶层语言 + GCC 翻译表 + 五条道/五步闭环落地
├── 01-方向矩阵.md            # 7 个候选支柱 + provable_need 素描 + target repo 候选池
└── (后续按需扩: skills/ / proposals/ / case-studies/)
```

编号从 `00` 开始（V1 `指挥文档/` 从 `01` 开始）是为了让物理结构一眼看出"这是新空间"，不是任何协议上的硬要求。

## 当前阶段

V2 当前只到"哲学 + 方向矩阵"阶段。

具体支柱**尚未立 slice**。也就是说：

- `workspace/contracts/v2-*.md` 目前**不存在**（立案时会按 V1 协议创建）
- `memory/skills/` 目录目前**不存在**（`v2-skill-stack` 立案时才创建）
- V2 没有任何 active mainline，与 V1 当前状态一致（V1 也无 active mainline，见 `指挥文档/06-一期PhaseDone审计.md`）

要推进 V2 第一条真实 slice：

1. 先读 `V2/00-哲学总纲.md`（理解 V2 顶层语言）
2. 再读 `V2/01-方向矩阵.md`（选一条支柱 + 引用对应的 `provable_need_sketch`）
3. 立案时按 V1 协议走 `contract + state + handoff + worktree + verification + closeout + archive`（`workspace/` 路径不变）；`V2/` 下只放 V2 自己的哲学文档与 V2 特有的新工件（例如 `V2/skills/*.md`）

## V2 继承的 V1 硬骨头（不可谈判）

- `Self-Reference Ops`：harness 自指 slice 必须附 `provable_need`
- `Cross-Repo Execution`：跨仓四字段（`target_repo` / `execution_host` / `cross_repo_boundary` / `target_repo_ref`）+ PII redaction
- `Dangerous Ops`：禁止 `rm -rf` / `git push --force` / `DROP` / `.env` 写入
- `Task Size Gradation`：S0/S1/S2/S3 `size` 硬必填
- 中文优先、工件真相源优先于聊天回忆

## 与 V1 冲突时怎么办

V2 是**平行扩展层**，不是**协议覆写层**。若 V2 文档与 V1 协议出现文字冲突，以 V1 为准。V2 哲学总纲 §7 列出了 V2 **允许重新思考**的 V1 预设（每条附反证理由，不为差异而差异），§9 列出了 V2 **必须继承**的硬骨头。

## 和 V1 入口的关系

- 判断 DD Hermes 当前能不能用 / 有没有 active mainline / 最近 proof 是什么 → 仍然走 `./scripts/demo-entry.sh` + `指挥文档/06-一期PhaseDone审计.md`（V1 入口）
- 判断 V2 的哲学和方向 → 读 `V2/00-哲学总纲.md` + `V2/01-方向矩阵.md`（V2 入口）
- 立 V2 真实 slice → V1 入口判断当前没在跑其他主线，再回到 V2 方向矩阵选支柱
