#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

topic=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --topic) topic="$2"; shift 2 ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

input_json=$(read_stdin_json)
repo=$(repo_root)
payload=$(INPUT_JSON="$input_json" python3 - <<'PY' "$repo" "$topic"
import json
import os
import sys
from pathlib import Path

repo = Path(sys.argv[1]).resolve()
topic = sys.argv[2]
data = json.loads(os.environ.get("INPUT_JSON", "{}"))
entries_dir = repo / "docs" / "textbook" / "entries"
entries_dir.mkdir(parents=True, exist_ok=True)

title = topic or data.get("topic") or "codex-lesson"
slug = title.lower().replace(" ", "-").replace("/", "-")
path = entries_dir / f"{slug}.md"
links = data.get("links", [])

body = "\n".join([
    "# Textbook Entry",
    "",
    "## Date",
    "",
    f"- {data.get('date', '')}",
    "",
    "## Topic",
    "",
    f"- {title}",
    "",
    "## User Experience",
    "",
    f"- {data.get('experience', '')}",
    "",
    "## Input Links",
    "",
    *([f"- {link}" for link in links] or ["- None"]),
    "",
    "## Conclusions",
    "",
    f"- {data.get('conclusions', '')}",
    "",
    "## Patterns",
    "",
    f"- {data.get('patterns', '')}",
    "",
    "## Next Lesson",
    "",
    f"- {data.get('next_lesson', '')}",
    "",
])
path.write_text(body, encoding="utf-8")
print(json.dumps({"entry_path": str(path)}, ensure_ascii=False))
PY
)
json_out "$payload"
