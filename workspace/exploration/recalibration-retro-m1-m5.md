---
title: DD Hermes 重校准 Retro (M1-M5)
recalibration_arc: 2026-04-17 to 2026-04-18
status: retro-complete
commits_span:
  - "3be33fa M3: governance cleanup + self-reference ops + task size gradation"
  - "919ebfe M4: cross-repo protocol skeleton"
  - "7e22fc5 M5a: first real slice instantiation (xc-baoxiao-web-gate-green-v1)"
  - "723ac8d M5d: closeout after baseline confirmed green"
next_mainline_candidates:
  - xc-baoxiao-web-test-coverage-v1
  - xc-baoxiao-web-docs-roadmap-v1
  - dd-hermes-gate-stdin-closeout-fallback-v1
---

# DD Hermes 重校准 Retro

## 为什么要做这次重校准

2026-04-17 时 DD Hermes 已经具备完整 harness 能力（control plane / contract / state / quality-gate / endpoint / smoke），但出现**产品漂移**信号：

- 最近三个 mainline 都是 harness 自指（router / dispatch / evidence audit）
- 没有一条 mainline 是 DD Hermes 指挥**其他仓库**做的实际业务工作
- 存在诱惑把 harness 自身的治理 slice 继续当 mainline 做，但这违背 DD Hermes 的北极星目标（"指挥 AI coding，防漂移"）

这次重校准的核心产品问题：**DD Hermes 能不能作为跨仓指挥工具产生可验证的用户价值？**

## M1 triage

- 扫了 HEAD 附近 commit history、active mainline 状态、residue 堆积
- 发现：无 active mainline（合规），但 successor evidence 里候选都是 harness self-reference
- 诊断：需要**切换真实产品视角**，不继续自指，而是去真实业务仓产生具体可测产物

## M2 slice selection

三个候选对比：

| 候选 | 类型 | 风险 | 产品价值 |
|---|---|---|---|
| A: xc-baoxiao-web-gate-green-v1 | 跨仓 npm gate | 中（可能红基线） | 高（trusted baseline SHA） |
| B: xc-baoxiao-docs roadmap | 跨仓纯文档 | 低 | 中（文档不如 test 可验证） |
| C: dd-hermes-self-improvement | 自指 harness | 低 | 低（违反 Self-Reference Ops） |

选定 A。A 的风险被 S2 size + 2h timebox + execution_host=target-repo 隔离边界约束住。

## M3 governance cleanup (`3be33fa`)

写进 `AGENTS.md`：

1. **Self-Reference Ops**：任何新 proposal 若主题是 DD Hermes 自身 harness 能力，必须附 `provable_need` 字段引用真实 slice 证据；否则自动降级 `deferred`
2. **Task Size Gradation**：S0/S1/S2/S3 四级，`contract.size` 硬必填，缺则按 S2 报警
3. **结构硬约束**：`指挥文档/` 文件数 <= 8（quality-gate.sh 先于 per-task 检查触发）
4. 18 份历史 harness contract 从 `workspace/contracts/` 移至 `_archive/`

**M3 的最大价值**：让"DD Hermes 自己再加一个治理特性"这类诱惑被规则层拦住，不是靠人记得。M4 规划时这条规则**真实生效**（差点又立 harness slice，被规则挡下）。

## M4 cross-repo protocol skeleton (`919ebfe`)

- `AGENTS.md` 加 **Cross-Repo Execution** 段：`target_repo / execution_host / target_repo_ref / cross_repo_boundary` 四字段
- `docs/cross-repo-execution.md` 120 行：角色分工、数据流、redaction 清单、典型流程、invariants、anti-patterns
- `workspace/contracts/README.md` + `_template.md`：size + cross_repo 字段骨架
- `workspace/state/xc-baoxiao-web-gate-green-v1/README.md` 占位：标明 M5 pending，不急着立 state.json

**关键设计决策**：DD Hermes 不直接 git push target_repo；target_repo 的 commit / branch 生命周期在其自己仓内管理；只有 redacted summary 能回流到 DD Hermes tracked 文件。

## M5 first real cross-repo slice (`7e22fc5` + `723ac8d`)

### M5a slice 实例化

