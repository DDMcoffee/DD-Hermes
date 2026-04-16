#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../scripts/common.sh
source "$SCRIPT_DIR/../scripts/common.sh"

event="event"
title=""
body=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --event) event="$2"; shift 2 ;;
    --title) title="$2"; shift 2 ;;
    --body) body="$2"; shift 2 ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

payload=$(python3 - <<'PY' "$event" "$title" "$body"
import json
import sys

event, title, body = sys.argv[1:]
print(json.dumps({
    "event": event,
    "title": title,
    "body": body,
    "delivered": False,
    "transport": "stdout",
    "fallback_used": True,
}, ensure_ascii=False))
PY
)
json_out "$payload"
exit 0

