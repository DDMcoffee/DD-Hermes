#!/usr/bin/env bash

set -euo pipefail

SOURCE_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SECTION="${1:-all}"
TMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/hermes-harness-smoke.XXXXXX")
ROOT="$TMP_ROOT/repo"

cleanup() {
  rm -rf "$TMP_ROOT"
}

create_fixture() {
  python3 - "$SOURCE_ROOT" "$ROOT" <<'PY'
import shutil
import sys
from pathlib import Path

source = Path(sys.argv[1])
target = Path(sys.argv[2])

def ignore(path, names):
    ignored = {".git", ".worktrees", "__pycache__"}
    current = Path(path)
    if current == source:
        ignored.add("workspace")
    if current == source / "memory":
        ignored.add("journal")
    return ignored.intersection(names)

shutil.copytree(source, target, ignore=ignore, copy_function=shutil.copy2)
PY
  git -C "$ROOT" init >/dev/null
  git -C "$ROOT" add . >/dev/null
  git -C "$ROOT" -c user.name=Codex -c user.email=codex@local commit -m "smoke fixture" >/dev/null
}

trap cleanup EXIT
create_fixture

assert_json_field() {
  local json="$1"
  local expr="$2"
  JSON_INPUT="$json" EXPR="$expr" python3 - <<'PY'
import json
import os

data = json.loads(os.environ["JSON_INPUT"])
expr = os.environ["EXPR"]
value = eval(expr, {"__builtins__": {}}, {"data": data, "len": len, "any": any, "all": all})
if not value:
    raise SystemExit(1)
PY
}

run_hooks() {
  local blocked
  set +e
  blocked=$("$ROOT/hooks/guard-dangerous-ops.sh" --event PreToolUse --tool shell <<'EOF'
{"command":"rm -fr output"}
EOF
)
  local status=$?
  set -e
  [[ $status -eq 2 ]]
  assert_json_field "$blocked" "data['allow'] is False and data['matched_rule'] == 'rm -rf'"

  local allowed
  allowed=$("$ROOT/hooks/guard-dangerous-ops.sh" --event PreToolUse --tool shell <<'EOF'
{"command":"ls -la"}
EOF
)
  assert_json_field "$allowed" "data['allow'] is True"

  local typecheck
  typecheck=$(HOOKS_FAKE_TYPECHECK=1 "$ROOT/hooks/post-edit-typecheck.sh" --event PostToolUse --file sample.ts)
  assert_json_field "$typecheck" "data['triggered'] is True and data['checker'] == 'tsc --noEmit' and data['mode'] == 'fake' and data['exit_code'] == 0"

  local skipped
  skipped=$("$ROOT/hooks/post-edit-typecheck.sh" --event PostToolUse --file README.md)
  assert_json_field "$skipped" "data['triggered'] is False"

  set +e
  "$ROOT/hooks/quality-gate.sh" --event Stop <<'EOF' >/dev/null
{"changed_code_files":["scripts/x.sh"],"verified_steps":[],"last_test_exit_code":1}
EOF
  status=$?
  set -e
  [[ $status -eq 2 ]]

  "$ROOT/hooks/quality-gate.sh" --event Stop <<'EOF' >/dev/null
{"changed_code_files":["scripts/x.sh"],"verified_steps":["tests/smoke.sh","coverage:all"],"verified_files":["scripts/x.sh"],"last_test_exit_code":0}
EOF

  local session_log
  session_log=$("$ROOT/hooks/session-end-log.sh" --session-id smoke <<'EOF'
{"tool_counts":{"shell":3},"error_counts":{"guard":1},"file_changes":["README.md"],"verification_events":["smoke"],"fragmentation_signals":{"count":0}}
EOF
)
  assert_json_field "$session_log" "data['log_file'].endswith('.jsonl')"
}

