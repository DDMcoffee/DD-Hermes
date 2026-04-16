#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

repo=$(repo_root)
landing_doc_rel="指挥文档/06-一期PhaseDone审计.md"
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

phase_summary=$(read_frontmatter_field phase_status)
proof_task=$(read_frontmatter_field latest_proof_task_id)
archive_rel=$(read_frontmatter_field latest_proof_archive)
task_doc_rel=$(read_frontmatter_field current_mainline_doc)
next_task=$(read_frontmatter_field current_mainline_task_id)
archive_doc="$repo/$archive_rel"
task_doc="$repo/$task_doc_rel"

missing=()
for path in "$archive_doc" "$task_doc"; do
  if [[ ! -f "$path" ]]; then
    missing+=("$path")
  fi
done

if (( ${#missing[@]} > 0 )); then
  printf 'DD Hermes 体验入口无法生成，缺少以下事实源：\n'
  for path in "${missing[@]}"; do
    printf -- '- %s\n' "$path"
  done
  exit 2
fi

execution_commit=$(find_commit "feat(${proof_task}):")
integration_commit=$(find_commit "integrate(${proof_task}):")
entry_task_commit=$(latest_touch_commit "$task_doc_rel")

cat <<EOF
DD Hermes 体验入口
===================

当前状态
- 一期状态：$phase_summary
- 当前入口页：$landing_doc_rel

最近一次真实 end-to-end 证明
- task_id：$proof_task
- execution commit：$(short_sha "$execution_commit")
- integration commit：$(short_sha "$integration_commit")
- archive：$archive_rel

当前主线任务
- task_id：$next_task
- 任务说明最新提交：$(short_sha "$entry_task_commit")
- 任务说明：$task_doc_rel

当前还没做到什么
- 还没有完成一期的最终收口裁决
- 还需要把单一用户可见入口持续维护为 repo 真相，而不是口头说明

推荐阅读顺序
1. 先看：$landing_doc_rel
2. 再看：$task_doc_rel
3. 若要看第一次真实证明：$archive_rel
EOF
