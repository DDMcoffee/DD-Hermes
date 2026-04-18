#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

repo=$(repo_root)
landing_doc_rel="指挥文档/06-一期PhaseDone审计.md"
decision_doc_rel="指挥文档/04-任务重校准与线程策略.md"
landing_doc="$repo/$landing_doc_rel"

if [[ ! -f "$landing_doc" ]]; then
  printf 'DD Hermes 体验入口无法生成，缺少以下事实源：\n- %s\n' "$landing_doc"
  exit 2
fi

find_commit() {
  local pattern="$1"
  git -C "$repo" log --grep "^$pattern" --format='%H' -n 1 2>/dev/null || true
}

latest_touch_commit() {
  local path="$1"
  git -C "$repo" log --format='%H' -n 1 -- "$path" 2>/dev/null || true
}

short_sha() {
  local sha="$1"
  if [[ -z "$sha" ]]; then
    printf '未找到'
  else
    printf '%.7s' "$sha"
  fi
}

read_frontmatter_field() {
  local field="$1"
  python3 - <<'PY' "$landing_doc" "$field"
from pathlib import Path
import re
import sys

text = Path(sys.argv[1]).read_text(encoding="utf-8")
match = re.match(r"---\n(.*?)\n---\n", text, re.S)
if not match:
    print("")
    raise SystemExit(0)
field = sys.argv[2]
for line in match.group(1).splitlines():
    if line.startswith(f"{field}:"):
        print(line.split(":", 1)[1].strip())
        break
PY
}

read_state_field() {
  local state_path="$1"
  local dotted="$2"
  python3 - <<'PY' "$state_path" "$dotted"
from pathlib import Path
import json
import sys

path = Path(sys.argv[1])
if not path.exists():
    print("")
    raise SystemExit(0)
try:
    data = json.loads(path.read_text(encoding="utf-8"))
except json.JSONDecodeError:
    print("")
    raise SystemExit(0)

value = data
for part in sys.argv[2].split("."):
    if isinstance(value, dict):
        value = value.get(part, "")
    else:
        value = ""
        break

if isinstance(value, str):
    print(value)
elif value in (None, []):
    print("")
else:
    print(str(value))
PY
}

phase_summary=$(read_frontmatter_field phase_status)
proof_task=$(read_frontmatter_field latest_proof_task_id)
archive_rel=$(read_frontmatter_field latest_proof_archive)
task_doc_rel=$(read_frontmatter_field current_mainline_doc)
next_task=$(read_frontmatter_field current_mainline_task_id)
gap_1=$(read_frontmatter_field current_gap_1)
gap_2=$(read_frontmatter_field current_gap_2)
archive_doc="$repo/$archive_rel"
task_doc=""
if [[ -n "$task_doc_rel" ]]; then
  task_doc="$repo/$task_doc_rel"
fi
proof_state_path="$repo/workspace/state/$proof_task/state.json"
mainline_state_json=""
if [[ -n "$next_task" ]]; then
  mainline_state_json=$("$repo/scripts/state-read.sh" --task-id "$next_task" 2>/dev/null || true)
fi
successor_audit_json=""
if [[ -z "$next_task" && -n "$proof_task" ]]; then
  successor_audit_json=$("$repo/scripts/coordination-endpoint.sh" --task-id "$proof_task" --endpoint successor.audit 2>/dev/null || true)
fi
proof_latest_commit=$(read_state_field "$proof_state_path" "git.latest_commit")
proof_status=$(read_state_field "$proof_state_path" "status")
proof_mode=$(read_state_field "$proof_state_path" "mode")

missing=()
for path in "$archive_doc"; do
  if [[ ! -f "$path" ]]; then
    missing+=("$path")
  fi
done
if [[ -n "$task_doc" && ! -f "$task_doc" ]]; then
  missing+=("$task_doc")
fi