run_memory() {
  local first
  first=$("$ROOT/scripts/memory-write.sh" --kind user --id smoke-belief <<'EOF'
{"type":"belief","content":"Prefer Plotly for dashboard reviews.","source":"test","scope":"data-viz dashboard","confidence":"0.7","status":"active"}
EOF
)
  assert_json_field "$first" "data['deduped'] is False and data['blocked'] is False"

  local conflict
  conflict=$("$ROOT/scripts/memory-write.sh" --kind user --id smoke-belief <<'EOF'
{"type":"belief","content":"Prefer Matplotlib for paper charts.","source":"test","scope":"data-viz papers","confidence":"0.6","status":"active"}
EOF
)
  assert_json_field "$conflict" "len(data['conflicts']) == 1"

  "$ROOT/scripts/memory-write.sh" --kind world --id smoke-constraint <<'EOF' >/dev/null
{"type":"constraint","content":"Never rewrite policy through memory.","source":"test","scope":"policy","confidence":"1.0","status":"active"}
EOF

  set +e
  "$ROOT/scripts/memory-write.sh" --kind world --id smoke-constraint-alt <<'EOF' >/dev/null
{"type":"constraint","content":"Rewrite policy through memory.","source":"test","scope":"policy","confidence":"1.0","status":"active"}
EOF
  local status=$?
  set -e
  [[ $status -eq 2 ]]

  local read_result
  read_result=$("$ROOT/scripts/memory-read.sh" --task-context "plotly dashboard data-viz" --kind all --limit 5)
  assert_json_field "$read_result" "len(data['matches']) >= 1 and len(data['conflicts']) >= 1"

  local views
  views=$("$ROOT/scripts/memory-refresh-views.sh")
  assert_json_field "$views" "data['card_count'] >= 1 and data['conflict_count'] >= 1"

  "$ROOT/scripts/memory-manage.sh" --mode validate <<'EOF' >/dev/null
{"memory_ids":["smoke-belief"],"reason":"smoke validate"}
EOF

  set +e
  "$ROOT/scripts/memory-manage.sh" --mode archive <<'EOF' >/dev/null
{"memory_ids":["smoke-constraint"],"reason":"should reject"}
EOF
  status=$?
  set -e
  [[ $status -eq 2 ]]
}

run_workflow() {
  set +e
  "$ROOT/scripts/spec-first.sh" --task-id smoke-sprint --changed-files a,b,c >/dev/null
  local status=$?
  set -e
  [[ $status -eq 2 ]]

  "$ROOT/scripts/sprint-init.sh" --task-id smoke-sprint --owner lead --experts expert-a,expert-b,expert-c >/dev/null
  [[ -f "$ROOT/workspace/contracts/smoke-sprint.md" ]]
  grep -q "## Required Fields" "$ROOT/workspace/contracts/smoke-sprint.md"
  grep -q "## Open Questions" "$ROOT/workspace/contracts/smoke-sprint.md"
  ! grep -q "sprint-000" "$ROOT/workspace/contracts/smoke-sprint.md"
  [[ -f "$ROOT/workspace/exploration/exploration-lead-smoke-sprint.md" ]]
  grep -q "## Evidence" "$ROOT/workspace/exploration/exploration-lead-smoke-sprint.md"
  [[ -f "$ROOT/openspec/proposals/smoke-sprint.md" ]]
  grep -q "## Verification" "$ROOT/openspec/proposals/smoke-sprint.md"
  [[ -f "$ROOT/workspace/state/smoke-sprint/state.json" ]]
  grep -q "## Acceptance" "$ROOT/workspace/handoffs/smoke-sprint-lead-to-expert-a.md"
  ! grep -q "subsystem-or-slice" "$ROOT/workspace/handoffs/smoke-sprint-lead-to-expert-a.md"
  ! grep -q "TBD" "$ROOT/workspace/handoffs/smoke-sprint-lead-to-expert-a.md"
  [[ -f "$ROOT/workspace/closeouts/smoke-sprint-expert-a.md" ]]
  grep -q "## Completion" "$ROOT/workspace/closeouts/smoke-sprint-expert-a.md"
  ! grep -q "sprint-000" "$ROOT/workspace/closeouts/smoke-sprint-expert-a.md"

  "$ROOT/scripts/spec-first.sh" --task-id smoke-sprint --changed-files a,b,c >/dev/null
  "$ROOT/scripts/openspec-init.sh" --task-id smoke-sprint --stage design >/dev/null
  "$ROOT/scripts/openspec-init.sh" --task-id smoke-sprint --stage task >/dev/null

  local create
  create=$("$ROOT/scripts/worktree-create.sh" --task-id smoke-sprint --expert expert-a)
  assert_json_field "$create" "data['worktree_path'].endswith('smoke-sprint-expert-a')"

  local status_out
  status_out=$("$ROOT/scripts/worktree-status.sh" --task-id smoke-sprint)
  assert_json_field "$status_out" "'smoke-sprint.md' in data['linked_contract'] and 'smoke-sprint' in data['linked_handoff']"

  local status_from_worktree
  status_from_worktree=$(cd "$ROOT/.worktrees/smoke-sprint-expert-a" && ./scripts/worktree-status.sh --task-id smoke-sprint)
  assert_json_field "$status_from_worktree" "'smoke-sprint.md' in data['linked_contract'] and data['clean'] is True"
}

