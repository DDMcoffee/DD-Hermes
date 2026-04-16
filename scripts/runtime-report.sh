#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

task_id=""
worktree=""
agent_role=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --task-id) task_id="$2"; shift 2 ;;
    --worktree) worktree="$2"; shift 2 ;;
    --agent-role) agent_role="$2"; shift 2 ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

repo=$(shared_repo_root)
worktree=${worktree:-$(repo_root)}
git_snapshot=$("$SCRIPT_DIR/git-snapshot.sh" --worktree "$worktree")
payload=$(GIT_SNAPSHOT="$git_snapshot" python3 - <<'PY' "$repo" "$worktree" "$task_id" "$agent_role"
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

repo = Path(sys.argv[1]).resolve()
worktree = Path(sys.argv[2]).resolve()
task_id = sys.argv[3]
agent_role = sys.argv[4]
git_snapshot = json.loads(os.environ["GIT_SNAPSHOT"])
contract_path = repo / "workspace" / "contracts" / f"{task_id}.md" if task_id else None
state_path = repo / "workspace" / "state" / task_id / "state.json" if task_id else None

payload = {
    "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "repo_root": str(repo),
    "worktree": str(worktree),
    "agent_role": agent_role or "",
    "shell": os.environ.get("SHELL", ""),
    "git": git_snapshot,
    "hooks": {
        "events": ["PreToolUse", "PostToolUse", "Stop", "SessionEnd"],
        "available": sorted(path.name for path in (repo / "hooks").glob("*.sh")),
    },
    "skills": sorted(path.parent.name for path in (repo / ".codex" / "skills").glob("*/SKILL.md")),
    "tests": sorted(
        [path.name for path in (repo / "scripts").glob("test-*.sh")]
        + ([str(Path("tests") / "smoke.sh")] if (repo / "tests" / "smoke.sh").exists() else [])
    ),
    "task_surfaces": {
        "contract_path": str(contract_path) if contract_path and contract_path.exists() else "",
        "state_path": str(state_path) if state_path and state_path.exists() else "",
    },
}
print(json.dumps(payload, ensure_ascii=False))
PY
)
json_out "$payload"
