#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

max_age_days="30"
dry_run="false"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --max-age-days) max_age_days="$2"; shift 2 ;;
    --dry-run) dry_run="true"; shift ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

repo=$(repo_root)
result=$(python3 - <<'PY' "$repo" "$max_age_days"
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

repo = Path(sys.argv[1])
max_age_days = int(sys.argv[2])
now = datetime.now(timezone.utc)

candidates = []
for kind_dir in ("user", "task", "world", "self"):
    root = repo / "memory" / kind_dir
    if not root.exists():
        continue
    for path in root.rglob("*.md"):
        text = path.read_text(encoding="utf-8")
        if not text.startswith("---\n"):
            continue
        parts = text.split("---\n", 2)
        frontmatter = {}
        for line in parts[1].splitlines():
            if ":" not in line:
                continue
            key, value = line.split(":", 1)
            frontmatter[key.strip()] = value.strip().strip('"')

        if frontmatter.get("type") == "constraint":
            continue
        if frontmatter.get("status") != "active":
            continue

        validated = frontmatter.get("last_validated_at", "")
        created = frontmatter.get("created_at", "")
        ref_date = validated or created
        if not ref_date:
            continue

        try:
            ref_dt = datetime.fromisoformat(ref_date.replace("Z", "+00:00"))
            age_days = (now - ref_dt).days
        except (ValueError, TypeError):
            continue

        if age_days > max_age_days:
            confidence = 0.0
            try:
                confidence = float(frontmatter.get("confidence", "0"))
            except (ValueError, TypeError):
                pass

            candidates.append({
                "memory_id": frontmatter.get("id", path.stem),
                "path": str(path),
                "kind": kind_dir,
                "type": frontmatter.get("type", ""),
                "age_days": age_days,
                "confidence": confidence,
                "ref_date": ref_date,
            })

candidates.sort(key=lambda c: (-c["age_days"], c["confidence"]))
print(json.dumps({
    "candidates": candidates,
    "count": len(candidates),
    "max_age_days": max_age_days,
}, ensure_ascii=False))
PY
)

count=$(RESULT="$result" python3 -c 'import json,os; print(json.loads(os.environ["RESULT"])["count"])')

if [[ "$dry_run" == "true" || "$count" == "0" ]]; then
  json_out "$result"
  exit 0
fi

decayed_ids=$(RESULT="$result" python3 -c 'import json,os; [print(c["memory_id"]) for c in json.loads(os.environ["RESULT"])["candidates"]]')
decayed=0
failed=0
while IFS= read -r mid; do
  if [[ -z "$mid" ]]; then continue; fi
  if "$SCRIPT_DIR/memory-manage.sh" --mode decay --memory-ids "$mid" >/dev/null 2>&1; then
    decayed=$((decayed + 1))
  else
    failed=$((failed + 1))
  fi
done <<< "$decayed_ids"

final=$(RESULT="$result" python3 - <<'PY' "$decayed" "$failed"
import json, os, sys
r = json.loads(os.environ["RESULT"])
r["decayed"] = int(sys.argv[1])
r["failed"] = int(sys.argv[2])
print(json.dumps(r, ensure_ascii=False))
PY
)
json_out "$final"
