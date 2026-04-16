#!/usr/bin/env bash

set -euo pipefail
export PYTHONDONTWRITEBYTECODE=1

repo_root() {
  if [[ -n "${REPO_ROOT:-}" ]]; then
    printf '%s\n' "$REPO_ROOT"
    return
  fi

  local common_dir candidate
  common_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
  candidate=$(cd "$common_dir/.." && pwd)
  if git -C "$candidate" rev-parse --show-toplevel >/dev/null 2>&1; then
    git -C "$candidate" rev-parse --show-toplevel
  else
    git rev-parse --show-toplevel 2>/dev/null || pwd
  fi
}

shared_repo_root() {
  if [[ -n "${REPO_ROOT:-}" ]]; then
    printf '%s\n' "$REPO_ROOT"
    return
  fi

  local common_dir candidate common_git
  common_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
  candidate=$(cd "$common_dir/.." && pwd)
  if common_git=$(git -C "$candidate" rev-parse --git-common-dir 2>/dev/null); then
    if [[ "$common_git" != /* ]]; then
      common_git=$(cd "$candidate" && cd "$common_git" && pwd)
    fi
    printf '%s\n' "$(cd "$common_git/.." && pwd)"
  else
    repo_root
  fi
}

timestamp_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

today_utc() {
  date -u +"%Y-%m-%d"
}

read_stdin_json() {
  if [ -t 0 ]; then
    printf '{}'
  else
    local content
    content=$(cat)
    if [[ -z "$content" ]]; then
      printf '{}'
    else
      printf '%s' "$content"
    fi
  fi
}

json_out() {
  local payload="$1"
  PAYLOAD="$payload" python3 - <<'PY'
import json
import os
import sys

payload = os.environ.get("PAYLOAD", "{}")
json.dump(json.loads(payload), sys.stdout, ensure_ascii=False)
sys.stdout.write("\n")
PY
}

abs_path() {
  python3 - "$1" <<'PY'
import os
import sys

print(os.path.abspath(sys.argv[1]))
PY
}

slugify() {
  python3 - "$1" <<'PY'
import re
import sys

value = sys.argv[1].strip().lower()
value = re.sub(r"[^a-z0-9._-]+", "-", value)
value = re.sub(r"-{2,}", "-", value).strip("-")
print(value or "item")
PY
}

update_frontmatter_field() {
  local path="$1"
  local field="$2"
  local value="$3"
  python3 - "$path" "$field" "$value" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
field = sys.argv[2]
value = sys.argv[3]
text = path.read_text(encoding="utf-8")
if not text.startswith("---\n"):
    raise SystemExit(1)
parts = text.split("---\n", 2)
frontmatter = parts[1].splitlines()
rest = parts[2]
updated = []
found = False
for line in frontmatter:
    if line.startswith(f"{field}:"):
        updated.append(f"{field}: {value}")
        found = True
    else:
        updated.append(line)
if not found:
    updated.append(f"{field}: {value}")
path.write_text("---\n" + "\n".join(updated) + "\n---\n" + rest, encoding="utf-8")
PY
}

append_journal_line() {
  local journal_path="$1"
  local payload="$2"
  mkdir -p "$(dirname "$journal_path")"
  printf '%s\n' "$payload" >> "$journal_path"
}
