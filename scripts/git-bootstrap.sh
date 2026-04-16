#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

commit_message="repo: initialize managed baseline"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --commit-message) commit_message="$2"; shift 2 ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

repo=$(repo_root)
if git -C "$repo" rev-parse --verify HEAD >/dev/null 2>&1; then
  payload=$(python3 - <<'PY' "$repo"
import json
import subprocess
import sys

repo = sys.argv[1]
commit = subprocess.check_output(["git", "-C", repo, "rev-parse", "HEAD"], text=True).strip()
print(json.dumps({
    "repo_root": repo,
    "bootstrapped": False,
    "has_head": True,
    "commit": commit,
    "message": "repository already has a baseline commit",
}, ensure_ascii=False))
PY
)
  json_out "$payload"
  exit 0
fi

git -C "$repo" add .
git -C "$repo" -c user.name=Codex -c user.email=codex@local commit -m "$commit_message" >/dev/null

payload=$(python3 - <<'PY' "$repo" "$commit_message"
import json
import subprocess
import sys

repo = sys.argv[1]
commit_message = sys.argv[2]
commit = subprocess.check_output(["git", "-C", repo, "rev-parse", "HEAD"], text=True).strip()
print(json.dumps({
    "repo_root": repo,
    "bootstrapped": True,
    "has_head": True,
    "commit": commit,
    "commit_message": commit_message,
}, ensure_ascii=False))
PY
)
json_out "$payload"