run_dispatch() {
  "$ROOT/scripts/state-update.sh" --task-id smoke-sprint <<'EOF' >/dev/null
{"supervisors":["lead"],"executors":["expert-a","expert-b"],"skeptics":["expert-c"],"note":"dispatch independent skeptic fixture"}
EOF

  local dispatch
  dispatch=$("$ROOT/scripts/dispatch-create.sh" --task-id smoke-sprint)
  assert_json_field "$dispatch" "data['task_id'] == 'smoke-sprint' and data['summary']['supervisor_count'] >= 1 and data['summary']['executor_count'] >= 2 and data['summary']['skeptic_count'] >= 1"
  assert_json_field "$dispatch" "len([item for item in data['assignments'] if item['role'] == 'supervisor']) >= 1 and len([item for item in data['assignments'] if item['role'] == 'executor']) >= 2 and len([item for item in data['assignments'] if item['role'] == 'skeptic']) >= 1"
  assert_json_field "$dispatch" "all(item['next_commands'] for item in data['assignments']) and all(item['artifacts']['context_path'].endswith('context.json') for item in data['assignments'])"
  assert_json_field "$dispatch" "all(item['handoff_path'].endswith('.md') for item in data['assignments'] if item['role'] == 'executor') and any(item['status'] in ('created', 'existing') for item in data['assignments'] if item['role'] == 'executor')"
  assert_json_field "$dispatch" "data['independent_skeptic'] is True and data['degraded'] is False and data['role_conflicts'] == []"

  "$ROOT/scripts/state-update.sh" --task-id smoke-sprint <<'EOF' >/dev/null
{"skeptics":["lead"],"note":"dispatch degraded skeptic fixture"}
EOF

  local degraded
  degraded=$("$ROOT/scripts/dispatch-create.sh" --task-id smoke-sprint)
  assert_json_field "$degraded" "data['independent_skeptic'] is False and data['degraded'] is True"
  assert_json_field "$degraded" "'supervisor_skeptic_overlap:lead' in data['role_conflicts'] and 'independent_skeptic_unavailable' in data['scale_out_triggers']"
}

