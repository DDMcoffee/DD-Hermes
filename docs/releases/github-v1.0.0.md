# DD Hermes v1.0.0 Release Assets

This file contains a release-ready commit message and GitHub Release copy for the first public DD Hermes release.

## Assumptions

- Tag: `v1.0.0`
- License: `MIT`
- Audience: GitHub readers seeing DD Hermes for the first time
- Language order: English first, then Japanese, Korean, Chinese

## Commit Message

### Subject

```text
chore(release): publish DD Hermes v1.0.0 under MIT
```

### Body

```text
- prepare the first public GitHub-facing DD Hermes V1 surface
- add MIT license and contributor guidance
- add release-ready GitHub copy in English, Japanese, Korean, and Chinese
- keep runtime truth in workspace/docs instead of hardcoding it into the landing page
```

## GitHub Release Title

```text
DD Hermes v1.0.0
```

## GitHub Release Body

### English

```md
## DD Hermes v1.0.0

DD Hermes is a workspace-first engineering harness for complex agent work.
It helps teams turn long, fragile chat-driven execution into explicit, reviewable, and reusable control-plane artifacts.

### What is included in V1

- A stable repository entry point for GitHub readers
- Explicit task artifacts such as `contract`, `state`, `context`, `handoff`, and `closeout`
- Scripts and hooks for state management, verification, workflow control, and guardrails
- Cross-repo execution guidance for keeping control-plane work separate from target business code
- MIT licensing for public reuse

### What V1 is not

- A new agent runtime
- A provider or plugin loader
- A replacement for your application repository
- A promise that live runtime state is encoded in the README

### Start here

1. Read `README.md`
2. Run `./scripts/demo-entry.sh`
3. Follow `指挥文档/06-一期PhaseDone审计.md`
4. Use `docs/context-runtime-state-memory.md` and `docs/cross-repo-execution.md` as the long-term protocol references

### Minimal verification

```bash
bash tests/smoke.sh schema
./scripts/demo-entry.sh
```

### Notes

This release focuses on making DD Hermes publishable, understandable, and reusable as a GitHub project.
The evolving `V2/` drafts are intentionally excluded from the stability promise of this release.
```

### Japanese

```md
## DD Hermes v1.0.0

DD Hermes は、複雑なエージェント作業を整理するための workspace-first なエンジニアリング harness です。
長く壊れやすいチャット中心の実行を、明示的でレビュー可能かつ再利用可能な control-plane artifact に変換します。

### V1 に含まれるもの

- GitHub 読者向けの安定したリポジトリ入口
- `contract`、`state`、`context`、`handoff`、`closeout` などの明示的なタスク artifact
- state 管理、検証、workflow 制御、guardrail のための scripts と hooks
- control-plane と target business code を分離するための cross-repo execution ガイド
- 公開再利用のための MIT ライセンス

### V1 が含まないもの

- 新しい agent runtime
- provider や plugin loader
- アプリケーション repo の置き換え
- README に live runtime state を固定的に書くこと

### 開始手順

1. `README.md` を読む
2. `./scripts/demo-entry.sh` を実行する
3. `指挥文档/06-一期PhaseDone审计.md` を読む
4. 長期的な protocol 参照として `docs/context-runtime-state-memory.md` と `docs/cross-repo-execution.md` を使う

### 最小検証

```bash
bash tests/smoke.sh schema
./scripts/demo-entry.sh
```

### 補足

このリリースは、DD Hermes を GitHub プロジェクトとして公開・理解・再利用しやすくすることに集中しています。
進行中の `V2/` 草稿は、このリリースの安定範囲には含めていません。
```

### Korean

```md
## DD Hermes v1.0.0

DD Hermes는 복잡한 에이전트 작업을 정리하기 위한 workspace-first 엔지니어링 harness입니다.
길고 불안정한 채팅 중심 실행을 명시적이고 검토 가능하며 재사용 가능한 control-plane artifact로 바꿔 줍니다.

### V1에 포함된 내용

- GitHub 독자를 위한 안정적인 저장소 진입점
- `contract`, `state`, `context`, `handoff`, `closeout` 같은 명시적 작업 artifact
- state 관리, 검증, workflow 제어, 가드레일을 위한 scripts 및 hooks
- control-plane 작업과 target business code를 분리하기 위한 cross-repo execution 가이드
- 공개 재사용을 위한 MIT 라이선스

### V1에 포함되지 않는 내용

- 새로운 agent runtime
- provider 또는 plugin loader
- 애플리케이션 저장소를 대체하는 것
- README에 실시간 runtime state를 고정해서 적어 두는 것

### 시작 방법

1. `README.md`를 읽습니다
2. `./scripts/demo-entry.sh`를 실행합니다
3. `指挥文档/06-一期PhaseDone审计.md`를 확인합니다
4. 장기 프로토콜 참조로 `docs/context-runtime-state-memory.md` 와 `docs/cross-repo-execution.md`를 사용합니다

### 최소 검증

```bash
bash tests/smoke.sh schema
./scripts/demo-entry.sh
```

### 메모

이번 릴리스는 DD Hermes를 GitHub 프로젝트로 공개하고 이해하고 재사용하기 쉽게 만드는 데 초점을 둡니다.
계속 발전 중인 `V2/` 초안은 이번 릴리스의 안정성 범위에 포함되지 않습니다.
```

### Chinese

```md
## DD Hermes v1.0.0

DD Hermes 是一个面向复杂 agent 工作的 workspace-first 工程 harness。
它把漫长、脆弱、依赖聊天上下文的执行过程，压成显式、可审阅、可复用的控制面工件。

### V1 包含什么

- 面向 GitHub 读者的稳定仓库入口
- `contract`、`state`、`context`、`handoff`、`closeout` 等显式任务工件
- 用于状态管理、验证、workflow 控制和防护的 scripts 与 hooks
- 用于分离 control-plane 与 target business code 的跨仓执行指南
- 支持公开复用的 MIT 许可证

### V1 不是什么

- 新的 agent runtime
- provider 或 plugin loader
- 业务应用仓库的替代品
- 把实时运行态硬编码进 README 的做法

### 从这里开始

1. 阅读 `README.md`
2. 运行 `./scripts/demo-entry.sh`
3. 查看 `指挥文档/06-一期PhaseDone审计.md`
4. 将 `docs/context-runtime-state-memory.md` 和 `docs/cross-repo-execution.md` 作为长期协议参考

### 最小验证

```bash
bash tests/smoke.sh schema
./scripts/demo-entry.sh
```

### 说明

这一版发布重点是让 DD Hermes 作为 GitHub 项目可发布、可理解、可复用。
仍在演进中的 `V2/` 草稿不属于这一版的稳定承诺。
```
