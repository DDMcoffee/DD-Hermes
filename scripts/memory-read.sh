#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

task_context=""
kind="all"
limit="10"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --task-context) task_context="$2"; shift 2 ;;
    --kind) kind="$2"; shift 2 ;;
    --limit) limit="$2"; shift 2 ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

case "$kind" in
  all|user|task|world|self) ;;
  *)
    json_out '{"error":"invalid kind"}'
    exit 3
    ;;
esac

repo=$(repo_root)
payload=$(python3 - <<'PY' "$repo" "$task_context" "$kind" "$limit"
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

now = datetime.now(timezone.utc)
repo = Path(sys.argv[1])
task_context = sys.argv[2].lower()
kind = sys.argv[3]
limit = int(sys.argv[4])
tokens = {token for token in task_context.replace("/", " ").replace("-", " ").split() if token}

roots = []
if kind == "all":
    roots = [repo / "memory" / name for name in ("user", "task", "world", "self")]
else:
    roots = [repo / "memory" / kind]

matches = []
for root in roots:
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
        haystack = f"{frontmatter.get('content','')} {frontmatter.get('scope','')}".lower()
        token_score = sum(1 for token in tokens if token in haystack)
        if token_score:
            constraint_bonus = 100 if frontmatter.get("type") == "constraint" else 0
            confidence = 0.0
            try:
                confidence = float(frontmatter.get("confidence", "0"))
            except (ValueError, TypeError):
                pass
            confidence_bonus = confidence * 10

            recency_bonus = 0.0
            validated_at = frontmatter.get("last_validated_at", "")
            created_at = frontmatter.get("created_at", "")
            ref_date = validated_at or created_at
            if ref_date:
                try:
                    ref_dt = datetime.fromisoformat(ref_date.replace("Z", "+00:00"))
                    age_days = (now - ref_dt).days
                    if age_days <= 7:
                        recency_bonus = 5.0
                    elif age_days <= 30:
                        recency_bonus = 2.0
                except (ValueError, TypeError):
                    pass

            score = token_score + constraint_bonus + confidence_bonus + recency_bonus
            matches.append({
                "memory_id": frontmatter.get("id"),
                "path": str(path),
                "score": score,
                "token_score": token_score,
                "confidence": confidence,
                "recency_bonus": recency_bonus,
                "type": frontmatter.get("type"),
                "status": frontmatter.get("status"),
            })

matches.sort(key=lambda item: (-item["score"], item["memory_id"] or ""))
selected = matches[:limit]
journal_conflicts = []
for journal in (repo / "memory" / "journal").glob("*.jsonl"):
    for line in journal.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        event = json.loads(line)
        if event.get("op") != "conflict":
            continue
        if any(event.get("memory_id") == item.get("memory_id") for item in selected):
            journal_conflicts.append(event)
print(json.dumps({
    "matches": selected,
    "scored_candidates": matches,
    "conflicts": journal_conflicts,
    "expired": [item for item in selected if item.get("status") == "expired"],
    "explanation": "constraint-first lexical match weighted by confidence and recency",
}, ensure_ascii=False))
PY
)
json_out "$payload"