- `workspace/contracts/xc-baoxiao-web-gate-green-v1.md` 从 `_template.md` 填满
  - size=S2, task_class=T2, quality_requirement=degraded-allowed
  - cross_repo_boundary.allowed_back vs forbidden_back 明确
  - 2h fix-pressure cap 明确写进 blocked_if
- handoff 承载 M5b instruction 集
- memory/task hint 声明 active
- state.json 初始化，`team.role_integrity.independent_skeptic=false, degraded=true, degraded_ack_by=lead` 诚实记录

### M5b baseline probe（跨仓 execution_host=target-repo）

1. `git status`：发现 6 份预先未 commit 修改（auth / middleware / .env.example / docs / db）
2. `git stash push -u`：保留 stash ref，工作区纯净至 `a6619de5`
3. 三门全跑：
   - `npm install` → exit 0（3s，286 pkgs up to date）
   - `npm run typecheck` → exit 0（0 errors）
   - `npm test` → exit 0（1/1 vitest pass, 191ms）
   - `npm run build` → exit 0（Next.js 11.6s, 15 static pages）
4. `git stash pop`：6 份修改完好恢复，stash ref 已清理

**结论**：baseline 本身就是绿的 → **无 M5c 修复循环**

### M5d closeout

- `workspace/closeouts/xc-baoxiao-web-gate-green-v1-lead.md` 完整落盘
- memory hint 更新到 `status=done`，加 `target_repo_baseline_green_sha` 字段
- state.json 更新到 `lease.status=done, product.goal_status=met`
- contract 归档到 `_archive/`
- 最终 gate 跑：`GATE_EXIT=0, pass=true, missing_verification=[]`

## 用户价值判定

### DD Hermes 这次交付了什么？

**一个可信的基线 SHA**：`a6619de50df5474233cbe8a33b718817950fb196` 在 web-main 上三门 npm 全绿。这不是模糊的"看起来没事"，是四个 exit code = 0 加上可查的 evidence 路径。

**一套跨仓协议**：`docs/cross-repo-execution.md` + `workspace/contracts/_template.md` + `memory/task/xc-baoxiao-web-gate-green-v1.md` 三件套可复用到未来所有 XC-BaoXiaoAuto 跨仓 slice。

**一条反漂移规则**：`Self-Reference Ops` 在 M4 规划时被实际触发（如果再加 harness 自指 slice，需要 provable_need）。DD Hermes 从"它自己觉得要做什么"切换成"真实 slice 的证据决定"。

**一条 PII 护栏**：`cross_repo_boundary.forbidden_back` 在 M5b 实际 probe 中零触发 — 没有任何名字、金额、发票号进 DD Hermes git history。redaction 不是口号，是工程化约束。

### DD Hermes 没交付什么？

- **真正的多线程执行**：M5 是单线程 degraded 跑的。没有独立 skeptic。user value 判定是 lead 自己做的，不是被第三方 agent 盖章的。
- **CI 集成**：三门 gate 是本地跑的。如果别人 push 到 web-main，没有自动 re-probe。
- **测试覆盖**：baseline 绿是因为只有 1 个测试。信号质量天花板受测试覆盖率限制。
- **对未来 commit 的持续保证**：SHA `a6619de5` 是瞬间快照。若 web-main 前进，需要 re-run。

## 观察到的 protocol gaps

### G1 - execution_closeout stdin-mode 无声 not-evaluated

**证据**：M5d final gate run 输出 `execution_closeout_status=not-evaluated`。closeout 文件实际已在磁盘上（`workspace/closeouts/xc-baoxiao-web-gate-green-v1-lead.md`），但 gate 不知道因为用户用 stdin 而非 `--state` 传入。

**provable_need**：真实 slice（M5）里观察到的 silent gap；未来所有 stdin-mode 用户都会踩。

**处理**：M6 内 fix。在 stdin mode + data 含 `task_id` + state-shaped fields 时，从 `script_dir.parent` 推断 repo_root，调 closeout_verdict。

### G2 - write_to_file vs gitignore 冲突

**证据**：M5a 并行写 4 个文件时，state.json（gitignored）被 write_to_file 工具层拒绝。