if (( ${#missing[@]} > 0 )); then
  printf 'DD Hermes 体验入口无法生成，缺少以下事实源：\n'
  for path in "${missing[@]}"; do
    printf -- '- %s\n' "$path"
  done
  exit 2
fi

execution_commit=$(find_commit "feat(${proof_task}):")
integration_commit=$(find_commit "integrate(${proof_task}):")
if [[ -z "$execution_commit" && -n "$proof_latest_commit" ]]; then
  execution_commit="$proof_latest_commit"
fi
integration_commit_display=$(short_sha "$integration_commit")
if [[ -z "$integration_commit" && "$proof_status" == "done" && "$proof_mode" == "archive" ]]; then
  integration_commit_display="不单独存在"
fi
entry_task_commit="未找到"
if [[ -n "$task_doc_rel" ]]; then
  entry_task_commit=$(short_sha "$(latest_touch_commit "$task_doc_rel")")
  if [[ "$entry_task_commit" == "未找到" && -f "$task_doc" ]]; then
    entry_task_commit="当前工作树未提交"
  fi
fi
mainline_summary=$(STATE_JSON="$mainline_state_json" python3 - <<'PY'
import json
import os

payload = os.environ.get("STATE_JSON", "")
if not payload:
    print("")
    raise SystemExit(0)
try:
    data = json.loads(payload)
except json.JSONDecodeError:
    print("")
    raise SystemExit(0)
summary = data.get("summary", {})
lines = [
    "当前锚点真相",
    f"- Product Anchor：{summary.get('product_anchor_name', '未设置')} ({summary.get('product_anchor_role', '未设置')})",
    f"- Product Goal：{summary.get('goal', '未设置')}",
    f"- User Value：{summary.get('product_user_value', '未设置')}",
    f"- Task Class：{summary.get('task_class', '未设置')} ({summary.get('task_class_bucket', 'unknown')})",
    f"- Quality Requirement：{summary.get('quality_requirement', '未设置')}",
]
non_goals = summary.get("product_non_goals", [])
if non_goals:
    lines.append(f"- Non-goals：{'；'.join(non_goals)}")
lines.extend([
    f"- Product Gate：{summary.get('product_gate_status', 'unknown')}",
    f"- Quality Anchor：{summary.get('quality_anchor_name', '未设置')} ({summary.get('quality_anchor_role', '未设置')}, {summary.get('quality_anchor_status', 'unknown')})",
    f"- Quality Seat：{summary.get('quality_seat_mode', 'unknown')} ({summary.get('quality_seat_status', 'blocked')})",
    f"- Independent Skeptic：{'yes' if summary.get('independent_skeptic') else 'no'}",
    f"- Degraded Ack：{summary.get('degraded_ack_status', 'unknown')}",
])
reasons = summary.get("product_gate_reasons", [])
if reasons:
    lines.append(f"- Product Gate Reasons：{', '.join(reasons)}")
if summary.get("degraded_ack_required") and not summary.get("degraded_ack_ready"):
    lines.append("- Degraded Ack Reasons：degraded supervision requires explicit acknowledgement")
seat_reasons = summary.get("quality_seat_reasons", [])
if seat_reasons:
    lines.append(f"- Quality Seat Reasons：{', '.join(seat_reasons)}")
print("\n".join(lines))
PY
)
successor_audit_summary=$(AUDIT_JSON="$successor_audit_json" python3 - <<'PY'
import json
import os

payload = os.environ.get("AUDIT_JSON", "")
if not payload:
    print("")
    raise SystemExit(0)
try:
    data = json.loads(payload)
except json.JSONDecodeError:
    print("")
    raise SystemExit(0)

labels = {
    "active-mainline-present": "存在 active mainline",
    "candidate-available": "存在 committed 候选",
    "no-successor-yet": "暂无 committed successor",
}
verdict = labels.get(data.get("verdict", ""), data.get("verdict", "unknown"))
line = (
    f"successor 审计：{verdict}；"
    f"{data.get('committed_candidate_count', 0)} 个 committed 候选；"
    f"{data.get('local_residue_count', 0)} 个 local residue 已忽略"
)
residue = data.get("local_residue", [])
if residue:
    names = "、".join(item.get("task_id", "") for item in residue[:3] if item.get("task_id"))
    if names:
        line += f"\n- residue task_ids：{names}"
    first_hint = residue[0].get("hint", "")
    if first_hint:
        line += f"\n- residue 建议：{first_hint}"
print(line)
PY
)

cat <<EOF
DD Hermes 体验入口
===================

当前状态
- 一期状态：$phase_summary
- 当前入口页：$landing_doc_rel

最近一次真实 end-to-end 证明
- task_id：$proof_task
- execution commit：$(short_sha "$execution_commit")
- integration commit：$integration_commit_display
- archive：$archive_rel

当前 phase-2 主线
EOF

if [[ -n "$next_task" ]]; then
cat <<EOF
- task_id：$next_task
- 任务说明最新提交：$entry_task_commit
- 任务说明：$task_doc_rel
EOF
else
cat <<EOF
- 当前 active mainline：暂无
- 下一步决策文档：$decision_doc_rel
EOF
fi

cat <<EOF

当前还没做到什么
- $gap_1
- $gap_2

推荐阅读顺序
1. 先看：$landing_doc_rel
EOF

if [[ -n "$task_doc_rel" ]]; then
cat <<EOF
2. 再看：$task_doc_rel
EOF
else
cat <<EOF
2. 再看：$archive_rel
EOF
fi

cat <<EOF
3. 若要看最近一次真实证明：$archive_rel
EOF

if [[ -n "$mainline_summary" ]]; then
  printf '\n%s\n' "$mainline_summary"
fi

if [[ -n "$successor_audit_summary" ]]; then
  printf '\n%s\n' "$successor_audit_summary"
fi
