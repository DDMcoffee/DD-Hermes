#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

task_id=""
owner="lead"
experts=""
status="initialized"
mode="planning"
current_focus="bootstrap"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --task-id) task_id="$2"; shift 2 ;;
    --owner) owner="$2"; shift 2 ;;
    --experts) experts="$2"; shift 2 ;;
    --status) status="$2"; shift 2 ;;
    --mode) mode="$2"; shift 2 ;;
    --current-focus) current_focus="$2"; shift 2 ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

if [[ -z "$task_id" ]]; then
  json_out '{"error":"task_id is required"}'
  exit 3
fi

repo=$(repo_root)
payload=$(python3 - <<'PY' "$repo" "$task_id" "$owner" "$experts" "$status" "$mode" "$current_focus"
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

repo = Path(sys.argv[1]).resolve()
task_id = sys.argv[2]
owner = sys.argv[3]
experts_csv = sys.argv[4]
status = sys.argv[5]
mode = sys.argv[6]
current_focus = sys.argv[7]
timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

state_dir = repo / "workspace" / "state" / task_id
state_dir.mkdir(parents=True, exist_ok=True)
state_path = state_dir / "state.json"
events_path = state_dir / "events.jsonl"
contract_path = repo / "workspace" / "contracts" / f"{task_id}.md"
handoff_paths = sorted(str(path) for path in (repo / "workspace" / "handoffs").glob(f"{task_id}-*.md"))
exploration_paths = sorted(str(path) for path in (repo / "workspace" / "exploration").glob(f"*{task_id}*.md"))
openspec = {
    "stage": "proposal",
    "proposal_path": str(repo / "openspec" / "proposals" / f"{task_id}.md") if (repo / "openspec" / "proposals" / f"{task_id}.md").exists() else "",
    "design_path": str(repo / "openspec" / "designs" / f"{task_id}.md") if (repo / "openspec" / "designs" / f"{task_id}.md").exists() else "",
    "task_path": str(repo / "openspec" / "tasks" / f"{task_id}.md") if (repo / "openspec" / "tasks" / f"{task_id}.md").exists() else "",
    "archive_path": str(repo / "openspec" / "archive" / f"{task_id}.md") if (repo / "openspec" / "archive" / f"{task_id}.md").exists() else "",
}


def parse_frontmatter(path: Path):
    if not path.exists():
        return {}
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        return {}
    lines = text.split("---\n", 2)[1].splitlines()
    data = {}
    current = None
    for line in lines:
        if not line.strip():
            continue
        if line.startswith("  - ") and current:
            data.setdefault(current, []).append(line[4:].strip().strip('"'))
            continue
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        key = key.strip()
        value = value.strip()
        if value:
            data[key] = value.strip('"')
            current = None
        else:
            data[key] = []
            current = key
    return data


contract_frontmatter = parse_frontmatter(contract_path)
memory_reads = contract_frontmatter.get("memory_reads", [])
memory_writes = contract_frontmatter.get("memory_writes", [])
experts = [item.strip() for item in experts_csv.split(",") if item.strip()]
if not experts:
    experts = contract_frontmatter.get("experts", [])
if not experts:
    experts = [path.split("-to-")[-1].removesuffix(".md") for path in handoff_paths]

created = not state_path.exists()
if state_path.exists():
    state = json.loads(state_path.read_text(encoding="utf-8"))
else:
    state = {
        "state_version": 1,
        "created_at": timestamp,
        "git": {
            "baseline_commit": "",
            "latest_commit": "",
            "latest_branch": "",
            "latest_upstream": "",
            "latest_remote_urls": {},
        },
        "verification": {
            "last_pass": False,
            "last_run_at": "",
            "verified_steps": [],
            "verified_files": [],
        },
        "runtime": {
            "preferred_surface": "repo-first",
            "worktree_strategy": "isolated",
            "last_context_path": "",
            "last_runtime_report_path": "",
            "last_worktree_path": "",
        },
        "lease": {
            "goal": "",
            "status": "idle",
            "duration_hours": 0,
            "started_at": "",
            "deadline_at": "",
            "paused_at": "",
            "pause_reason": "",
            "resume_after": "",
            "resume_checkpoint": "",
            "dispatch_cursor": "",
        },
        "memory": {
            "reads": [],
            "writes": [],
            "last_selected_ids": [],
        },
        "notes": [],
    }

if openspec["archive_path"]:
    openspec["stage"] = "archive"
elif openspec["task_path"]:
    openspec["stage"] = "task"
elif openspec["design_path"]:
    openspec["stage"] = "design"

state.update({
    "task_id": task_id,
    "status": state.get("status", status) if not created else status,
    "mode": state.get("mode", mode) if not created else mode,
    "current_focus": state.get("current_focus", current_focus) if not created else current_focus,
    "owner": contract_frontmatter.get("owner") or state.get("owner") or owner,
    "experts": experts,
    "active_expert": state.get("active_expert", ""),
    "blocked_reason": state.get("blocked_reason", ""),
    "contract_path": str(contract_path) if contract_path.exists() else "",
    "handoff_paths": handoff_paths,
    "exploration_paths": exploration_paths,
    "openspec": {
        **state.get("openspec", {}),
        **openspec,
    },
    "updated_at": timestamp,
})
state["memory"]["reads"] = memory_reads
state["memory"]["writes"] = memory_writes

state_path.write_text(json.dumps(state, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
event = {
    "event_id": f"{task_id}:{timestamp}:{'state-init' if created else 'state-refresh'}",
    "task_id": task_id,
    "op": "state_init" if created else "state_refresh",
    "timestamp": timestamp,
    "status": state["status"],
    "mode": state["mode"],
    "actor": "state-init",
}
with events_path.open("a", encoding="utf-8") as fh:
    fh.write(json.dumps(event, ensure_ascii=False) + "\n")

print(json.dumps({
    "state_path": str(state_path),
    "events_path": str(events_path),
    "created": created,
    "status": state["status"],
    "mode": state["mode"],
}, ensure_ascii=False))
PY
)
json_out "$payload"