run_git_management() {
  local report
  report=$("$ROOT/scripts/git-status-report.sh")
  assert_json_field "$report" "data['has_head'] is True and data['can_create_worktree'] is True"

  local snapshot
  snapshot=$("$ROOT/scripts/git-snapshot.sh")
  assert_json_field "$snapshot" "data['has_head'] is True and 'remote_urls' in data and 'known_worktrees' in data"

  printf 'hello\n' > "$ROOT/.worktrees/smoke-sprint-expert-a/NOTE.txt"
  local task_commit
  task_commit=$(cd "$ROOT/.worktrees/smoke-sprint-expert-a" && ./scripts/git-commit-task.sh --task-id smoke-sprint --message "task(smoke-sprint): expert-a slice")
  assert_json_field "$task_commit" "data['task_id'] == 'smoke-sprint' and len(data['commit_sha']) == 40"

  local state_after_commit
  state_after_commit=$("$ROOT/scripts/state-read.sh" --task-id smoke-sprint)
  assert_json_field "$state_after_commit" "len(data['state']['git']['latest_commit']) == 40 and data['state']['git']['latest_branch'] == 'smoke-sprint-expert-a'"

  local removal
  removal=$("$ROOT/scripts/worktree-remove.sh" --task-id smoke-sprint --expert expert-a --delete-branch)
  assert_json_field "$removal" "data['removed_worktree'].endswith('smoke-sprint-expert-a') and data['deleted_branch'] is True"

  local bootstrap_root="$TMP_ROOT/bootstrap"
  python3 - "$SOURCE_ROOT" "$bootstrap_root" <<'PY'
import shutil
import sys
from pathlib import Path

source = Path(sys.argv[1])
target = Path(sys.argv[2])

def ignore(path, names):
    ignored = {".git", ".worktrees", "__pycache__"}
    current = Path(path)
    if current == source:
        ignored.add("workspace")
    if current == source / "memory":
        ignored.add("journal")
    return ignored.intersection(names)

shutil.copytree(source, target, ignore=ignore, copy_function=shutil.copy2)
PY
  git -C "$bootstrap_root" init >/dev/null

  local before
  before=$("$bootstrap_root/scripts/git-status-report.sh")
  assert_json_field "$before" "data['has_head'] is False and data['bootstrap_required'] is True"

  local bootstrapped
  bootstrapped=$("$bootstrap_root/scripts/git-bootstrap.sh" --commit-message "repo: initialize managed baseline")
  assert_json_field "$bootstrapped" "data['bootstrapped'] is True and data['has_head'] is True"
}

run_context_state() {
  if [[ ! -d "$ROOT/.worktrees/smoke-sprint-expert-a" ]]; then
    "$ROOT/scripts/worktree-create.sh" --task-id smoke-sprint --expert expert-a >/dev/null
  fi

  local runtime
  runtime=$("$ROOT/scripts/runtime-report.sh" --task-id smoke-sprint --agent-role commander)
  assert_json_field "$runtime" "'PreToolUse' in data['hooks']['events'] and data['task_surfaces']['state_path'].endswith('state.json')"

  local context
  context=$("$ROOT/scripts/context-build.sh" --task-id smoke-sprint --agent-role commander --memory-limit 5)
  assert_json_field "$context" "data['context_path'].endswith('context.json') and data['runtime_path'].endswith('runtime.json') and data['memory_count'] >= 1"

  local state
  state=$("$ROOT/scripts/state-read.sh" --task-id smoke-sprint)
  assert_json_field "$state" "data['summary']['has_context'] is True and data['summary']['has_runtime_report'] is True and data['summary']['has_supervisor'] is True and data['summary']['supervisor_count'] >= 1"

  local state_from_worktree
  state_from_worktree=$(cd "$ROOT/.worktrees/smoke-sprint-expert-a" && ./scripts/state-read.sh --task-id smoke-sprint)
  assert_json_field "$state_from_worktree" "data['summary']['has_context'] is True and data['summary']['active_expert'] == ''"

  "$ROOT/scripts/state-update.sh" --task-id smoke-sprint <<'EOF' >/dev/null
{"mode":"execution","current_focus":"implement hooks","active_expert":"expert-a","goal":"drive smoke sprint to verification","lease_status":"running","run_duration_hours":5,"supervisors":["lead"],"executors":["expert-a","expert-b"],"skeptics":["expert-c"],"integration_pressure":true,"note":"execution thread accepted handoff"}
EOF

  local updated
  updated=$("$ROOT/scripts/state-read.sh" --task-id smoke-sprint)
  assert_json_field "$updated" "data['state']['mode'] == 'execution' and data['state']['active_expert'] == 'expert-a' and data['state']['lease']['status'] == 'running' and data['summary']['scale_out_recommended'] is True and 'parallel_execution_slices' in data['summary']['scale_out_triggers'] and 'integration_pressure' in data['summary']['scale_out_triggers'] and data['summary']['independent_skeptic'] is True and data['summary']['role_conflicts'] == []"

  set +e
  "$ROOT/scripts/state-update.sh" --task-id smoke-sprint <<'EOF' >/dev/null
{"supervisors":[]}
EOF
  local invalid_role_status=$?
  set -e
  [[ $invalid_role_status -eq 3 ]]

  (
    cd "$ROOT/.worktrees/smoke-sprint-expert-a" && ./scripts/state-update.sh --task-id smoke-sprint <<'EOF' >/dev/null
{"append_verified_steps":["state-update-from-worktree"],"note":"worktree state update"}
EOF
  )

  local updated_from_worktree
  updated_from_worktree=$("$ROOT/scripts/state-read.sh" --task-id smoke-sprint)
  assert_json_field "$updated_from_worktree" "'state-update-from-worktree' in data['state']['verification']['verified_steps']"

  "$ROOT/scripts/state-update.sh" --task-id smoke-sprint <<'EOF' >/dev/null
{"lease_status":"paused","paused_at":"2026-04-16T10:00:00Z","pause_reason":"codex_quota","resume_after":"2026-04-16T11:00:00Z","resume_checkpoint":"expert-a:after-hooks","dispatch_cursor":"expert-a","note":"quota pause"}
EOF

  local paused
  paused=$("$ROOT/scripts/state-read.sh" --task-id smoke-sprint)
  assert_json_field "$paused" "data['summary']['paused'] is True and data['summary']['resume_checkpoint'] == 'expert-a:after-hooks' and data['summary']['active_expert'] == 'expert-a'"

  local paused_context
  paused_context=$("$ROOT/scripts/context-build.sh" --task-id smoke-sprint --agent-role commander --memory-limit 5)
  assert_json_field "$paused_context" "data['context_path'].endswith('context.json')"

  local paused_packet
  paused_packet=$(python3 - "$ROOT/workspace/state/smoke-sprint/context.json" <<'PY'
import json
import sys
from pathlib import Path

print(json.dumps(json.loads(Path(sys.argv[1]).read_text(encoding='utf-8')), ensure_ascii=False))
PY
)
  assert_json_field "$paused_packet" "data['continuation']['lease']['status'] == 'paused' and data['continuation']['lease']['resume_checkpoint'] == 'expert-a:after-hooks'"
  assert_json_field "$paused_packet" "data['context_summary']['supervisor_count'] >= 1 and data['context_summary']['scale_out_recommended'] is True and 'parallel_execution_slices' in data['context_summary']['scale_out_triggers'] and data['context_summary']['independent_skeptic'] is True"

  "$ROOT/scripts/state-update.sh" --task-id smoke-sprint <<'EOF' >/dev/null
{"lease_status":"running","pause_reason":"","resume_after":"","current_focus":"resume from checkpoint","note":"resume execution"}
EOF
}

