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
    if current == source / "workspace":
        ignored.add("logs")
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
{"changed_code_files":["scripts/x.sh"],"verified_steps":["tests/smoke.sh","coverage:all"],"verified_files":["scripts/x.sh"],"last_test_exit_code":0,"product_goal_status":"validated","quality_review_status":"approved","team":{"product_anchors":["lead"],"quality_anchors":["expert-c"],"anchor_policy":{"product_anchor_role":"supervisor","quality_anchor_role":"skeptic","constant_anchor_seats":true}},"product":{"anchor":"lead","goal":"Ship the smoke slice.","user_value":"Keep DD Hermes task-bound.","task_class":"T2","quality_requirement":"degraded-allowed","task_class_rationale":"This is a bounded smoke-test slice.","non_goals":["No runtime rewrite."],"product_acceptance":["Traceable outcome."],"drift_risk":"Could drift into unrelated cleanup.","goal_status":"validated","goal_drift_flags":[],"last_product_review_at":"2026-04-16T10:00:00Z"},"quality":{"anchor":"expert-c","review_status":"approved","review_findings":[],"review_examples":[],"last_review_at":"2026-04-16T10:05:00Z"}}
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
  grep -q "## Product Gate" "$ROOT/workspace/contracts/smoke-sprint.md"
  grep -q "task_class: T2" "$ROOT/workspace/contracts/smoke-sprint.md"
  grep -q "quality_requirement: degraded-allowed" "$ROOT/workspace/contracts/smoke-sprint.md"
  ! grep -q "sprint-000" "$ROOT/workspace/contracts/smoke-sprint.md"
  [[ -f "$ROOT/workspace/exploration/exploration-lead-smoke-sprint.md" ]]
  grep -q "## Evidence" "$ROOT/workspace/exploration/exploration-lead-smoke-sprint.md"
  [[ -f "$ROOT/openspec/proposals/smoke-sprint.md" ]]
  grep -q "## Verification" "$ROOT/openspec/proposals/smoke-sprint.md"
  [[ -f "$ROOT/workspace/state/smoke-sprint/state.json" ]]
  grep -q "## Acceptance" "$ROOT/workspace/handoffs/smoke-sprint-lead-to-expert-a.md"
  grep -q "## Product Check" "$ROOT/workspace/handoffs/smoke-sprint-lead-to-expert-a.md"
  ! grep -q "subsystem-or-slice" "$ROOT/workspace/handoffs/smoke-sprint-lead-to-expert-a.md"
  ! grep -q "TBD" "$ROOT/workspace/handoffs/smoke-sprint-lead-to-expert-a.md"
  [[ -f "$ROOT/workspace/closeouts/smoke-sprint-expert-a.md" ]]
  grep -q "## Completion" "$ROOT/workspace/closeouts/smoke-sprint-expert-a.md"
  grep -q "## Quality Review" "$ROOT/workspace/closeouts/smoke-sprint-expert-a.md"
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
  assert_json_field "$dispatch" "all(item['next_commands'] for item in data['assignments']) and all(item['artifacts']['context_path'].endswith('.json') and item['artifacts']['runtime_path'].endswith('.json') for item in data['assignments'])"
  assert_json_field "$dispatch" "all(item['handoff_path'].endswith('.md') for item in data['assignments'] if item['role'] == 'executor') and any(item['status'] in ('created', 'existing') for item in data['assignments'] if item['role'] == 'executor')"
  assert_json_field "$dispatch" "all(item['worktree_required'] is True and item['handoff_path'].endswith('.md') and item['worktree_path'].endswith('smoke-sprint-' + item['agent_id']) and item['artifacts']['context_path'].endswith('context-skeptic-' + item['agent_id'] + '.json') and item['artifacts']['runtime_path'].endswith('runtime-skeptic-' + item['agent_id'] + '.json') and item['status'] in ('created', 'existing') for item in data['assignments'] if item['role'] == 'skeptic')"
  assert_json_field "$dispatch" "data['independent_skeptic'] is True and data['degraded'] is False and data['role_conflicts'] == []"
  assert_json_field "$dispatch" "data['quality_seat_mode'] == 'independent' and data['quality_seat_ready'] is True and data['quality_seat_status'] == 'ready'"
  assert_json_field "$dispatch" "data['skeptic_lane_status'] == 'ready' and data['skeptic_lane_ready'] is True and data['skeptic_lane_reasons'] == []"
  assert_json_field "$dispatch" "data['task_class'] == 'T2' and data['quality_requirement'] == 'degraded-allowed'"
  assert_json_field "$dispatch" "data['anchors']['product_goal'] != '' and len(data['anchors']['product_anchors']) >= 1 and len(data['anchors']['quality_anchors']) >= 1"
  assert_json_field "$dispatch" "data['anchors']['product_gate_ready'] is True and data['anchors']['quality_anchor_ready'] is True"

  "$ROOT/scripts/state-update.sh" --task-id smoke-sprint <<'EOF' >/dev/null
{"skeptics":["lead"],"note":"dispatch degraded skeptic fixture"}
EOF

  set +e
  "$ROOT/scripts/dispatch-create.sh" --task-id smoke-sprint >/tmp/dd-hermes-dispatch-degraded.json
  local status=$?
  set -e
  [[ $status -eq 2 ]]
  python3 - <<'PY' /tmp/dd-hermes-dispatch-degraded.json
