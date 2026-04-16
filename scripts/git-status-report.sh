#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

repo=$(repo_root)
payload=$(python3 - <<'PY' "$repo"
import json
import subprocess
import sys
from pathlib import Path

repo = Path(sys.argv[1]).resolve()


def run(*cmd):
    proc = subprocess.run(
        list(cmd),
        cwd=str(repo),
        capture_output=True,
        text=True,
        check=False,
    )
    return proc.returncode, proc.stdout.strip(), proc.stderr.strip()


head_code, head_out, _ = run("git", "rev-parse", "--verify", "HEAD")
branch_code, branch_out, _ = run("git", "branch", "--show-current")
status_code, status_out, _ = run("git", "status", "--porcelain")
wt_code, wt_out, _ = run("git", "worktree", "list", "--porcelain")

entries = []
current = {}
for line in wt_out.splitlines():
    if not line.strip():
        if current:
            entries.append(current)
            current = {}
        continue
    key, _, value = line.partition(" ")
    if key == "worktree":
        current = {"path": value}
    elif key == "branch":
        current["branch"] = value.rsplit("/", 1)[-1]
    elif key == "HEAD":
        current["head"] = value
if current:
    entries.append(current)

porcelain = [line for line in status_out.splitlines() if line.strip()]
staged = [line[3:] for line in porcelain if line[:2].strip() and not line.startswith("??")]
unstaged = [line[3:] for line in porcelain if line[1] != " "]
untracked = [line[3:] for line in porcelain if line.startswith("??")]

has_head = head_code == 0
payload = {
    "repo_root": str(repo),
    "has_head": has_head,
    "head": head_out if has_head else "",
    "branch": branch_out if branch_code == 0 else "",
    "clean": status_code == 0 and len(porcelain) == 0,
    "staged_files": staged,
    "unstaged_files": unstaged,
    "untracked_files": untracked,
    "worktrees": entries if wt_code == 0 else [],
    "bootstrap_required": not has_head,
    "can_create_worktree": has_head,
    "next_actions": (
        ["scripts/git-bootstrap.sh --commit-message 'repo: initialize managed baseline'"]
        if not has_head
        else []
    ),
}
print(json.dumps(payload, ensure_ascii=False))
PY
)
json_out "$payload"