run_verify() {
  local pass
  pass=$("$ROOT/scripts/verify-loop.sh" --task-id smoke-sprint --max-rounds 2 --checks "true" --user-gate pass)
  assert_json_field "$pass" "data['last_pass'] is True and data['rounds_used'] == 1"

  set +e
  "$ROOT/scripts/verify-loop.sh" --task-id smoke-sprint --max-rounds 2 --checks "false" --user-gate pass >/dev/null
  local status=$?
  set -e
  [[ $status -eq 2 ]]

  local state
  state=$("$ROOT/scripts/state-read.sh" --task-id smoke-sprint)
  assert_json_field "$state" "data['state']['verification']['last_run_at'] != ''"
}

run_schema() {
  python3 - "$ROOT" <<'PY'
from pathlib import Path
import json
import subprocess
import sys

root = Path(sys.argv[1])
required = {"id","type","content","source","scope","confidence","created_at","last_validated_at","decay_policy","status"}


def fail(message):
    raise SystemExit(message)


card = root / "memory" / "world" / "no-destruction-without-confirmation.md"
text = card.read_text(encoding="utf-8")
frontmatter = text.split("---\n", 2)[1].splitlines()
fields = {line.split(":", 1)[0].strip() for line in frontmatter if ":" in line}
if not required.issubset(fields):
    fail(f"memory card missing keys: {sorted(required - fields)}")

contract = root / "workspace" / "contracts" / "smoke-sprint.md"
contract_fields = {line.split(":", 1)[0].strip() for line in contract.read_text(encoding="utf-8").split("---\n", 2)[1].splitlines() if ":" in line}
required_contract = {"task_id", "owner", "experts", "acceptance", "blocked_if", "memory_reads", "memory_writes"}
if not required_contract.issubset(contract_fields):
    fail(f"contract missing keys: {sorted(required_contract - contract_fields)}")

proposal = root / "openspec" / "proposals" / "smoke-sprint.md"
proposal_text = proposal.read_text(encoding="utf-8")
for section in ("## What", "## Why", "## Non-goals", "## Acceptance", "## Verification"):
    if section not in proposal_text:
        fail(f"proposal missing section: {section}")

coordination_doc = root / "docs" / "coordination-endpoints.md"
coordination_text = coordination_doc.read_text(encoding="utf-8")
for section in ("## 三层终点映射", "## Endpoint Surface", "### 5) `closeout.check`"):
    if section not in coordination_text:
        fail(f"coordination-endpoints missing section: {section}")

artifact_doc = root / "docs" / "artifact-schemas.md"
artifact_text = artifact_doc.read_text(encoding="utf-8")
for section in ("## 1) Sprint Contract", "## 2) Handoff (Lead/Expert)", "## 3) Task State", "## 4) Execution Closeout"):
    if section not in artifact_text:
        fail(f"artifact-schemas missing section: {section}")

closeout_template = root / ".codex" / "templates" / "EXECUTION-CLOSEOUT.md"
closeout_template_text = closeout_template.read_text(encoding="utf-8")
closeout_fields = {line.split(":", 1)[0].strip() for line in closeout_template_text.split("---\n", 2)[1].splitlines() if ":" in line}
required_closeout_fields = {"task_id", "from", "to", "scope", "execution_commit", "state_path", "context_path", "runtime_path", "verified_steps", "verified_files", "open_risks", "next_actions"}
if not required_closeout_fields.issubset(closeout_fields):
    fail(f"execution closeout template missing keys: {sorted(required_closeout_fields - closeout_fields)}")

# Schema smoke can run standalone without run_memory; seed one journal event if needed.
journal_dir = root / "memory" / "journal"
journal_files = list(journal_dir.glob("*.jsonl"))
if not journal_files:
    subprocess.run(
        [str(root / "scripts" / "memory-write.sh"), "--kind", "self", "--id", "schema-smoke-journal-seed"],
        input=json.dumps(
            {
                "type": "belief",
                "content": "Seed memory journal for schema smoke checks.",
                "source": "tests/smoke.sh#run_schema",
                "scope": "schema smoke",
                "confidence": "0.5",
                "status": "active",
            }
        ),
        text=True,
        capture_output=True,
        check=True,
    )
    journal_files = list(journal_dir.glob("*.jsonl"))

if not journal_files:
    fail("memory journal still empty after seed write")
event = json.loads(journal_files[0].read_text(encoding="utf-8").splitlines()[0])
for key in ("event_id", "memory_id", "op", "actor", "timestamp", "reason", "source_ref", "scope", "result"):
    if key not in event:
        fail(f"memory journal event missing key: {key}")

state = json.loads((root / "workspace" / "state" / "smoke-sprint" / "state.json").read_text(encoding="utf-8"))
for key in ("task_id", "status", "mode", "owner", "experts", "openspec", "runtime", "lease", "git", "verification", "memory", "team", "updated_at"):
    if key not in state:
        fail(f"state missing key: {key}")
for key in ("supervisors", "executors", "skeptics", "scale_out_recommended", "scale_out_triggers", "role_integrity"):
    if key not in state["team"]:
        fail(f"team missing key: {key}")
for key in ("independent_skeptic", "degraded", "role_conflicts", "role_overlap"):
    if key not in state["team"]["role_integrity"]:
        fail(f"team.role_integrity missing key: {key}")

context = json.loads((root / "workspace" / "state" / "smoke-sprint" / "context.json").read_text(encoding="utf-8"))
for key in ("task_id", "runtime", "state", "memory", "continuation", "documents", "context_summary"):
    if key not in context:
        fail(f"context missing key: {key}")
for key in ("supervisor_count", "scale_out_recommended", "scale_out_triggers"):
    if key not in context["context_summary"]:
        fail(f"context_summary missing key: {key}")
for key in ("independent_skeptic", "role_integrity_degraded", "role_conflicts"):
    if key not in context["context_summary"]:
        fail(f"context_summary missing key: {key}")


def run_json(command, cwd=None):
    result = subprocess.run(
        command,
        cwd=str(cwd) if cwd else None,
        capture_output=True,
        text=True,
        check=True,
    )
    return json.loads(result.stdout)


def require_keys(payload, required_keys):
    missing = [key for key in required_keys if key not in payload]
    if missing:
        fail(f"payload missing keys: {missing}")


runtime_report = run_json([str(root / "scripts" / "runtime-report.sh"), "--task-id", "smoke-sprint", "--agent-role", "commander"])
require_keys(runtime_report, ("timestamp", "repo_root", "worktree", "git", "hooks", "tests", "task_surfaces"))
if not runtime_report["task_surfaces"].get("state_path"):
    fail("runtime-report task_surfaces.state_path is empty")

subprocess.run(
    [str(root / "scripts" / "state-update.sh"), "--task-id", "smoke-sprint"],
    input=json.dumps({"skeptics": ["lead"], "note": "schema degraded skeptic fixture"}),
    text=True,
    capture_output=True,
    check=True,
)

dispatch = run_json([str(root / "scripts" / "dispatch-create.sh"), "--task-id", "smoke-sprint"])
require_keys(dispatch, ("task_id", "contract_path", "state_path", "context_path", "runtime_path", "independent_skeptic", "degraded", "role_conflicts", "role_overlap", "scale_out_recommended", "scale_out_triggers", "summary", "assignments"))
require_keys(dispatch["summary"], ("supervisor_count", "executor_count", "skeptic_count", "assignment_count", "created_worktree_count", "existing_worktree_count"))
if dispatch["summary"]["supervisor_count"] < 1 or dispatch["summary"]["executor_count"] < 2 or dispatch["summary"]["skeptic_count"] < 1:
    fail("dispatch summary counts are incomplete")
if dispatch["independent_skeptic"] is not False or dispatch["degraded"] is not True:
    fail("dispatch should report degraded skeptic independence after degraded fixture")
if "supervisor_skeptic_overlap:lead" not in dispatch["role_conflicts"]:
    fail("dispatch role_conflicts missing supervisor skeptic overlap")

context_build = run_json([str(root / "scripts" / "context-build.sh"), "--task-id", "smoke-sprint", "--agent-role", "commander", "--memory-limit", "5"])
require_keys(context_build, ("context_path", "runtime_path", "state_path", "memory_count", "handoff_count", "exploration_count"))
if context_build["memory_count"] < 1:
    fail("context-build memory_count < 1")

state_read = run_json([str(root / "scripts" / "state-read.sh"), "--task-id", "smoke-sprint"])
require_keys(state_read, ("state", "summary"))
require_keys(state_read["summary"], ("verification_complete", "has_context", "has_runtime_report", "has_supervisor", "supervisor_count", "independent_skeptic", "role_integrity_degraded", "role_conflicts", "scale_out_recommended", "scale_out_triggers", "event_count"))

artifact_check = run_json([str(root / "scripts" / "check-artifact-schemas.sh"), "--task-id", "smoke-sprint"])
require_keys(artifact_check, ("task_id", "checked", "artifacts", "errors", "valid"))
if not artifact_check["valid"]:
    fail(f"artifact schema check failed: {artifact_check['errors']}")

worktree_status = run_json([str(root / "scripts" / "worktree-status.sh"), "--task-id", "smoke-sprint"])
require_keys(worktree_status, ("clean", "dirty_files", "linked_contract", "linked_handoff"))
if "smoke-sprint.md" not in worktree_status["linked_contract"]:
    fail("worktree-status linked_contract does not reference smoke-sprint.md")

expert_worktree = root / ".worktrees" / "smoke-sprint-expert-a"
if expert_worktree.exists():
    worktree_status_from_expert = run_json(["./scripts/worktree-status.sh", "--task-id", "smoke-sprint"], cwd=expert_worktree)
    require_keys(worktree_status_from_expert, ("clean", "dirty_files", "linked_contract", "linked_handoff"))
    if "smoke-sprint.md" not in worktree_status_from_expert["linked_contract"]:
        fail("expert worktree-status linked_contract does not reference smoke-sprint.md")

git_status = run_json([str(root / "scripts" / "git-status-report.sh")])
require_keys(git_status, ("has_head", "branch", "staged_files", "unstaged_files", "untracked_files", "worktrees", "can_create_worktree"))
if not git_status["has_head"] or not git_status["can_create_worktree"]:
    fail("git-status-report has_head/can_create_worktree check failed")

git_snapshot = run_json([str(root / "scripts" / "git-snapshot.sh")])
require_keys(git_snapshot, ("repo_root", "worktree", "has_head", "head", "branch", "known_worktrees", "dirty_files", "remote_urls"))
if not git_snapshot["has_head"]:
    fail("git-snapshot has_head is false")

verify_loop = run_json([str(root / "scripts" / "verify-loop.sh"), "--task-id", "smoke-sprint", "--max-rounds", "1", "--checks", "true", "--user-gate", "pass"])
require_keys(verify_loop, ("rounds_used", "last_pass", "remaining_failures"))
if not verify_loop["last_pass"]:
    fail("verify-loop last_pass is false")
PY
}

