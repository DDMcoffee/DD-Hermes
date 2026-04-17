#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

repo=$(shared_repo_root)
landing_doc="$repo/指挥文档/06-一期PhaseDone审计.md"

payload=$(python3 - <<'PY' "$repo" "$landing_doc"
from __future__ import annotations

import json
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

repo = Path(sys.argv[1]).resolve()
landing_doc = Path(sys.argv[2]).resolve()


def read_frontmatter(path: Path) -> dict[str, str]:
    if not path.exists():
        return {}
    text = path.read_text(encoding="utf-8")
    match = re.match(r"---\n(.*?)\n---\n", text, re.S)
    if not match:
        return {}
    fields = {}
    for line in match.group(1).splitlines():
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        fields[key.strip()] = value.strip()
    return fields


def git_tracked(path: Path) -> bool:
    rel = path.relative_to(repo).as_posix()
    result = subprocess.run(
        ["git", "-C", str(repo), "ls-files", "--error-unmatch", rel],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    )
    return result.returncode == 0


def load_json(path: Path) -> dict:
    if not path.exists():
        return {}
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return {}


frontmatter = read_frontmatter(landing_doc)
latest_proof_task_id = frontmatter.get("latest_proof_task_id", "")
current_mainline_task_id = frontmatter.get("current_mainline_task_id", "")

formal_task_ids: set[str] = set()
for directory in (
    repo / "workspace" / "contracts",
    repo / "openspec" / "proposals",
    repo / "openspec" / "designs",
    repo / "openspec" / "tasks",
    repo / "openspec" / "archive",
):
    for path in directory.glob("dd-hermes-*.md"):
        if git_tracked(path):
            formal_task_ids.add(path.stem)

state_root = repo / "workspace" / "state"
archived_tasks = []
live_committed_candidates = []
local_residue = []

all_state_ids = {path.parent.name for path in state_root.glob("*/state.json")}

for task_id in sorted(formal_task_ids):
    surface_paths = {
        "contract": repo / "workspace" / "contracts" / f"{task_id}.md",
        "proposal": repo / "openspec" / "proposals" / f"{task_id}.md",
        "design": repo / "openspec" / "designs" / f"{task_id}.md",
        "task": repo / "openspec" / "tasks" / f"{task_id}.md",
        "archive": repo / "openspec" / "archive" / f"{task_id}.md",
        "state": repo / "workspace" / "state" / task_id / "state.json",
    }
    present_surfaces = [name for name, path in surface_paths.items() if path.exists()]
    tracked_surfaces = [name for name, path in surface_paths.items() if path.exists() and git_tracked(path)]
    state = load_json(surface_paths["state"])
    stage = state.get("openspec", {}).get("stage", "")
    status = state.get("status", "")
    mode = state.get("mode", "")
    archived = "archive" in tracked_surfaces or (
        status == "done" and mode == "archive"
    ) or stage == "archive"
    live_candidate = not archived and bool(
        set(tracked_surfaces) & {"contract", "proposal", "design", "task", "state"}
    )

    item = {
        "task_id": task_id,
        "status": status,
        "mode": mode,
        "stage": stage,
        "present_surfaces": present_surfaces,
        "tracked_surfaces": tracked_surfaces,
    }
    if archived:
        archived_tasks.append(item)
    elif live_candidate:
        live_committed_candidates.append(item)

for task_id in sorted(all_state_ids):
    state_path = state_root / task_id / "state.json"
    surface_paths = {
        "contract": repo / "workspace" / "contracts" / f"{task_id}.md",
        "proposal": repo / "openspec" / "proposals" / f"{task_id}.md",
        "design": repo / "openspec" / "designs" / f"{task_id}.md",
        "task": repo / "openspec" / "tasks" / f"{task_id}.md",
        "archive": repo / "openspec" / "archive" / f"{task_id}.md",
        "state": state_path,
    }
    tracked_surfaces = [name for name, path in surface_paths.items() if path.exists() and git_tracked(path)]
    if tracked_surfaces:
        continue
    local_residue.append(
        {
            "task_id": task_id,
            "present_surfaces": [name for name, path in surface_paths.items() if path.exists()],
            "tracked_surfaces": [],
            "reason": "working_tree_only_task_package",
        }
    )


reasons = []
committed_mainline = any(
    item["task_id"] == current_mainline_task_id for item in live_committed_candidates
)
if current_mainline_task_id and committed_mainline:
    verdict = "active-mainline-present"
    reasons.append("current_mainline_task_id_set")
elif current_mainline_task_id:
    verdict = "working-tree-mainline-only"
    reasons.extend(["current_mainline_task_id_set", "current_mainline_not_committed"])
elif live_committed_candidates:
    verdict = "candidate-available"
    reasons.append("live_committed_candidates_present")
else:
    verdict = "no-successor-yet"
    reasons.append("no_live_committed_candidates")

if archived_tasks:
    reasons.append("archived_dd_hermes_history_present")
if local_residue:
    reasons.append("working_tree_residue_ignored")

payload = {
    "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "latest_proof_task_id": latest_proof_task_id,
    "current_mainline_task_id": current_mainline_task_id,
    "verdict": verdict,
    "reasons": reasons,
    "live_committed_candidates": live_committed_candidates,
    "committed_candidate_count": len(live_committed_candidates),
    "local_residue": local_residue,
    "local_residue_count": len(local_residue),
    "archived_task_count": len(archived_tasks),
    "archived_tasks_sample": [item["task_id"] for item in archived_tasks[:5]],
}
print(json.dumps(payload, ensure_ascii=False))
PY
)

json_out "$payload"
