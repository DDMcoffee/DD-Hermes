#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

task_id=""
stage=""
owner="lead"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --task-id) task_id="$2"; shift 2 ;;
    --stage) stage="$2"; shift 2 ;;
    --owner) owner="$2"; shift 2 ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

if [[ -z "$task_id" || -z "$stage" ]]; then
  json_out '{"error":"task_id and stage are required"}'
  exit 3
fi

case "$stage" in
  proposal) template="proposal.template.md"; target_dir="proposals"; status="proposed" ;;
  design) template="design.template.md"; target_dir="designs"; status="design" ;;
  task) template="task.template.md"; target_dir="tasks"; status="active" ;;
  archive) template="archive.template.md"; target_dir="archive"; status="archived" ;;
  *)
    json_out '{"error":"invalid stage"}'
    exit 3
    ;;
esac

repo=$(repo_root)
mkdir -p "$repo/openspec/$target_dir"
target_path="$repo/openspec/$target_dir/$task_id.md"
template_path="$repo/openspec/$template"

python3 - "$template_path" "$target_path" "$owner" "$task_id" "$status" <<'PY'
import sys
from pathlib import Path

template_path = Path(sys.argv[1])
target_path = Path(sys.argv[2])
owner = sys.argv[3]
task_id = sys.argv[4]
status = sys.argv[5]

text = template_path.read_text(encoding="utf-8")
lines = text.splitlines()
out = []
for line in lines:
    if line.startswith("status:"):
        out.append(f"status: {status}")
    elif line.startswith("owner:"):
        out.append(f"owner: {owner}")
    elif line.startswith("scope:"):
        out.append(f"scope: {task_id}")
    else:
        out.append(line)
target_path.write_text("\n".join(out) + "\n", encoding="utf-8")
PY

payload=$(python3 - <<'PY' "$target_path" "$stage"
import json
import sys

path, stage = sys.argv[1:]
print(json.dumps({"path": path, "stage": stage}, ensure_ascii=False))
PY
)
json_out "$payload"