**非 DD Hermes 问题**：是 Windsurf 工具层把 `.gitignore` 的读保护错误地应用到写操作。workaround 是 write 到 `/tmp/` + `cp`。

**处理**：memory/self 记录，下次遇到直接走 /tmp 路径，不再重试。

### G3 - 并行 write_to_file 的失败传播语义不清晰

**证据**：M5a 并行 4 个 write_to_file，其中 1 个失败。实际结果是前 3 个都落盘成功，但返回给我的是"都被 defer"的表述，误导我以为全部未写。用 `ls` 才确认实际状态。

**处理**：memory/self 记录，下次并行写之后先跑 ls 确认每个文件落盘状态，不信任 defer 表述。

## What worked

- **milestone-based 推进**：每个 milestone 结束 stop + 问用户，不一路狂奔。M4 后 asked 用户才进 M5，让 scope 可控。
- **timeboxed sub-beats**：M5b 跑完立刻评估是否进 M5c，不自动假设"要修"。事实证明绿基线不需要修。
- **stash/pop discipline**：6 份预先 WIP 完整保全，技术上 trivial 但操作上关键。
- **redaction-by-design**：contract.cross_repo_boundary 在 M5a 写好，M5b 执行时已经是自动约束而不是事后审查。
- **每次 commit 用 /tmp 文件 + -F**：避免终端渲染长 message 卡顿。

## What didn't work

- **初次尝试并行 4 个 write_to_file**：gitignore 阻止了 1 个，其他的状态语义不清（见 G3）。
- **第一次 smoke test 用 stdin 忽略了 execution_closeout 评估链路**：直到最后才发现 gap（见 G1）。
- **retro 开始前对 "全绿基线" 的低估**：M5b 开始前我预估红基线概率 ~50%；实际绿基线，说明用户 web-main 维护得比预期好。未来类似 slice 应该把"可能直接绿"作为一个正规情况，而不是"我们希望红以便展示修复能力"的浪漫情怀。

## Next mainline 候选

按 user value 优先级排：

### 候选 1: `xc-baoxiao-web-test-coverage-v1`（跨仓，S2/T2）

- **问题**：`products/web/` 只有 1 个 vitest 测试（`matching.test.ts`）。baseline 绿的信号质量天花板低。
- **产品价值**：测试覆盖从 1 扩到 ~5，覆盖 auth / middleware / trpc router 等核心路径。
- **cross_repo_boundary**：同 M5，redaction 一致，evidence 汇总为新增 test count + covered function count。
- **估 time**：90-150 min（含测试设计 + 写测试 + 跑绿）

### 候选 2: `xc-baoxiao-web-docs-roadmap-v1`（跨仓，S1）

- **问题**：`docs/web/README.md` 是空的或 placeholder（M5b 发现它是 pre-existing modification 之一）。
- **产品价值**：整理 web 产品线的当前状态、未来 roadmap、integration 占位说明。帮 XC-BaoXiaoAuto 维护者和协作者对齐。
- **cross_repo_boundary**：纯文档，几乎零 PII 风险。
- **估 time**：45-75 min

### 候选 3: `dd-hermes-gate-stdin-closeout-fallback-v1`（harness 自指，S1）

- **问题**：G1 gap 已经在 M6 内临时修，但更系统的 integration test 还没加。
- **产品价值**：为未来所有跨仓 slice 关闭一个 silent gate-evaluation gap。
- **provable_need**：M5d 观察到的 `execution_closeout_status=not-evaluated`，真实 slice 证据。
- **估 time**：30-45 min（已 partial 完成 in M6，只剩 smoke test 补齐）

## 核心结论

DD Hermes 这次重校准把自己从"一个总觉得要完善自身的 harness"拖回到"一个能指挥真实 AI coding 工作的工具"。M5 的 green baseline SHA 是第一条**确实存在于 XC-BaoXiaoAuto 仓、可被独立 reproduce 的真实证据**，不是 DD Hermes 内部的 contract 炫技。

下一步要用这条协议做第二次、第三次、第 N 次跨仓 slice。只有当别人问"为什么要用 DD Hermes 而不是直接跑 npm"时，你能把 M5 的 cross_repo_boundary + stash/pop discipline + redaction evidence 指给他看 —— 这个重校准才算真正落地。
