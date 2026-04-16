#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

role=""
task_id=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --role) role="$2"; shift 2 ;;
    --task-id) task_id="$2"; shift 2 ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

input_json=$(read_stdin_json)
if [[ -z "$role" || -z "$task_id" ]]; then
  json_out '{"error":"role and task_id are required"}'
  exit 3
fi

repo=$(repo_root)
mkdir -p "$repo/workspace/exploration"
log_path="$repo/workspace/exploration/exploration-$role-$task_id.md"
INPUT_JSON="$input_json" ROLE="$role" TASK_ID="$task_id" LOG_PATH="$log_path" python3 - <<'PY'
import json
import os
from pathlib import Path

data = json.loads(os.environ.get("INPUT_JSON", "{}"))
facts = data.get("facts", [])
hypotheses = data.get("hypotheses", [])
status = data.get("status", "IN_PROGRESS")
next_questions = data.get("next_questions", [])

path = Path(os.environ["LOG_PATH"])
path.write_text(
    "# Exploration Log\n\n"
    "## Context\n\n"
    f"- Task: {os.environ['TASK_ID']}\n"
    f"- Role: {os.environ['ROLE']}\n"
    f"- Status: {status}\n\n"
    "## Facts\n\n"
    + "\n".join(f"- {item}" for item in facts)
    + "\n\n## Hypotheses\n\n"
    + "\n".join(f"- {item}" for item in hypotheses)
    + "\n\n## Next Questions\n\n"
    + "\n".join(f"- {item}" for item in next_questions)
    + "\n",
    encoding="utf-8",
)
PY

payload=$(python3 - <<'PY' "$log_path" "$role" "$task_id"
import json
import sys

log_path, role, task_id = sys.argv[1:]
print(json.dumps({
    "log_path": log_path,
    "status": "written",
    "blocked": False,
    "next_questions": [],
    "task_id": task_id,
    "role": role,
}, ensure_ascii=False))
PY
)
json_out "$payload"

