#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

task_id=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --task-id) task_id="$2"; shift 2 ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

if [[ -z "$task_id" ]]; then
  json_out '{"error":"task_id is required"}'
  exit 3
fi

repo=$(shared_repo_root)
contract_path="$repo/workspace/contracts/$task_id.md"
if [[ ! -f "$contract_path" ]]; then
  json_out '{"error":"missing sprint contract","blocked":true}'
  exit 2
fi

if [[ ! -f "$repo/workspace/state/$task_id/state.json" ]]; then
  "$SCRIPT_DIR/state-init.sh" --task-id "$task_id" >/dev/null
fi

state_json=$("$SCRIPT_DIR/state-read.sh" --task-id "$task_id")
context_json=$("$SCRIPT_DIR/context-build.sh" --task-id "$task_id" --agent-role commander)

payload=$(STATE_JSON="$state_json" CONTEXT_JSON="$context_json" python3 - <<'PY' "$repo" "$task_id" "$SCRIPT_DIR"
import json
import os
import shlex
import subprocess
import sys
from pathlib import Path

repo = Path(sys.argv[1]).resolve()
task_id = sys.argv[2]
script_dir = Path(sys.argv[3]).resolve()
state_wrapper = json.loads(os.environ["STATE_JSON"])
context_wrapper = json.loads(os.environ["CONTEXT_JSON"])
state = state_wrapper["state"]
context_path = context_wrapper["context_path"]
runtime_path = context_wrapper["runtime_path"]
state_path = context_wrapper["state_path"]


def normalize_people(items):
    seen = set()
    result = []
    for item in items or []:
        if not isinstance(item, str):
            continue
        value = item.strip()
        if not value or value in seen:
            continue
        seen.add(value)
        result.append(value)
    return result


def handoff_for(agent_id):
    for path in state.get("handoff_paths", []):
        if Path(path).name.endswith(f"-to-{agent_id}.md"):
            return path
    return ""


def run_json(cmd):
    proc = subprocess.run(
        cmd,
        cwd=str(repo),
        capture_output=True,
        text=True,
        check=True,
    )
    return json.loads(proc.stdout)


team = state.get("team", {}) if isinstance(state.get("team"), dict) else {}
supervisors = normalize_people(team.get("supervisors", []))
executors = normalize_people(team.get("executors", []))
skeptics = normalize_people(team.get("skeptics", []))

if not supervisors:
    print(json.dumps({"error": "dispatch requires at least one supervisor", "blocked": True}, ensure_ascii=False))
    raise SystemExit(2)
if not executors:
    print(json.dumps({"error": "dispatch requires at least one executor", "blocked": True}, ensure_ascii=False))
    raise SystemExit(2)
if not skeptics:
    print(json.dumps({"error": "dispatch requires at least one skeptic", "blocked": True}, ensure_ascii=False))
    raise SystemExit(2)

assignments = []
created_worktrees = []
existing_worktrees = []

for agent_id in supervisors:
    assignments.append({
        "agent_id": agent_id,
        "role": "supervisor",
        "status": "ready",
        "worktree_required": False,
        "worktree_path": "",
        "branch": "",
        "handoff_path": "",
        "artifacts": {
            "contract_path": state.get("contract_path", ""),
            "state_path": state_path,
            "context_path": context_path,
            "runtime_path": runtime_path,
        },
        "next_commands": [
            f"cd {shlex.quote(str(repo))}",
            f"./scripts/state-read.sh --task-id {task_id}",
            f"./scripts/context-build.sh --task-id {task_id} --agent-role supervisor",
        ],
    })

for agent_id in executors:
    expected_worktree = repo / ".worktrees" / f"{task_id}-{agent_id}"
    branch = f"{task_id}-{agent_id}"
    status = "existing"
    if expected_worktree.exists():
        existing_worktrees.append(str(expected_worktree))
    else:
        created = run_json([str(script_dir / "worktree-create.sh"), "--task-id", task_id, "--expert", agent_id])
        expected_worktree = Path(created["worktree_path"]).resolve()
        branch = created["branch"]
        status = "created"
        created_worktrees.append(str(expected_worktree))
    assignments.append({
        "agent_id": agent_id,
        "role": "executor",
        "status": status,
        "worktree_required": True,
        "worktree_path": str(expected_worktree),
        "branch": branch,
        "handoff_path": handoff_for(agent_id),
        "artifacts": {
            "contract_path": state.get("contract_path", ""),
            "state_path": state_path,
            "context_path": context_path,
            "runtime_path": runtime_path,
        },
        "next_commands": [
            f"cd {shlex.quote(str(expected_worktree))}",
            "git status --short",
            f"./scripts/context-build.sh --task-id {task_id} --agent-role executor --worktree {shlex.quote(str(expected_worktree))}",
        ],
    })

for agent_id in skeptics:
    assignments.append({
        "agent_id": agent_id,
        "role": "skeptic",
        "status": "ready",
        "worktree_required": False,
        "worktree_path": "",
        "branch": "",
        "handoff_path": "",
        "artifacts": {
            "contract_path": state.get("contract_path", ""),
            "state_path": state_path,
            "context_path": context_path,
            "runtime_path": runtime_path,
        },
        "next_commands": [
            f"cd {shlex.quote(str(repo))}",
            f"./scripts/context-build.sh --task-id {task_id} --agent-role skeptic",
            f"./scripts/state-read.sh --task-id {task_id}",
        ],
    })

print(json.dumps({
    "task_id": task_id,
    "contract_path": state.get("contract_path", ""),
    "state_path": state_path,
    "context_path": context_path,
    "runtime_path": runtime_path,
    "scale_out_recommended": bool(team.get("scale_out_recommended", False)),
    "scale_out_triggers": team.get("scale_out_triggers", []),
    "summary": {
        "supervisor_count": len(supervisors),
        "executor_count": len(executors),
        "skeptic_count": len(skeptics),
        "assignment_count": len(assignments),
        "created_worktree_count": len(created_worktrees),
        "existing_worktree_count": len(existing_worktrees),
    },
    "created_worktrees": created_worktrees,
    "existing_worktrees": existing_worktrees,
    "assignments": assignments,
}, ensure_ascii=False))
PY
) || status_code=$?

status_code=${status_code:-0}
json_out "$payload"
if [[ "$status_code" -ne 0 ]]; then
  exit "$status_code"
fi
