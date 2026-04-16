#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

changed_files=""
spec_path=""
task_id=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --changed-files) changed_files="$2"; shift 2 ;;
    --spec-path) spec_path="$2"; shift 2 ;;
    --task-id) task_id="$2"; shift 2 ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

repo=$(repo_root)
if [[ -z "$spec_path" && -n "$task_id" ]]; then
  candidate="$repo/openspec/proposals/$task_id.md"
  if [[ -f "$candidate" ]]; then
    spec_path="$candidate"
  fi
fi

payload=$(python3 - <<'PY' "$changed_files" "$spec_path" "$task_id"
import json
import sys
from pathlib import Path

changed_files, spec_path, task_id = sys.argv[1:]
files = [part for part in changed_files.split(",") if part]
required = len(files) >= 3
valid = False
task_bound = False
reason = ""
if spec_path:
    path = Path(spec_path)
    if path.exists():
        text = path.read_text(encoding="utf-8")
        valid = all(section in text for section in (
            "## What",
            "## Why",
            "## Non-goals",
            "## Acceptance",
            "## Verification",
        ))
        task_bound = (not task_id) or (path.stem == task_id)

missing = required and not spec_path
blocked = required and (missing or not valid or not task_bound)
if blocked:
    if missing:
        reason = "missing proposal for this change set"
    elif not task_bound:
        reason = "proposal does not match current task id"
    else:
        reason = "proposal is missing required sections"
print(json.dumps({
    "required": required,
    "spec_path": spec_path,
    "missing": missing,
    "valid": valid,
    "task_bound": task_bound,
    "blocked": blocked,
    "reason": reason,
}, ensure_ascii=False))
PY
)

json_out "$payload"
if [[ $(PAYLOAD="$payload" python3 - <<'PY'
import json, os
print("1" if json.loads(os.environ["PAYLOAD"])["blocked"] else "0")
PY
) == "1" ]]; then
  exit 2
fi