import json, sys
payload = json.loads(open(sys.argv[1], encoding="utf-8").read())
assert payload["blocked"] is True
assert "degraded supervision" in payload["error"]
assert "degraded_ack_by_missing" in payload["degraded_ack_reasons"]
assert payload["quality_seat_mode"] == "degraded"
assert payload["quality_seat_status"] == "blocked"
assert "degraded_ack_by_missing" in payload["quality_seat_reasons"]
PY

  "$ROOT/scripts/state-update.sh" --task-id smoke-sprint <<'EOF' >/dev/null
{"degraded_ack_by":"lead","degraded_ack_at":"2026-04-17T09:00:00Z","note":"dispatch degraded ack fixture"}
EOF

  local degraded_ready
  degraded_ready=$("$ROOT/scripts/dispatch-create.sh" --task-id smoke-sprint)
  assert_json_field "$degraded_ready" "data['independent_skeptic'] is False and data['degraded'] is True and data['degraded_ack_ready'] is True"
  assert_json_field "$degraded_ready" "data['quality_seat_mode'] == 'degraded' and data['quality_seat_ready'] is True and data['quality_seat_status'] == 'ready'"
  assert_json_field "$degraded_ready" "data['skeptic_lane_status'] == 'not-required' and data['skeptic_lane_ready'] is True and data['skeptic_lane_reasons'] == []"
  assert_json_field "$degraded_ready" "'supervisor_skeptic_overlap:lead' in data['role_conflicts'] and 'independent_skeptic_unavailable' in data['scale_out_triggers']"

  "$ROOT/scripts/sprint-init.sh" --task-id dispatch-failure-sprint --owner lead --experts expert-a,expert-c >/dev/null
  "$ROOT/scripts/state-update.sh" --task-id dispatch-failure-sprint <<'EOF' >/dev/null
{"supervisors":["lead"],"executors":["expert-a"],"skeptics":["expert-c"],"quality_anchors":["expert-c"],"note":"dispatch materialization failure fixture"}
EOF
  git -C "$ROOT" branch dispatch-failure-sprint-expert-a HEAD >/dev/null

  local materialization_blocked
  set +e
  materialization_blocked=$("$ROOT/scripts/dispatch-create.sh" --task-id dispatch-failure-sprint)
  status=$?
  set -e
  [[ $status -eq 2 ]]
  assert_json_field "$materialization_blocked" "data['blocked'] is True and data['stage'] == 'worktree_create' and data['role'] == 'executor' and data['agent_id'] == 'expert-a'"
  assert_json_field "$materialization_blocked" "data['quality_seat_status'] == 'ready' and data['task_class'] == 'T2' and data['quality_requirement'] == 'degraded-allowed'"
  assert_json_field "$materialization_blocked" "data['child_exit_code'] != 0 and any('dispatch-failure-sprint' in item for item in data['suggested_next_commands'])"

  "$ROOT/scripts/sprint-init.sh" --task-id dispatch-state-read-failure-sprint --owner lead --experts expert-a,expert-c >/dev/null
  "$ROOT/scripts/state-update.sh" --task-id dispatch-state-read-failure-sprint <<'EOF' >/dev/null
{"supervisors":["lead"],"executors":["expert-a"],"skeptics":["expert-c"],"quality_anchors":["expert-c"],"note":"dispatch preflight state-read failure fixture"}
EOF
  printf '{not-json\n' > "$ROOT/workspace/state/dispatch-state-read-failure-sprint/state.json"

  local state_read_blocked
  set +e
  state_read_blocked=$("$ROOT/scripts/dispatch-create.sh" --task-id dispatch-state-read-failure-sprint)
  status=$?
  set -e
  [[ $status -eq 2 ]]
  assert_json_field "$state_read_blocked" "data['blocked'] is True and data['stage'] == 'state_read' and data['role'] == 'commander' and data['agent_id'] == 'lead'"
  assert_json_field "$state_read_blocked" "data['task_class'] == '' and data['quality_requirement'] == '' and data['child_exit_code'] != 0"
  assert_json_field "$state_read_blocked" "any(item == './scripts/state-read.sh --task-id dispatch-state-read-failure-sprint' for item in data['suggested_next_commands'])"

  "$ROOT/scripts/sprint-init.sh" --task-id dispatch-context-build-failure-sprint --owner lead --experts expert-a,expert-c >/dev/null
  "$ROOT/scripts/state-update.sh" --task-id dispatch-context-build-failure-sprint <<'EOF' >/dev/null
{"supervisors":["lead"],"executors":["expert-a"],"skeptics":["expert-c"],"quality_anchors":["expert-c"],"note":"dispatch preflight context-build failure fixture"}
EOF
  mv "$ROOT/scripts/runtime-report.sh" "$ROOT/scripts/runtime-report.sh.off"

  local context_build_blocked
  set +e
  context_build_blocked=$("$ROOT/scripts/dispatch-create.sh" --task-id dispatch-context-build-failure-sprint)
  status=$?
  set -e
  mv "$ROOT/scripts/runtime-report.sh.off" "$ROOT/scripts/runtime-report.sh"
  [[ $status -eq 2 ]]
  assert_json_field "$context_build_blocked" "data['blocked'] is True and data['stage'] == 'context_build' and data['role'] == 'commander' and data['agent_id'] == 'lead'"
  assert_json_field "$context_build_blocked" "data['quality_seat_status'] == 'ready' and data['task_class'] == 'T2' and data['quality_requirement'] == 'degraded-allowed'"
  assert_json_field "$context_build_blocked" "data['child_exit_code'] != 0 and any(item == './scripts/context-build.sh --task-id dispatch-context-build-failure-sprint --agent-role commander' for item in data['suggested_next_commands'])"
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
  assert_json_field "$state_after_commit" "len(data['state']['git']['latest_commit']) == 40 and len(data['state']['git']['baseline_commit']) == 40 and data['state']['git']['latest_branch'] == 'smoke-sprint-expert-a'"

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
  assert_json_field "$state" "data['summary']['task_class'] == 'T2' and data['summary']['quality_requirement'] == 'degraded-allowed'"
  assert_json_field "$state" "data['summary']['execution_closeout_status'] == 'blocked' and data['summary']['ready_for_execution_slice_done'] is False"

  local state_from_worktree
  state_from_worktree=$(cd "$ROOT/.worktrees/smoke-sprint-expert-a" && ./scripts/state-read.sh --task-id smoke-sprint)
  assert_json_field "$state_from_worktree" "data['summary']['has_context'] is True and data['summary']['active_expert'] == ''"

  "$ROOT/scripts/state-update.sh" --task-id smoke-sprint <<'EOF' >/dev/null
{"mode":"execution","current_focus":"implement hooks","active_expert":"expert-a","goal":"drive smoke sprint to verification","lease_status":"running","run_duration_hours":5,"supervisors":["lead"],"executors":["expert-a","expert-b"],"skeptics":["expert-c"],"integration_pressure":true,"note":"execution thread accepted handoff"}
EOF

  local updated
  updated=$("$ROOT/scripts/state-read.sh" --task-id smoke-sprint)
  assert_json_field "$updated" "data['state']['mode'] == 'execution' and data['state']['active_expert'] == 'expert-a' and data['state']['lease']['status'] == 'running' and data['summary']['scale_out_recommended'] is True and 'parallel_execution_slices' in data['summary']['scale_out_triggers'] and 'integration_pressure' in data['summary']['scale_out_triggers'] and data['summary']['independent_skeptic'] is True and data['summary']['role_conflicts'] == []"
  assert_json_field "$updated" "data['summary']['product_gate_ready'] is True and data['summary']['quality_anchor_ready'] is True and data['summary']['product_gate_status'] == 'ready' and data['summary']['quality_anchor_status'] == 'ready'"
  assert_json_field "$updated" "data['summary']['task_class'] == 'T2' and data['summary']['quality_requirement'] == 'degraded-allowed' and data['summary']['quality_requirement_ready'] is False and data['summary']['manual_escalation_required'] is True and 't2_manual_escalation_required:integration_pressure' in data['summary']['manual_escalation_reasons']"

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
  assert_json_field "$paused_packet" "data['context_summary']['product_gate_ready'] is True and data['context_summary']['quality_anchor_ready'] is True and data['context_summary']['product_gate_status'] == 'ready' and data['context_summary']['quality_anchor_status'] == 'ready'"
  assert_json_field "$paused_packet" "data['context_summary']['task_class'] == 'T2' and data['context_summary']['quality_requirement'] == 'degraded-allowed' and data['context_summary']['quality_requirement_ready'] is False and data['context_summary']['manual_escalation_required'] is True and 't2_manual_escalation_required:integration_pressure' in data['context_summary']['manual_escalation_reasons']"
  assert_json_field "$paused_packet" "data['context_summary']['execution_closeout_status'] == 'blocked' and data['context_summary']['ready_for_execution_slice_done'] is False"

  "$ROOT/scripts/state-update.sh" --task-id smoke-sprint <<'EOF' >/dev/null
{"lease_status":"running","pause_reason":"","resume_after":"","current_focus":"resume from checkpoint","note":"resume execution"}
EOF

  "$ROOT/scripts/state-update.sh" --task-id smoke-sprint <<'EOF' >/dev/null
{"integration_pressure":false,"note":"restore low-risk smoke fixture"}
EOF
}

