#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

task_id=""
message=""
worktree=""
allow_primary="false"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --task-id) task_id="$2"; shift 2 ;;
    --message) message="$2"; shift 2 ;;
    --worktree) worktree="$2"; shift 2 ;;
    --allow-primary) allow_primary="true"; shift ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

if [[ -z "$task_id" ]]; then
  json_out '{"error":"task_id is required"}'
  exit 3
fi

repo=$(shared_repo_root)
worktree=${worktree:-$(repo_root)}
worktree=$(abs_path "$worktree")
if [[ "$allow_primary" != "true" && "$worktree" == "$(abs_path "$repo")" ]]; then
  json_out '{"error":"refusing to create execution commit in primary worktree","blocked":true}'
  exit 2
fi
if ! git -C "$repo" rev-parse --verify HEAD >/dev/null 2>&1; then
  json_out '{"error":"repository needs a baseline commit before task commits","blocked":true}'
  exit 2
fi

dirty=$(git -C "$worktree" status --porcelain 2>/dev/null || true)
if [[ -z "$dirty" ]]; then
  json_out '{"error":"no changes to commit","blocked":true}'
  exit 2
fi

git -C "$worktree" add -A
message=${message:-"task($task_id): execution slice"}
git -C "$worktree" -c user.name=Codex -c user.email=codex@local commit -m "$message" >/dev/null
snapshot=$("$SCRIPT_DIR/git-snapshot.sh" --worktree "$worktree")

state_update=$(SNAPSHOT="$snapshot" python3 - <<'PY'
import json
import os

snap = json.loads(os.environ["SNAPSHOT"])
payload = {
    "worktree_path": snap["worktree"],
    "commit_sha": snap["head"],
    "commit_branch": snap["branch"],
    "commit_upstream": snap["upstream"],
    "commit_remote_urls": snap["remote_urls"],
}
print(json.dumps(payload, ensure_ascii=False))
PY
)
if [[ -f "$repo/workspace/state/$task_id/state.json" ]]; then
  printf '%s' "$state_update" | "$SCRIPT_DIR/state-update.sh" --task-id "$task_id" >/dev/null || true
fi

payload=$(SNAPSHOT="$snapshot" python3 - <<'PY' "$message"
import json
import os
import sys

snap = json.loads(os.environ["SNAPSHOT"])
message = sys.argv[1]
print(json.dumps({
    "task_id": "",
    "commit_sha": snap["head"],
    "branch": snap["branch"],
    "worktree": snap["worktree"],
    "message": message,
    "upstream": snap["upstream"],
    "remote_urls": snap["remote_urls"],
}, ensure_ascii=False))
PY
)
payload=$(TASK_ID="$task_id" PAYLOAD="$payload" python3 - <<'PY'
import json
import os

payload = json.loads(os.environ["PAYLOAD"])
payload["task_id"] = os.environ["TASK_ID"]
print(json.dumps(payload, ensure_ascii=False))
PY
)
json_out "$payload"
