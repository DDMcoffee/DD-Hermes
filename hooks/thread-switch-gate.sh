#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../scripts/common.sh
source "$SCRIPT_DIR/../scripts/common.sh"

task_id=""
target_thread=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --task-id) task_id="$2"; shift 2 ;;
    --target) target_thread="$2"; shift 2 ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

if [[ -z "$task_id" ]]; then
  json_out '{"error":"task_id is required"}'
  exit 3
fi

repo=$(shared_repo_root)
state_path="$repo/workspace/state/$task_id/state.json"

payload=$(python3 - <<'PY' "$state_path" "$target_thread"
import json
import sys
from pathlib import Path

state_path = Path(sys.argv[1])
target = sys.argv[2]

if not state_path.exists():
    print(json.dumps({"pass": True, "reason": "no state file, allowing switch"}))
    raise SystemExit(0)

state = json.loads(state_path.read_text(encoding="utf-8"))
discussion = state.get("discussion", {})
policy = discussion.get("policy", "")
synthesis_path = discussion.get("synthesis_path", "")

blocked = False
reason = ""

if target == "execution" and policy == "3-explorer-then-execute":
    if not synthesis_path:
        blocked = True
        reason = "discussion.policy is 3-explorer-then-execute but synthesis_path is empty; complete synthesis before dispatching execution thread"
    elif not Path(synthesis_path).exists():
        blocked = True
        reason = f"synthesis_path points to {synthesis_path} which does not exist"

lease = state.get("lease", {})
lease_status = lease.get("status", "")
if target == "execution" and lease_status == "paused":
    blocked = True
    reason = f"lease is paused (reason: {lease.get('pause_reason', 'unknown')}); resume before dispatching"

if target == "execution":
    team = state.get("team", {}) if isinstance(state.get("team"), dict) else {}
    executors = [e for e in team.get("executors", []) if isinstance(e, str) and e.strip()]
    if not executors:
        blocked = True
        reason = "no executors assigned in state.team; run dispatch-create.sh first"

result = {
    "pass": not blocked,
    "target_thread": target,
    "discussion_policy": policy,
    "synthesis_path": synthesis_path,
    "blocked_reason": reason,
    "required_next_step": reason if blocked else "",
}
print(json.dumps(result, ensure_ascii=False))
PY
)

json_out "$payload"
if [[ $(PAYLOAD="$payload" python3 -c 'import json,os; print("1" if json.loads(os.environ["PAYLOAD"])["pass"] else "0")') == "1" ]]; then
  exit 0
fi
exit 2
