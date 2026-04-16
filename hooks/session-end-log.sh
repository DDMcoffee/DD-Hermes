#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../scripts/common.sh
source "$SCRIPT_DIR/../scripts/common.sh"

session_id="unknown"
event="SessionEnd"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --event) event="$2"; shift 2 ;;
    --session-id) session_id="$2"; shift 2 ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

input_json=$(read_stdin_json)
repo=$(repo_root)
mkdir -p "$repo/workspace/logs"
log_file="$repo/workspace/logs/session-$(today_utc).jsonl"

line=$(INPUT_JSON="$input_json" SESSION_ID="$session_id" EVENT="$event" python3 - <<'PY'
import json
import os
from datetime import datetime, timezone

data = json.loads(os.environ.get("INPUT_JSON", "{}"))
line = {
    "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "session_id": os.environ.get("SESSION_ID"),
    "event": os.environ.get("EVENT"),
    "tool_counts": data.get("tool_counts", {}),
    "error_counts": data.get("error_counts", {}),
    "file_changes": data.get("file_changes", []),
    "verification_events": data.get("verification_events", []),
    "fragmentation_signals": data.get("fragmentation_signals", {}),
}
print(json.dumps(line, ensure_ascii=False))
PY
)
append_journal_line "$log_file" "$line"

payload=$(python3 - <<'PY' "$log_file" "$session_id"
import json
import sys

log_file, session_id = sys.argv[1:]
print(json.dumps({
    "log_file": log_file,
    "summary": f"session {session_id} logged",
    "warnings": [],
}, ensure_ascii=False))
PY
)
json_out "$payload"