run_endpoint() {
  "$ROOT/scripts/coordination-endpoint.sh" --task-id smoke-sprint --endpoint state.update <<'EOF' >/dev/null
{"skeptics":["lead"],"note":"endpoint router degraded skeptic fixture"}
EOF

  local state
  state=$("$ROOT/scripts/coordination-endpoint.sh" --task-id smoke-sprint --endpoint state.read)
  assert_json_field "$state" "'state' in data and 'summary' in data and data['summary']['has_supervisor'] is True"
  assert_json_field "$state" "data['summary']['independent_skeptic'] is False and 'supervisor_skeptic_overlap:lead' in data['summary']['role_conflicts']"

  local context
  context=$("$ROOT/scripts/coordination-endpoint.sh" --task-id smoke-sprint --endpoint context.build --agent-role commander --memory-limit 5)
  assert_json_field "$context" "data['context_path'].endswith('context.json') and data['runtime_path'].endswith('runtime.json') and data['state_path'].endswith('state.json')"
  assert_json_field "$context" "data['memory_count'] >= 1 and data['handoff_count'] >= 1 and data['exploration_count'] >= 1"

  local dispatch
  dispatch=$("$ROOT/scripts/coordination-endpoint.sh" --task-id smoke-sprint --endpoint dispatch.create)
  assert_json_field "$dispatch" "data['task_id'] == 'smoke-sprint' and 'summary' in data and data['summary']['supervisor_count'] >= 1 and data['summary']['executor_count'] >= 2 and data['summary']['skeptic_count'] >= 1"
  assert_json_field "$dispatch" "data['independent_skeptic'] is False and data['degraded'] is True and 'supervisor_skeptic_overlap:lead' in data['role_conflicts']"

  local closeout
  closeout=$("$ROOT/scripts/coordination-endpoint.sh" --task-id smoke-sprint --endpoint closeout.check)
  assert_json_field "$closeout" "data['task_id'] == 'smoke-sprint' and data['valid'] is True and len(data['errors']) == 0"

  set +e
  "$ROOT/scripts/coordination-endpoint.sh" --task-id smoke-sprint --endpoint unknown >/dev/null
  local status=$?
  set -e
  [[ $status -eq 3 ]]
}

case "$SECTION" in
  all)
    run_hooks
    run_memory
    run_workflow
    run_git_management
    run_dispatch
    run_context_state
    run_verify
    run_endpoint
    run_schema
    ;;
  hooks) run_hooks ;;
  memory) run_memory ;;
  workflow) run_workflow ;;
  dispatch)
    run_workflow
    run_dispatch
    ;;
  git)
    run_workflow
    run_git_management
    run_dispatch
    ;;
  context)
    run_workflow
    run_dispatch
    run_context_state
    ;;
  verify) run_verify ;;
  endpoint)
    run_workflow
    run_dispatch
    run_context_state
    run_endpoint
    ;;
  schema)
    run_workflow
    run_dispatch
    run_context_state
    run_schema
    ;;
  *)
    echo "unknown smoke section: $SECTION" >&2
    exit 3
    ;;
esac

echo "{\"section\":\"$SECTION\",\"passed\":true}"
