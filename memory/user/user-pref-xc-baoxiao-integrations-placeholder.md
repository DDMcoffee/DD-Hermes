---
id: "user-pref-xc-baoxiao-integrations-placeholder"
type: "preference"
content: "For XC-BaoXiaoAuto web product, user prefers DingTalk/WeCom integrations remain as 501 placeholders; early-stage data entry uses manual upload only."
source: "user-stated during M2 slice selection on 2026-04-18"
scope: "xc-baoxiao-web product scope and slice prioritization"
confidence: "1.0"
created_at: "2026-04-18T08:30:00Z"
last_validated_at: "2026-04-18T08:30:00Z"
decay_policy: "manual"
status: "active"
---

# Memory Card

## Evidence

- Source: user reply on 2026-04-18 during DD Hermes M2 decision: "钉钉企业微信那些只做占位，前期还是使用上传导入".
- Echoes `docs/web/报销系统 Web 界面搭建方案.md:10-12` non-goals (审批流 / 自动填报 / 163 / 钉钉正式对接).
- Also `docs/web/报销系统 Web 界面搭建方案.md:124` (`/api/integrations/dingtalk` 保留 501 占位接口，不实现业务逻辑).

## Implications for DD Hermes slice triage

- Any slice proposing "auto-pull from DingTalk/WeCom" defaults to `deferred` under §5.1 unless user explicitly rescinds this preference.
- Real-user data entry starts at `/api/uploads` (manual upload), not integration channels.
- `/api/integrations/dingtalk` stays 501; fully acceptable as-is.

## Revalidation

- Re-check if user explicitly opens a DingTalk/WeCom slice in a future M-cycle.
- Until then: do not propose integration work as mainline.
