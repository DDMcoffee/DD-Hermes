#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

date_value="${1:-$(today_utc)}"
repo=$(repo_root)
payload=$(python3 - <<'PY' "$repo" "$date_value"
import json
import sys
from pathlib import Path

repo = Path(sys.argv[1]).resolve()
date_value = sys.argv[2]
entries_dir = repo / "docs" / "textbook" / "entries"
daily_dir = repo / "docs" / "textbook" / "daily"
daily_dir.mkdir(parents=True, exist_ok=True)
summary_path = daily_dir / f"{date_value}.md"
entries = sorted(entries_dir.glob("*.md")) if entries_dir.exists() else []

body = [
    "# Daily Textbook Summary",
    "",
    "## Date",
    "",
    f"- {date_value}",
    "",
    "## New Material",
    "",
]
if entries:
    for path in entries[-5:]:
        body.append(f"- {path.stem}")
else:
    body.append("- None")
body.extend([
    "",
    "## Confirmed Patterns",
    "",
    "- Fill from today's main-thread conclusions.",
    "",
    "## Key Input Links",
    "",
    "- Fill from today's linked materials.",
    "",
    "## Open Gaps",
    "",
    "- Fill unresolved teaching gaps here.",
    "",
    "## Next Chapter",
    "",
    "- Fill the next lesson target here.",
    "",
])
summary_path.write_text("\n".join(body), encoding="utf-8")
print(json.dumps({"summary_path": str(summary_path), "entry_count": len(entries)}, ensure_ascii=False))
PY
)
json_out "$payload"
