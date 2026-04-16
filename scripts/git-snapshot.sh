#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

worktree=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --worktree) worktree="$2"; shift 2 ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

repo=$(repo_root)
worktree=${worktree:-"$repo"}
payload=$(python3 - <<'PY' "$repo" "$worktree"
import json
import subprocess
import sys
from pathlib import Path

repo = Path(sys.argv[1]).resolve()
worktree = Path(sys.argv[2]).resolve()


def run(*cmd):
    proc = subprocess.run(
        list(cmd),
        cwd=str(worktree),
        capture_output=True,
        text=True,
        check=False,
    )
    return proc.returncode, proc.stdout.strip(), proc.stderr.strip()


def run_repo(*cmd):
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
upstream_code, upstream_out, _ = run("git", "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}")

ahead = 0
behind = 0
if upstream_code == 0:
    counts_code, counts_out, _ = run("git", "rev-list", "--left-right", "--count", f"{upstream_out}...HEAD")
    if counts_code == 0 and counts_out:
        behind, ahead = [int(part) for part in counts_out.split()]

remotes_code, remotes_out, _ = run("git", "remote", "-v")
remote_urls = {}
for line in remotes_out.splitlines():
    parts = line.split()
    if len(parts) >= 3 and parts[2] == "(fetch)":
        remote_urls[parts[0]] = parts[1]

wt_code, wt_out, _ = run_repo("git", "worktree", "list", "--porcelain")
worktrees = []
current = {}
for line in wt_out.splitlines():
    if not line.strip():
        if current:
            worktrees.append(current)
            current = {}
        continue
    key, _, value = line.partition(" ")
    if key == "worktree":
        current = {"path": value}
    elif key == "HEAD":
        current["head"] = value
    elif key == "branch":
        current["branch"] = value.rsplit("/", 1)[-1]
if current:
    worktrees.append(current)

porcelain = [line for line in status_out.splitlines() if line.strip()]
payload = {
    "repo_root": str(repo),
    "worktree": str(worktree),
    "has_head": head_code == 0,
    "head": head_out if head_code == 0 else "",
    "branch": branch_out if branch_code == 0 else "",
    "upstream": upstream_out if upstream_code == 0 else "",
    "ahead": ahead,
    "behind": behind,
    "clean": status_code == 0 and len(porcelain) == 0,
    "dirty_files": [line[3:] for line in porcelain],
    "remote_urls": remote_urls,
    "known_worktrees": worktrees if wt_code == 0 else [],
}
print(json.dumps(payload, ensure_ascii=False))
PY
)
json_out "$payload"
