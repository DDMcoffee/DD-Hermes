# DD Hermes V2

V2 是 DD Hermes 在"给 Codex APP 套马具 + 沉淀用户知识/经验"这个北极星下的下一代扩展空间。它**不是** V1 的补丁，也**不替代** V1 的任何协议；V2 以独立顶层目录并行存在，V1 的所有文件（`AGENTS.md` / `README.md` / `CLAUDE.md` / `docs/` / `指挥文档/` / `hooks/` / `scripts/` / `tests/` / `workspace/` / `memory/` / `openspec/`）保持稳定不动。

## 本文件的四层来源声明（第三方审核 3.4 要求）

本文件及整个 `V2/` 目录的所有主张按下列四层来源区分：

- 🎯 **用户明确输入**：V2 是下一代大版本扩展空间 / 北极星 = 更好使用 Codex APP + 沉淀个人知识 / 不要全盘吸收 docx / 不污染 V1 / XC-Park-AI 保持候选池定位
- 📂 **仓库现有真相**：通过 `./scripts/demo-entry.sh` / `openspec/archive/` (19 条) / `memory/self/` (2 条) / `docs/textbook/daily/` (3 条) 等直接验证
- 📘 **外部参考筛选后吸收**：docx《Agentic 之道 V2》、Anthropic Skills、OpenSpec 等 —— **筛选后**引用，三层清单见 `00-哲学总纲.md §8`
- 🔀 **头脑风暴 / 多 Explorer 结果**：方向矩阵里的 7 条候选、评分、分层标签；**强度弱于前三层**，未经直接证据补齐前不升级为协议

**关键原则**：🎯 和 📂 优先于 📘，📘 优先于 🔀。

## 北极星（🎯 用户明确输入）

- 为了更好地使用 Codex APP
- 给 Codex 套上**马具**（harness 的本义：缰绳 + 挽具，让强大的马匹朝用户方向稳定产出）
- 在使用过程中**沉淀用户个人的知识/经验**，形成不可复制的 Context
- 对外沟通的**映射语言**（非主骨架）：`Goal + Context + Constraints` 三元组（GCC）；主骨架仍是 V1 工件八件套（见 `00-哲学总纲.md §1.1`）

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
└── (后续按需扩: proposals/ / case-studies/ 等 V2 特有的分析文档)
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
3. 立案时按 V1 协议走 `contract + state + handoff + worktree + verification + closeout + archive`（`workspace/` 路径不变）；skill 文件（若将来引入）统一落在 `memory/skills/`（V1 memory 子目录），`V2/` 下只放 V2 自己的哲学/方向/分析文档，不建 `V2/skills/` 等工件目录

## V2 继承的 V1 硬骨头（不可谈判）

- `Self-Reference Ops`：harness 自指 slice 必须附 `provable_need`
- `Cross-Repo Execution`：跨仓四字段（`target_repo` / `execution_host` / `cross_repo_boundary` / `target_repo_ref`）+ PII redaction
- `Dangerous Ops`：禁止 `rm -rf` / `git push --force` / `DROP` / `.env` 写入
- `Task Size Gradation`：S0/S1/S2/S3 `size` 硬必填
- 中文优先、工件真相源优先于聊天回忆

## 与 V1 冲突时怎么办

V2 是**平行扩展层**，不是**协议覆写层**。若 V2 文档与 V1 协议出现文字冲突，以 V1 为准。V2 哲学总纲 §7 列出了 V2 **允许重新思考**的 V1 预设（每条附反证理由，不为差异而差异），§9 列出了 V2 **必须继承**的硬骨头。

## 运行入口 vs 阅读入口（第三方审核 4.4）

V2 **不新增运行入口**。明确拆分如下，避免"V2 是不是另开一套系统"的误解：

### 运行入口（可执行）

| 场景 | 入口 | 来源 |
|---|---|---|
| 判断 DD Hermes 当前能不能用 / 有没有 active mainline / 最近 proof | `./scripts/demo-entry.sh` | V1 唯一运行入口 |
| 验证完成态 / gate 判定 | `hooks/quality-gate.sh` | V1 唯一 gate |
| smoke 验证 | `bash tests/smoke.sh` | V1 |

### 阅读入口（理解 V2 方向时读；不执行）

| 场景 | 入口 | 性质 |
|---|---|---|
| 理解 V2 哲学 / 四层来源 / docx 筛选 | `V2/00-哲学总纲.md` | 阅读文档，不执行 |
| 浏览 V2 候选方向 / 分层 / 证据强度 | `V2/01-方向矩阵.md` | 阅读文档，不执行 |
| V2 第三方审核 | `V2/99-网友的意见-2026-04-20.md` | 审核记录 |

### 立 V2 真实 slice 的顺序

1. 先走运行入口 `./scripts/demo-entry.sh` 确认当前无 active mainline
2. 再读阅读入口 `V2/01-方向矩阵.md §3` 选讨论顺序里的一条候选
3. 按 `AGENTS.md → Self-Reference Ops` 补齐当时的真实 `provable_need`
4. 按 V1 协议走 `contract + state + handoff + worktree + verification + closeout + archive`（全部落在 V1 路径）
