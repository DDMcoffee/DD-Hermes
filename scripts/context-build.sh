#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

task_id=""
worktree=""
agent_role="commander"
memory_limit="8"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --task-id) task_id="$2"; shift 2 ;;
    --worktree) worktree="$2"; shift 2 ;;
    --agent-role) agent_role="$2"; shift 2 ;;
    --memory-limit) memory_limit="$2"; shift 2 ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

if [[ -z "$task_id" ]]; then
  json_out '{"error":"task_id is required"}'
  exit 3
fi

repo=$(repo_root)
contract_path="$repo/workspace/contracts/$task_id.md"
if [[ ! -f "$contract_path" ]]; then
  json_out '{"error":"missing sprint contract","blocked":true}'
  exit 2
fi

worktree=${worktree:-"$repo"}
if [[ ! -f "$repo/workspace/state/$task_id/state.json" ]]; then
  "$SCRIPT_DIR/state-init.sh" --task-id "$task_id" >/dev/null
fi

runtime_json=$("$SCRIPT_DIR/runtime-report.sh" --task-id "$task_id" --worktree "$worktree" --agent-role "$agent_role")
state_json=$("$SCRIPT_DIR/state-read.sh" --task-id "$task_id")

payload=$(RUNTIME_JSON="$runtime_json" STATE_JSON="$state_json" python3 - <<'PY' "$repo" "$task_id" "$agent_role" "$memory_limit"
import json
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

repo = Path(sys.argv[1]).resolve()
task_id = sys.argv[2]
agent_role = sys.argv[3]
memory_limit = sys.argv[4]
runtime = json.loads(os.environ["RUNTIME_JSON"])
state_wrapper = json.loads(os.environ["STATE_JSON"])
state = state_wrapper["state"]
timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
state_dir = repo / "workspace" / "state" / task_id
state_path = state_dir / "state.json"
events_path = state_dir / "events.jsonl"
runtime_path = state_dir / "runtime.json"
context_path = state_dir / "context.json"


def read_doc(path: Path):
    if not path or not path.exists():
        return None
    return {"path": str(path), "text": path.read_text(encoding="utf-8")}


contract = read_doc(repo / "workspace" / "contracts" / f"{task_id}.md")
handoffs = [read_doc(path) for path in sorted((repo / "workspace" / "handoffs").glob(f"{task_id}-*.md"))]
handoffs = [item for item in handoffs if item]
exploration = [read_doc(path) for path in sorted((repo / "workspace" / "exploration").glob(f"*{task_id}*.md"))]
exploration = [item for item in exploration if item]
openspec = {
    "proposal": read_doc(repo / "openspec" / "proposals" / f"{task_id}.md"),
    "design": read_doc(repo / "openspec" / "designs" / f"{task_id}.md"),
    "task": read_doc(repo / "openspec" / "tasks" / f"{task_id}.md"),
    "archive": read_doc(repo / "openspec" / "archive" / f"{task_id}.md"),
}

seed_parts = [task_id]
for doc in [contract, *handoffs, *exploration, *[item for item in openspec.values() if item]]:
    seed_parts.append(doc["text"])
seed = "\n".join(seed_parts)[:12000]

memory_proc = subprocess.run(
    [
        str(repo / "scripts" / "memory-read.sh"),
        "--task-context",
        seed,
        "--kind",
        "all",
        "--limit",
        memory_limit,
    ],
    capture_output=True,
    text=True,
    check=True,
)
memory = json.loads(memory_proc.stdout)
selected_ids = [item.get("memory_id") for item in memory.get("matches", []) if item.get("memory_id")]

runtime_path.write_text(json.dumps(runtime, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
packet = {
    "task_id": task_id,
    "agent_role": agent_role,
    "generated_at": timestamp,
    "sources": {
        "contract_path": contract["path"] if contract else "",
        "handoff_paths": [item["path"] for item in handoffs],
        "exploration_paths": [item["path"] for item in exploration],
        "state_path": str(state_path),
        "runtime_path": str(runtime_path),
        "openspec": {name: item["path"] if item else "" for name, item in openspec.items()},
    },
    "runtime": runtime,
    "state": state,
    "memory": memory,
    "continuation": {
        "goal": state.get("lease", {}).get("goal", ""),
        "lease": state.get("lease", {}),
        "current_focus": state.get("current_focus", ""),
        "active_expert": state.get("active_expert", ""),
        "blocked_reason": state.get("blocked_reason", ""),
    },
    "documents": {
        "contract": contract,
        "handoffs": handoffs,
        "exploration": exploration,
        "openspec": openspec,
    },
    "context_summary": {
        "memory_ids": selected_ids,
        "handoff_count": len(handoffs),
        "exploration_count": len(exploration),
        "has_design": bool(openspec["design"]),
        "has_task": bool(openspec["task"]),
        "lease_status": state.get("lease", {}).get("status", ""),
        "resume_checkpoint": state.get("lease", {}).get("resume_checkpoint", ""),
    },
}
context_path.write_text(json.dumps(packet, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

state.setdefault("runtime", {})
state["runtime"]["last_context_path"] = str(context_path)
state["runtime"]["last_runtime_report_path"] = str(runtime_path)
state.setdefault("memory", {})
state["memory"]["last_selected_ids"] = selected_ids
state["updated_at"] = timestamp
state_path.write_text(json.dumps(state, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

event = {
    "event_id": f"{task_id}:{timestamp}:context-build",
    "task_id": task_id,
    "op": "context_build",
    "timestamp": timestamp,
    "context_path": str(context_path),
    "runtime_path": str(runtime_path),
    "memory_ids": selected_ids,
    "actor": "context-build",
}
with events_path.open("a", encoding="utf-8") as fh:
    fh.write(json.dumps(event, ensure_ascii=False) + "\n")

print(json.dumps({
    "context_path": str(context_path),
    "runtime_path": str(runtime_path),
    "state_path": str(state_path),
    "memory_count": len(memory.get("matches", [])),
    "handoff_count": len(handoffs),
    "exploration_count": len(exploration),
}, ensure_ascii=False))
PY
)
json_out "$payload"