run_discussion_textbook() {
  local missing_state_gate
  set +e
  missing_state_gate=$("$ROOT/hooks/thread-switch-gate.sh" --task-id missing-sprint --target execution)
  local gate_status=$?
  set -e
  [[ $gate_status -eq 2 ]]
  assert_json_field "$missing_state_gate" "data['pass'] is False and 'state.json is missing' in data['blocked_reason']"

  local decision
  decision=$("$ROOT/scripts/decision-init.sh" --task-id smoke-sprint --decision-id decision-smoke)
  assert_json_field "$decision" "len(data['explorer_paths']) == 3 and data['synthesis_path'].endswith('synthesis.md')"

  local state_after_decision
  state_after_decision=$("$ROOT/scripts/state-read.sh" --task-id smoke-sprint)
  assert_json_field "$state_after_decision" "data['summary']['discussion_policy'] == '3-explorer-then-execute' and data['summary']['decision_id'] == 'decision-smoke'"

  "$ROOT/scripts/sprint-init.sh" --task-id architecture-sprint --owner lead --experts expert-a --current-focus "architecture policy routing" --task-class T3 >/dev/null
  local architecture_state
  architecture_state=$("$ROOT/scripts/state-read.sh" --task-id architecture-sprint)
  assert_json_field "$architecture_state" "data['summary']['discussion_policy'] == '3-explorer-then-execute'"
  assert_json_field "$architecture_state" "data['summary']['task_class'] == 'T3' and data['summary']['quality_requirement'] == 'requires-independent'"

  local architecture_gate
  set +e
  architecture_gate=$("$ROOT/hooks/thread-switch-gate.sh" --task-id architecture-sprint --target execution)
  gate_status=$?
  set -e
  [[ $gate_status -eq 2 ]]
  assert_json_field "$architecture_gate" "data['pass'] is False and 'synthesis_path is empty' in data['blocked_reason']"

  "$ROOT/scripts/decision-init.sh" --task-id architecture-sprint --decision-id architecture-smoke >/dev/null
  local placeholder_gate
  set +e
  placeholder_gate=$("$ROOT/hooks/thread-switch-gate.sh" --task-id architecture-sprint --target execution)
  gate_status=$?
  set -e
  [[ $gate_status -eq 2 ]]
  assert_json_field "$placeholder_gate" "data['pass'] is False and 'placeholder' in data['blocked_reason']"

python3 - "$ROOT/workspace/decisions/architecture-smoke/synthesis.md" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
path.write_text("""---
decision_id: architecture-smoke
task_id: architecture-sprint
owner: lead
status: synthesized
---

# Decision Synthesis

## Goal

Route architecture work through discussion before execution.

## Accepted Path

- Auto-route architecture tasks into `3-explorer-then-execute`.

## Rejected Paths

- Keep architecture tasks on `direct`.

## Execution Boundary

- Execution may modify initialization and gate logic, plus smoke coverage.

## Executor Handoff

- Implement the routing and gate changes, then verify them.
""", encoding="utf-8")
PY

  "$ROOT/scripts/state-update.sh" --task-id architecture-sprint <<'EOF' >/dev/null
{"degraded_ack_by":"lead","degraded_ack_at":"2026-04-17T10:30:00Z","note":"architecture degraded ack fixture"}
EOF
  set +e
  local architecture_dispatch_blocked
  architecture_dispatch_blocked=$("$ROOT/scripts/dispatch-create.sh" --task-id architecture-sprint)
  gate_status=$?
  set -e
  [[ $gate_status -eq 2 ]]
  assert_json_field "$architecture_dispatch_blocked" "data['blocked'] is True and data['task_class'] == 'T3' and data['quality_requirement'] == 'requires-independent'"
  assert_json_field "$architecture_dispatch_blocked" "'quality_requirement_requires_independent' in data['quality_seat_reasons']"

  "$ROOT/scripts/state-update.sh" --task-id architecture-sprint <<'EOF' >/dev/null
{"skeptics":["expert-c"],"quality_anchors":["expert-c"],"degraded_ack_by":"","degraded_ack_at":"","note":"architecture independent skeptic fixture"}
EOF
  local architecture_dispatch_ready
  architecture_dispatch_ready=$("$ROOT/scripts/dispatch-create.sh" --task-id architecture-sprint)
  assert_json_field "$architecture_dispatch_ready" "data['skeptic_lane_status'] == 'ready' and data['skeptic_lane_ready'] is True"
  local architecture_gate_pass
  architecture_gate_pass=$("$ROOT/hooks/thread-switch-gate.sh" --task-id architecture-sprint --target execution)
  assert_json_field "$architecture_gate_pass" "data['pass'] is True"

  "$ROOT/scripts/sprint-init.sh" --task-id delivery-sprint --owner lead --experts expert-a --current-focus "delivery bugfix" >/dev/null
  local delivery_state
  delivery_state=$("$ROOT/scripts/state-read.sh" --task-id delivery-sprint)
  assert_json_field "$delivery_state" "data['summary']['discussion_policy'] == 'direct'"

  local delivery_gate_before_dispatch
  set +e
  delivery_gate_before_dispatch=$("$ROOT/hooks/thread-switch-gate.sh" --task-id delivery-sprint --target execution)
  gate_status=$?
  set -e
  [[ $gate_status -eq 2 ]]
  assert_json_field "$delivery_gate_before_dispatch" "data['pass'] is False and 'context packet is missing' in data['blocked_reason'] and 'execution worktree is missing' in data['blocked_reason']"

  "$ROOT/scripts/state-update.sh" --task-id delivery-sprint <<'EOF' >/dev/null
{"degraded_ack_by":"lead","degraded_ack_at":"2026-04-17T10:35:00Z","note":"delivery degraded ack fixture"}
EOF
  "$ROOT/scripts/dispatch-create.sh" --task-id delivery-sprint >/dev/null
  local delivery_gate
  delivery_gate=$("$ROOT/hooks/thread-switch-gate.sh" --task-id delivery-sprint --target execution)
  assert_json_field "$delivery_gate" "data['pass'] is True and data['discussion_policy'] == 'direct'"

  "$ROOT/scripts/sprint-init.sh" --task-id t2-override-sprint --owner lead --experts expert-a --current-focus "bounded slice under integration pressure" >/dev/null
  "$ROOT/scripts/state-update.sh" --task-id t2-override-sprint <<'EOF' >/dev/null
{"supervisors":["lead"],"executors":["expert-a"],"skeptics":["expert-c"],"quality_anchors":["expert-c"],"integration_pressure":true,"note":"t2 manual escalation required fixture"}
EOF

  local t2_override_state
  t2_override_state=$("$ROOT/scripts/state-read.sh" --task-id t2-override-sprint)
  assert_json_field "$t2_override_state" "data['summary']['task_class'] == 'T2' and data['summary']['quality_requirement'] == 'degraded-allowed' and data['summary']['quality_requirement_ready'] is False and data['summary']['manual_escalation_required'] is True and 't2_manual_escalation_required:integration_pressure' in data['summary']['manual_escalation_reasons']"

  local t2_override_context
  t2_override_context=$("$ROOT/scripts/context-build.sh" --task-id t2-override-sprint --agent-role commander --memory-limit 5)
  assert_json_field "$t2_override_context" "data['context_path'].endswith('context.json')"
  local t2_override_packet
  t2_override_packet=$(python3 - "$ROOT/workspace/state/t2-override-sprint/context.json" <<'PY'
import json
import sys
from pathlib import Path

print(json.dumps(json.loads(Path(sys.argv[1]).read_text(encoding='utf-8')), ensure_ascii=False))
PY
)
  assert_json_field "$t2_override_packet" "data['context_summary']['quality_requirement_ready'] is False and data['context_summary']['manual_escalation_required'] is True and 't2_manual_escalation_required:integration_pressure' in data['context_summary']['manual_escalation_reasons']"

  set +e
  local t2_override_dispatch_blocked
  t2_override_dispatch_blocked=$("$ROOT/scripts/dispatch-create.sh" --task-id t2-override-sprint)
  gate_status=$?
  set -e
  [[ $gate_status -eq 2 ]]
  assert_json_field "$t2_override_dispatch_blocked" "data['blocked'] is True and data['task_class'] == 'T2' and data['quality_requirement'] == 'degraded-allowed'"
  assert_json_field "$t2_override_dispatch_blocked" "'t2_manual_escalation_required:integration_pressure' in data['task_policy_reasons']"

  "$ROOT/scripts/state-update.sh" --task-id t2-override-sprint <<'EOF' >/dev/null
{"quality_requirement":"requires-independent","note":"t2 explicit escalation fixture"}
EOF
  local t2_override_dispatch_ready
  t2_override_dispatch_ready=$("$ROOT/scripts/dispatch-create.sh" --task-id t2-override-sprint)
  assert_json_field "$t2_override_dispatch_ready" "data['task_class'] == 'T2' and data['quality_requirement'] == 'requires-independent' and data['quality_requirement_source'] == 'explicit_escalation'"
  assert_json_field "$t2_override_dispatch_ready" "data['manual_escalation_required'] is False and data['quality_seat_mode'] == 'independent' and data['quality_seat_ready'] is True"

  local t2_override_gate
  t2_override_gate=$("$ROOT/hooks/thread-switch-gate.sh" --task-id t2-override-sprint --target execution)
  assert_json_field "$t2_override_gate" "data['pass'] is True"

  "$ROOT/scripts/sprint-init.sh" --task-id product-gap-sprint --owner lead --experts expert-a --current-focus "delivery bugfix" >/dev/null
  "$ROOT/scripts/state-update.sh" --task-id product-gap-sprint <<'EOF' >/dev/null
{"product_goal":"","user_value":"","non_goals":[],"product_acceptance":[],"drift_risk":"","last_product_review_at":"","note":"product gate gap fixture"}
EOF
  set +e
  local product_gap_gate
  product_gap_gate=$("$ROOT/hooks/thread-switch-gate.sh" --task-id product-gap-sprint --target execution)
  gate_status=$?
  set -e
  [[ $gate_status -eq 2 ]]
  assert_json_field "$product_gap_gate" "data['pass'] is False and 'product gate not ready' in data['blocked_reason']"

  local prompt
  prompt=$("$ROOT/scripts/execution-thread-prompt.sh" --task-id smoke-sprint --expert expert-b)
  assert_json_field "$prompt" "'context.json' in data['prompt'] and data['expert'] == 'expert-b'"

  local textbook_entry
  textbook_entry=$("$ROOT/scripts/textbook-record.sh" --topic "codex-workflow" <<'EOF'
{"date":"2026-04-16","experience":"Split command and execution threads.","links":["https://example.com/thread-model"],"conclusions":"Commander thread should not code directly.","patterns":"Discuss first, then execute.","next_lesson":"Decision synthesis."}
EOF
)
  assert_json_field "$textbook_entry" "data['entry_path'].endswith('codex-workflow.md')"

  local textbook_summary
  textbook_summary=$("$ROOT/scripts/textbook-summary.sh" 2026-04-16)
  assert_json_field "$textbook_summary" "data['summary_path'].endswith('2026-04-16.md') and data['entry_count'] >= 1"
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

run_entry() {
  local entry
  entry=$("$ROOT/scripts/demo-entry.sh")
  [[ "$entry" == *"DD Hermes 体验入口"* ]]
  [[ "$entry" == *"最近一次真实 end-to-end 证明"* ]]

  local landing_doc="$ROOT/指挥文档/06-一期PhaseDone审计.md"
  local landing_backup
  landing_backup=$(mktemp)
  cp "$landing_doc" "$landing_backup"
  trap 'cp "$landing_backup" "$landing_doc"; rm -f "$landing_backup"; trap - RETURN' RETURN

  python3 - "$landing_doc" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
match = re.match(r"---\n(.*?)\n---\n", text, re.S)
if not match:
    raise SystemExit("frontmatter missing")
lines = []
for line in match.group(1).splitlines():
    if line.startswith("current_mainline_task_id:"):
        lines.append("current_mainline_task_id:")
    elif line.startswith("current_mainline_doc:"):
        lines.append("current_mainline_doc:")
    elif line.startswith("current_gap_1:"):
        lines.append("current_gap_1: 最近一个 phase-2 proof 已归档；当前还没有新的 active mainline。")
    elif line.startswith("current_gap_2:"):
        lines.append("current_gap_2: 下一步需要在新 task id 下定义 successor mainline，而不是把任何已归档 proof 重新当成 active mainline。")
    else:
        lines.append(line)
updated = "---\n" + "\n".join(lines) + "\n---\n" + text[match.end():]
path.write_text(updated, encoding="utf-8")
PY

  local vacant
  vacant=$("$ROOT/scripts/demo-entry.sh")
  [[ "$vacant" == *"当前 active mainline：暂无"* ]]
  [[ "$vacant" == *"下一步决策文档：指挥文档/04-任务重校准与线程策略.md"* ]]
  [[ "$vacant" == *"successor 审计："* ]]
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
required_contract = {"task_id", "owner", "experts", "acceptance", "blocked_if", "memory_reads", "memory_writes", "task_class", "quality_requirement", "task_class_rationale"}
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
required_closeout_fields = {"schema_version", "task_id", "from", "to", "scope", "execution_commit", "state_path", "context_path", "runtime_path", "verified_steps", "verified_files", "quality_review_status", "quality_findings_summary", "open_risks", "next_actions"}
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
for key in ("task_id", "status", "mode", "owner", "experts", "openspec", "runtime", "lease", "git", "verification", "memory", "team", "verdicts", "updated_at"):
    if key not in state:
        fail(f"state missing key: {key}")
for key in ("supervisors", "executors", "skeptics", "product_anchors", "quality_anchors", "anchor_policy", "scale_out_recommended", "scale_out_triggers", "role_integrity"):
    if key not in state["team"]:
        fail(f"team missing key: {key}")
for key in ("independent_skeptic", "degraded", "degraded_ack_by", "degraded_ack_at", "role_conflicts", "role_overlap"):
    if key not in state["team"]["role_integrity"]:
        fail(f"team.role_integrity missing key: {key}")
for key in ("anchor", "goal", "user_value", "task_class", "quality_requirement", "task_class_rationale", "non_goals", "product_acceptance", "drift_risk", "goal_status", "goal_drift_flags", "last_product_review_at"):
    if key not in state["product"]:
        fail(f"state.product missing key: {key}")
for key in ("anchor", "review_status", "review_findings", "review_examples", "last_review_at"):
    if key not in state["quality"]:
        fail(f"state.quality missing key: {key}")
for key in ("updated_at", "task_policy", "product_gate", "quality_anchor", "quality_review", "degraded_ack", "quality_seat_execution", "quality_seat_completion", "skeptic_lane", "execution_closeout"):
    if key not in state["verdicts"]:
        fail(f"state.verdicts missing key: {key}")
for verdict_key in ("task_policy", "product_gate", "quality_anchor", "quality_review", "degraded_ack", "quality_seat_execution", "quality_seat_completion", "skeptic_lane", "execution_closeout"):
    verdict = state["verdicts"][verdict_key]
    for key in ("status", "ready", "reasons", "updated_at"):
        if key not in verdict:
            fail(f"state.verdicts.{verdict_key} missing key: {key}")

context = json.loads((root / "workspace" / "state" / "smoke-sprint" / "context.json").read_text(encoding="utf-8"))
for key in ("task_id", "runtime", "state", "memory", "continuation", "documents", "context_summary"):
    if key not in context:
        fail(f"context missing key: {key}")
for key in ("supervisor_count", "product_anchor_count", "quality_anchor_count", "product_anchor_name", "product_anchor_role", "quality_anchor_name", "quality_anchor_role", "product_goal", "product_goal_status", "task_class", "task_class_bucket", "task_class_rationale", "quality_requirement", "quality_requirement_source", "quality_requirement_ready", "quality_requirement_reasons", "task_policy_status", "manual_escalation_required", "manual_escalation_reasons", "quality_review_status", "scale_out_recommended", "scale_out_triggers", "product_gate_ready", "product_gate_status", "quality_anchor_ready", "quality_anchor_status", "quality_review_ready", "quality_review_gate_status", "degraded_ack_required", "degraded_ack_ready", "degraded_ack_status", "execution_closeout_ready", "execution_closeout_status", "execution_closeout_reasons", "execution_closeout_path", "ready_for_execution_slice_done", "verdicts_updated_at"):
    if key not in context["context_summary"]:
        fail(f"context_summary missing key: {key}")
for key in ("skeptic_lane_ready", "skeptic_lane_status", "skeptic_lane_reasons"):
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
require_keys(dispatch, ("task_id", "contract_path", "state_path", "context_path", "runtime_path", "independent_skeptic", "degraded", "degraded_ack_ready", "degraded_ack_status", "role_conflicts", "role_overlap", "task_class", "task_class_bucket", "quality_requirement", "manual_escalation_required", "manual_escalation_reasons", "task_policy_reasons", "task_policy_status", "quality_seat_mode", "quality_seat_ready", "quality_seat_status", "quality_seat_reasons", "skeptic_lane_ready", "skeptic_lane_status", "skeptic_lane_reasons", "scale_out_recommended", "scale_out_triggers", "summary", "assignments"))
require_keys(dispatch["summary"], ("supervisor_count", "executor_count", "skeptic_count", "assignment_count", "created_worktree_count", "existing_worktree_count", "quality_seat_mode", "quality_seat_ready", "quality_seat_status", "skeptic_lane_ready", "skeptic_lane_status"))
if dispatch["summary"]["supervisor_count"] < 1 or dispatch["summary"]["executor_count"] < 2 or dispatch["summary"]["skeptic_count"] < 1:
    fail("dispatch summary counts are incomplete")
if dispatch["independent_skeptic"] is not False or dispatch["degraded"] is not True:
    fail("dispatch should report degraded skeptic independence after degraded fixture")
if dispatch["task_class"] != "T2" or dispatch["quality_requirement"] != "degraded-allowed":
    fail("dispatch should expose T2 degraded-allowed truth for smoke fixture")
if dispatch["quality_seat_mode"] != "degraded" or dispatch["quality_seat_ready"] is not True:
    fail("dispatch quality seat should report degraded but ready after explicit degraded ack")
if dispatch["skeptic_lane_status"] != "not-required" or dispatch["skeptic_lane_ready"] is not True:
    fail("dispatch should report skeptic lane as not-required for degraded-ready smoke fixture")
if "supervisor_skeptic_overlap:lead" not in dispatch["role_conflicts"]:
    fail("dispatch role_conflicts missing supervisor skeptic overlap")

context_build = run_json([str(root / "scripts" / "context-build.sh"), "--task-id", "smoke-sprint", "--agent-role", "commander", "--memory-limit", "5"])
require_keys(context_build, ("context_path", "runtime_path", "state_path", "memory_count", "handoff_count", "exploration_count"))
if context_build["memory_count"] < 1:
    fail("context-build memory_count < 1")

state_read = run_json([str(root / "scripts" / "state-read.sh"), "--task-id", "smoke-sprint"])
require_keys(state_read, ("state", "summary"))
require_keys(state_read["summary"], ("verification_complete", "has_context", "has_runtime_report", "has_supervisor", "supervisor_count", "product_anchor_count", "quality_anchor_count", "product_anchor_name", "product_anchor_role", "product_goal_ready", "product_goal_status", "task_class", "task_class_bucket", "quality_requirement", "quality_requirement_ready", "quality_requirement_reasons", "task_policy_status", "manual_escalation_required", "manual_escalation_reasons", "quality_review_status", "product_gate_ready", "product_gate_status", "quality_anchor_ready", "quality_anchor_status", "quality_review_ready", "quality_review_gate_status", "quality_seat_mode", "quality_seat_ready", "quality_seat_status", "quality_seat_reasons", "skeptic_lane_ready", "skeptic_lane_status", "skeptic_lane_reasons", "execution_closeout_ready", "execution_closeout_status", "execution_closeout_reasons", "execution_closeout_path", "ready_for_execution_slice_done", "independent_skeptic", "role_integrity_degraded", "degraded_ack_required", "degraded_ack_ready", "degraded_ack_status", "role_conflicts", "scale_out_recommended", "scale_out_triggers", "verdicts_updated_at", "event_count"))
if state_read["summary"]["quality_seat_mode"] != "degraded" or state_read["summary"]["quality_seat_status"] != "ready":
    fail("state-read quality seat summary should expose degraded ready truth")
if state_read["summary"]["skeptic_lane_status"] != "not-required" or state_read["summary"]["skeptic_lane_ready"] is not True:
    fail("state-read should expose skeptic lane as not-required for degraded-ready smoke fixture")
if state_read["summary"]["task_class"] != "T2" or state_read["summary"]["quality_requirement"] != "degraded-allowed":
    fail("state-read should expose T2 degraded-allowed truth")
if state_read["summary"]["task_policy_status"] != "ready" or state_read["summary"]["product_gate_status"] != "ready":
    fail("state-read should expose ready persisted verdict statuses for the degraded-ready fixture")
if state_read["summary"]["execution_closeout_status"] != "blocked" or state_read["summary"]["ready_for_execution_slice_done"] is not False:
    fail("state-read should expose blocked execution_closeout before real closeout evidence is written")

artifact_check = run_json([str(root / "scripts" / "check-artifact-schemas.sh"), "--task-id", "smoke-sprint"])
require_keys(artifact_check, ("task_id", "checked", "artifacts", "errors", "valid", "execution_closeout", "semantic_valid", "ready_for_execution_slice_done"))
if not artifact_check["valid"]:
    fail(f"artifact schema check failed: {artifact_check['errors']}")
if artifact_check["semantic_valid"]:
    fail("artifact schema semantic_valid should be false before closeout is completed")
if artifact_check["execution_closeout"]["status"] != "blocked":
    fail("artifact schema should expose blocked execution_closeout before closeout is completed")

for archived_task in ("dd-hermes-anchor-governance-v1", "dd-hermes-independent-quality-seat-v1"):
    archived_check = run_json([str(root / "scripts" / "check-artifact-schemas.sh"), "--task-id", archived_task])
    if not archived_check["valid"] or not archived_check["semantic_valid"]:
        fail(f"archived task schema regression for {archived_task}: {archived_check}")

for no_execution_task in ("dd-hermes-backlog-truth-hygiene-v1", "dd-hermes-s5-2expert-20260416"):
    no_execution_state = run_json([str(root / "scripts" / "state-read.sh"), "--task-id", no_execution_task])
    if no_execution_state["summary"]["task_class_bucket"] != "no-execution":
        fail(f"{no_execution_task} should stay in the no-execution bucket")
    if no_execution_state["summary"]["execution_closeout_status"] != "not-required" or no_execution_state["summary"]["ready_for_execution_slice_done"] is not True:
        fail(f"{no_execution_task} should expose not-required execution_closeout truth")
    no_execution_check = run_json([str(root / "scripts" / "check-artifact-schemas.sh"), "--task-id", no_execution_task])
    if not no_execution_check["valid"] or not no_execution_check["semantic_valid"]:
        fail(f"{no_execution_task} should remain schema-valid after no-execution normalization")
    if no_execution_check["execution_closeout"]["status"] != "not-required" or not no_execution_check["ready_for_execution_slice_done"]:
        fail(f"{no_execution_task} should report not-required closeout semantics")

state["git"]["latest_commit"] = "1234567890abcdef1234567890abcdef12345678"
(root / "workspace" / "state" / "smoke-sprint" / "state.json").write_text(json.dumps(state, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
for expert in ("expert-a", "expert-b", "expert-c"):
    closeout_path = root / "workspace" / "closeouts" / f"smoke-sprint-{expert}.md"
    closeout_path.write_text(f"""---
schema_version: 2
task_id: smoke-sprint
from: {expert}
to: lead
scope: smoke-sprint execution slice closeout for {expert}
execution_commit: 1234567890abcdef1234567890abcdef12345678
state_path: workspace/state/smoke-sprint/state.json
context_path: workspace/state/smoke-sprint/context.json
runtime_path: workspace/state/smoke-sprint/runtime.json
verified_steps:
  - bash tests/smoke.sh workflow
verified_files:
  - scripts/dispatch-create.sh
quality_review_status: degraded-approved
quality_findings_summary:
  - Degraded review accepted with explicit ack because independent skeptic is unavailable in the fixture.
open_risks:
  - none
next_actions:
  - integrate fixture changes
---

# Execution Closeout

## Context

Smoke fixture closeout for {expert} upgraded to semantic completion state.

## Required Fields

- `task_id`
- `from`
- `to`
- `scope`
- `execution_commit`
- `state_path`
- `context_path`
- `runtime_path`
- `verified_steps`
- `verified_files`
- `quality_review_status`
- `quality_findings_summary`
- `open_risks`
- `next_actions`

## Completion

- Completed the smoke execution slice and wrote a real execution commit.

## Verification

- Ran `bash tests/smoke.sh workflow` and verified the dispatch fixture paths.

## Quality Review

- Quality anchor accepted a degraded review for fixture purposes after explicit degraded acknowledgement.

## Open Questions

- None.
""", encoding="utf-8")
artifact_check = run_json([str(root / "scripts" / "check-artifact-schemas.sh"), "--task-id", "smoke-sprint"])
if not artifact_check["semantic_valid"] or not artifact_check["ready_for_execution_slice_done"]:
    fail(f"artifact semantic check failed after closeout completion: {artifact_check['semantic_errors']}")
subprocess.run(
    [str(root / "scripts" / "state-update.sh"), "--task-id", "smoke-sprint"],
    input=json.dumps({"note": "refresh execution closeout verdict after semantic closeout fixture"}),
    text=True,
    capture_output=True,
    check=True,
)
state_after_closeout = json.loads((root / "workspace" / "state" / "smoke-sprint" / "state.json").read_text(encoding="utf-8"))
if state_after_closeout["verdicts"]["execution_closeout"]["status"] != "ready" or state_after_closeout["verdicts"]["execution_closeout"]["ready"] is not True:
    fail("state should persist ready execution_closeout after closeout refresh")

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
{"skeptics":["lead"],"degraded_ack_by":"","degraded_ack_at":"","note":"endpoint router degraded skeptic fixture"}
EOF

  local state
  state=$("$ROOT/scripts/coordination-endpoint.sh" --task-id smoke-sprint --endpoint state.read)
  assert_json_field "$state" "'state' in data and 'summary' in data and data['summary']['has_supervisor'] is True"
  assert_json_field "$state" "data['summary']['independent_skeptic'] is False and data['summary']['degraded_ack_ready'] is False and 'supervisor_skeptic_overlap:lead' in data['summary']['role_conflicts']"

  local context
  context=$("$ROOT/scripts/coordination-endpoint.sh" --task-id smoke-sprint --endpoint context.build --agent-role commander --memory-limit 5)
  assert_json_field "$context" "data['context_path'].endswith('context.json') and data['runtime_path'].endswith('runtime.json') and data['state_path'].endswith('state.json')"
  assert_json_field "$context" "data['memory_count'] >= 1 and data['handoff_count'] >= 1 and data['exploration_count'] >= 1"

  set +e
  "$ROOT/scripts/coordination-endpoint.sh" --task-id smoke-sprint --endpoint dispatch.create >/tmp/dd-hermes-endpoint-degraded.json
  local status=$?
  set -e
  [[ $status -eq 2 ]]
  python3 - <<'PY' /tmp/dd-hermes-endpoint-degraded.json
import json, sys
payload = json.loads(open(sys.argv[1], encoding="utf-8").read())
assert payload["blocked"] is True
assert "degraded supervision" in payload["error"]
PY

  "$ROOT/scripts/coordination-endpoint.sh" --task-id smoke-sprint --endpoint state.update <<'EOF' >/dev/null
{"degraded_ack_by":"lead","degraded_ack_at":"2026-04-17T10:00:00Z","note":"endpoint degraded ack fixture"}
EOF

  local dispatch
  dispatch=$("$ROOT/scripts/coordination-endpoint.sh" --task-id smoke-sprint --endpoint dispatch.create)
  assert_json_field "$dispatch" "data['task_id'] == 'smoke-sprint' and 'summary' in data and data['summary']['supervisor_count'] >= 1 and data['summary']['executor_count'] >= 2 and data['summary']['skeptic_count'] >= 1"
  assert_json_field "$dispatch" "data['independent_skeptic'] is False and data['degraded'] is True and data['degraded_ack_ready'] is True and 'supervisor_skeptic_overlap:lead' in data['role_conflicts']"

  local closeout
  closeout=$("$ROOT/scripts/coordination-endpoint.sh" --task-id smoke-sprint --endpoint closeout.check)
  assert_json_field "$closeout" "data['task_id'] == 'smoke-sprint' and data['valid'] is True and 'execution_closeout' in data and 'semantic_valid' in data and 'ready_for_execution_slice_done' in data"

  set +e
  "$ROOT/scripts/coordination-endpoint.sh" --task-id smoke-sprint --endpoint unknown >/dev/null
  local status=$?
  set -e
  [[ $status -eq 3 ]]

  local lease
  lease=$("$ROOT/scripts/coordination-endpoint.sh" --task-id smoke-sprint --endpoint lease.check)
  assert_json_field "$lease" "'lease_status' in data and 'exceeded' in data and 'lease_conflict' in data"

  local analytics
  analytics=$("$ROOT/scripts/coordination-endpoint.sh" --task-id smoke-sprint --endpoint session.analytics)
  assert_json_field "$analytics" "'session_count' in data and 'tool_usage' in data and 'kb_suggestions' in data"

  local decay
  decay=$("$ROOT/scripts/coordination-endpoint.sh" --task-id smoke-sprint --endpoint memory.decay)
  assert_json_field "$decay" "'candidates' in data and 'count' in data and 'max_age_days' in data"

  local compact
  compact=$("$ROOT/scripts/coordination-endpoint.sh" --task-id smoke-sprint --endpoint journal.compact)
  assert_json_field "$compact" "'compacted' in data and 'kept' in data and 'dry_run' in data and data['dry_run'] is True"

  local residue_dir="$ROOT/workspace/state/endpoint-residue-fixture"
  mkdir -p "$residue_dir"
  local landing_doc="$ROOT/指挥文档/06-一期PhaseDone审计.md"
  local landing_backup
  landing_backup=$(mktemp)
  cp "$landing_doc" "$landing_backup"
  trap 'cp "$landing_backup" "$landing_doc"; rm -f "$landing_backup"; rm -rf "$residue_dir"; trap - RETURN' RETURN
  cat > "$residue_dir/state.json" <<'EOF'
{
  "task_id": "endpoint-residue-fixture",
  "status": "initialized",
  "mode": "planning",
  "openspec": {
    "stage": "proposal",
    "proposal_path": "",
    "design_path": "",
    "task_path": "",
    "archive_path": ""
  }
}
EOF

  local successor_audit
  successor_audit=$("$ROOT/scripts/coordination-endpoint.sh" --task-id smoke-sprint --endpoint successor.audit)
  assert_json_field "$successor_audit" "'verdict' in data and 'reasons' in data and 'live_committed_candidates' in data and 'local_residue' in data and 'archived_task_count' in data"
  assert_json_field "$successor_audit" "any(item['task_id'] == 'endpoint-residue-fixture' for item in data['local_residue'])"

  python3 - "$landing_doc" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
match = re.match(r"---\n(.*?)\n---\n", text, re.S)
if not match:
    raise SystemExit("frontmatter missing")
lines = []
for line in match.group(1).splitlines():
    if line.startswith("current_mainline_task_id:"):
        lines.append("current_mainline_task_id: endpoint-residue-fixture")
    elif line.startswith("current_mainline_doc:"):
        lines.append("current_mainline_doc:")
    else:
        lines.append(line)
updated = "---\n" + "\n".join(lines) + "\n---\n" + text[match.end():]
path.write_text(updated, encoding="utf-8")
PY

  local residue_mainline
  residue_mainline=$("$ROOT/scripts/coordination-endpoint.sh" --task-id smoke-sprint --endpoint successor.audit)
  assert_json_field "$residue_mainline" "data['verdict'] == 'working-tree-mainline-only' and 'current_mainline_not_committed' in data['reasons']"
}

case "$SECTION" in
  all)
    run_hooks
    run_memory
    run_workflow
    run_git_management
    run_discussion_textbook
    run_dispatch
    run_context_state
    run_verify
    run_entry
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
  discussion)
    run_workflow
    run_discussion_textbook
    ;;
  context)
    run_workflow
    run_dispatch
    run_context_state
    ;;
  verify)
    run_workflow
    run_dispatch
    run_context_state
    run_verify
    ;;
  entry) run_entry ;;
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
