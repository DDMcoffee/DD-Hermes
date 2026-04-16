#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

task_id=""
owner="lead"
experts=""
current_focus="bootstrap"
discussion_policy="auto"
task_class="T2"
quality_requirement=""
task_class_rationale=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --task-id) task_id="$2"; shift 2 ;;
    --owner) owner="$2"; shift 2 ;;
    --experts) experts="$2"; shift 2 ;;
    --current-focus) current_focus="$2"; shift 2 ;;
    --discussion-policy) discussion_policy="$2"; shift 2 ;;
    --task-class) task_class="$2"; shift 2 ;;
    --quality-requirement) quality_requirement="$2"; shift 2 ;;
    --task-class-rationale) task_class_rationale="$2"; shift 2 ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

if [[ -z "$task_id" || -z "$experts" ]]; then
  json_out '{"error":"task_id and experts are required"}'
  exit 3
fi

repo=$(shared_repo_root)
mkdir -p "$repo/workspace/contracts" "$repo/workspace/handoffs" "$repo/workspace/exploration" "$repo/workspace/closeouts" "$repo/workspace/state" "$repo/openspec/proposals" "$repo/openspec/designs" "$repo/openspec/tasks" "$repo/openspec/archive"
contract_path="$repo/workspace/contracts/$task_id.md"
exploration_path="$repo/workspace/exploration/exploration-lead-$task_id.md"
proposal_path="$repo/openspec/proposals/$task_id.md"
contract_template="$repo/.codex/templates/SPRINT-CONTRACT.md"
handoff_template="$repo/.codex/templates/HANDOFF-LEAD.md"
closeout_template="$repo/.codex/templates/EXECUTION-CLOSEOUT.md"
exploration_template="$repo/.codex/templates/EXPLORATION-LOG.md"
proposal_template="$repo/.codex/templates/OPENSPEC-PROPOSAL.md"

handoff_json=$(python3 - \
  "$repo" \
  "$task_id" \
  "$owner" \
  "$experts" \
  "$task_class" \
  "$quality_requirement" \
  "$task_class_rationale" \
  "$contract_path" \
  "$exploration_path" \
  "$proposal_path" \
  "$contract_template" \
  "$handoff_template" \
  "$closeout_template" \
  "$exploration_template" \
  "$proposal_template" <<'PY'
import json
import sys
from pathlib import Path

repo = Path(sys.argv[1]).resolve()
task_id = sys.argv[2]
owner = sys.argv[3]
experts_csv = sys.argv[4]
task_class = sys.argv[5]
quality_requirement = sys.argv[6]
task_class_rationale = sys.argv[7]
contract_path = Path(sys.argv[8])
exploration_path = Path(sys.argv[9])
proposal_path = Path(sys.argv[10])
contract_template = Path(sys.argv[11])
handoff_template = Path(sys.argv[12])
closeout_template = Path(sys.argv[13])
exploration_template = Path(sys.argv[14])
proposal_template = Path(sys.argv[15])

expert_list = [item.strip() for item in experts_csv.split(",") if item.strip()]
task_class_defaults = {
    "T0": ("degraded-allowed", "治理/裁决/归档/trace 收口任务，不进入 execution slice。"),
    "T1": ("degraded-allowed", "单线程探查任务，只核对事实，不进入实现面。"),
    "T2": ("degraded-allowed", "边界清晰、低风险写集的实现切片，允许 degraded 但必须显式确认。"),
    "T3": ("requires-independent", "控制面、架构、策略或高回归风险任务，默认要求独立质量位。"),
    "T4": ("requires-independent", "需要双证据链的 schema/protocol/并发/集成任务，默认要求独立质量位。"),
}
default_requirement, default_rationale = task_class_defaults.get(task_class, ("", ""))
if not quality_requirement:
    quality_requirement = default_requirement
if not task_class_rationale:
    task_class_rationale = default_rationale


def load_template(path: Path):
    text = path.read_text(encoding="utf-8")
    front_keys = []
    body = text
    if text.startswith("---\n"):
        _, frontmatter, body = text.split("---\n", 2)
        for line in frontmatter.splitlines():
            if not line.strip() or line.startswith("  - "):
                continue
            key = line.split(":", 1)[0].strip()
            if key and key not in front_keys:
                front_keys.append(key)
    body_lines = body.strip().splitlines()
    title = next((line for line in body_lines if line.startswith("# ")), "")
    headings = [line[3:] for line in body_lines if line.startswith("## ")]
    return {"front_keys": front_keys, "title": title, "headings": headings}


def render_doc(template, frontmatter=None, sections=None):
    frontmatter = frontmatter or {}
    sections = sections or {}
    lines = []
    if template["front_keys"]:
        lines.append("---")
        for key in template["front_keys"]:
            value = frontmatter.get(key, "")
            if isinstance(value, list):
                lines.append(f"{key}:")
                lines.extend(f"  - {item}" for item in value)
            else:
                lines.append(f"{key}: {value}")
        lines.extend(["---", ""])
    if template["title"]:
        lines.extend([template["title"], ""])
    for heading in template["headings"]:
        lines.extend([f"## {heading}", ""])
        content = sections.get(heading, "")
        if isinstance(content, list):
            lines.extend(content or ["- None."])
        elif content:
            lines.append(content)
        lines.append("")
    return "\n".join(lines).rstrip() + "\n"


contract = render_doc(
    load_template(contract_template),
    frontmatter={
        "schema_version": "2",
        "task_id": task_id,
        "owner": owner,
        "experts": expert_list,
        "product_goal": f"Advance DD Hermes through task {task_id} without drifting from the current product focus.",
        "user_value": "Keep the next DD Hermes slice connected to a user-visible or operator-visible outcome instead of generic busywork.",
        "task_class": task_class,
        "quality_requirement": quality_requirement,
        "task_class_rationale": task_class_rationale,
        "non_goals": ["Do not expand into unrelated runtime, provider, or gateway work."],
        "product_acceptance": ["The task remains traceable to one clear product outcome and one explicit non-goal boundary."],
        "drift_risk": "This task could drift into generic infrastructure cleanup if the product outcome stops being explicit.",
        "acceptance": ["Complete sprint artifacts and verification."],
        "blocked_if": ["Missing repo facts or missing verification."],
        "memory_reads": ["memory/world/no-destruction-without-confirmation.md"],
        "memory_writes": [f"memory/task/{task_id}.md"],
    },
    sections={
        "Context": "Initialize the sprint and bind all collaboration artifacts.",
        "Scope": [
            "- In scope: contract, handoffs, exploration log, openspec proposal.",
            "- Out of scope: implementation details outside this sprint.",
        ],
        "Required Fields": [
            "- `task_id`",
            "- `owner`",
            "- `experts`",
            "- `product_goal`",
            "- `user_value`",
            "- `task_class`",
            "- `quality_requirement`",
            "- `task_class_rationale`",
            "- `non_goals`",
            "- `product_acceptance`",
            "- `drift_risk`",
            "- `acceptance`",
            "- `blocked_if`",
            "- `memory_reads`",
            "- `memory_writes`",
        ],
        "Acceptance": ["- All artifacts exist and are linked by task id."],
        "Product Gate": [
            "- The task must remain tied to one clear DD Hermes product outcome.",
            f"- This bootstrap defaults to `{task_class}` with `{quality_requirement}` so later gates know the intended quality-seat bar.",
            "- If the slice starts expanding beyond the declared non-goals, stop and recalibrate before implementation.",
        ],
        "Verification": [
            f"- Commands: `scripts/test-workflow.sh --task-id {task_id}`",
            "- User-visible proof: workflow test passes and bootstrap artifacts exist on disk.",
        ],
        "Open Questions": ["- None at bootstrap time."],
    },
)
contract_path.write_text(contract, encoding="utf-8")

handoff_paths = []
handoff_tpl = load_template(handoff_template)
closeout_paths = []
closeout_tpl = load_template(closeout_template)
for expert in expert_list:
    handoff_path = repo / "workspace" / "handoffs" / f"{task_id}-lead-to-{expert}.md"
    handoff = render_doc(
        handoff_tpl,
        frontmatter={
            "schema_version": "2",
            "from": owner,
            "to": expert,
            "scope": f"{task_id} bootstrap artifact slice",
            "product_rationale": f"This slice should advance task {task_id} in a way a DD Hermes maintainer can explain and verify.",
            "goal_drift_risk": "The slice could drift into generic control-plane churn if it stops serving the declared product goal.",
            "user_visible_outcome": "A maintainer can point to one concrete outcome instead of scattered partial work.",
            "files": [
                f"workspace/contracts/{task_id}.md",
                f"openspec/proposals/{task_id}.md",
                f"workspace/state/{task_id}/state.json",
            ],
            "decisions": [
                "Follow the sprint contract and spec-first rule.",
                "Prefer repo templates and existing scripts over ad-hoc scaffolding.",
            ],
            "risks": [
                "Do not change policy through memory writes.",
                "Only write execution evidence back to commander-side state.",
            ],
            "next_checks": [
                "Run verification before completion.",
                "Write back expert handoff and verification evidence.",
            ],
        },
        sections={
            "Context": f"Expert {expert} owns the bootstrap execution slice for sprint {task_id} inside an isolated worktree.",
            "Required Fields": [
                "- `from`",
                "- `to`",
                "- `scope`",
                "- `product_rationale`",
                "- `goal_drift_risk`",
                "- `user_visible_outcome`",
                "- `files`",
                "- `decisions`",
                "- `risks`",
                "- `next_checks`",
            ],
            "Acceptance": [
                "- Keep the sprint bootstrap artifacts task-bound, template-aligned, and ready for execution handoff.",
            ],
            "Product Check": [
                "- Confirm the slice still serves the stated product goal and does not expand into the declared non-goals.",
            ],
            "Verification": [
                "- State commands and evidence expected from expert before handoff return.",
                "- At minimum, include the workflow test result and the changed file list.",
            ],
            "Open Questions": [
                "- Final implementation files depend on the assigned execution slice and will be reported back by the expert.",
            ],
        },
    )
    handoff_path.write_text(handoff, encoding="utf-8")
    handoff_paths.append(str(handoff_path))

    closeout_path = repo / "workspace" / "closeouts" / f"{task_id}-{expert}.md"
    closeout = render_doc(
        closeout_tpl,
        frontmatter={
            "schema_version": "2",
            "task_id": task_id,
            "from": expert,
            "to": owner,
            "scope": f"{task_id} execution slice closeout",
            "execution_commit": "",
            "state_path": f"workspace/state/{task_id}/state.json",
            "context_path": f"workspace/state/{task_id}/context.json",
            "runtime_path": f"workspace/state/{task_id}/runtime.json",
            "verified_steps": [f"./scripts/test-workflow.sh --task-id {task_id}"],
            "verified_files": [f"workspace/contracts/{task_id}.md"],
            "quality_review_status": "pending",
            "quality_findings_summary": ["Awaiting quality anchor review after execution evidence is written."],
            "open_risks": ["None at bootstrap time."],
            "next_actions": ["Update with execution evidence before handing back to lead."],
        },
        sections={
            "Context": f"Execution closeout placeholder for {expert} on task {task_id}.",
            "Required Fields": [
                "- `task_id`",
                "- `from`",
                "- `to`",
                "- `scope`",
                "- `execution_commit`",
                "- `state_path`",
                "- `context_path`",
                "- `runtime_path`",
                "- `verified_steps`",
                "- `verified_files`",
                "- `quality_review_status`",
                "- `quality_findings_summary`",
                "- `open_risks`",
                "- `next_actions`",
            ],
            "Completion": [
                "- Replace this placeholder with completed outcomes for the execution slice.",
            ],
            "Verification": [
                "- Add exact commands and pass/fail evidence before handoff return.",
            ],
            "Quality Review": [
                "- Record the quality anchor judgment, concrete findings, and suggested fixes before final integration.",
            ],
            "Open Questions": [
                "- List unresolved integration questions for lead review.",
            ],
        },
    )
    closeout_path.write_text(closeout, encoding="utf-8")
    closeout_paths.append(str(closeout_path))

exploration = render_doc(
    load_template(exploration_template),
    sections={
        "Context": [
            f"- Task: {task_id}",
            f"- Role: {owner}",
            "- Status: IN_PROGRESS",
        ],
        "Facts": [
            "- Sprint bootstrap initialized.",
            "- Contract, lead handoff, proposal, and task state are expected to be materialized together.",
        ],
        "Hypotheses": [
            "- Later execution slices can reuse these bootstrap artifacts without redefining task boundaries.",
        ],
        "Evidence": [
            f"- Generated by `scripts/sprint-init.sh --task-id {task_id}`.",
            f"- Contract path: workspace/contracts/{task_id}.md",
            f"- Proposal path: openspec/proposals/{task_id}.md",
        ],
        "Acceptance": [
            "- Establish a traceable starting point for lead and expert collaboration.",
        ],
        "Verification": [
            f"- Confirm `scripts/test-workflow.sh --task-id {task_id}` passes after initialization.",
        ],
        "Open Questions": [
            "- Execution-slice-specific file ownership will be refined by later handoffs.",
        ],
    },
)
exploration_path.write_text(exploration, encoding="utf-8")

proposal = render_doc(
    load_template(proposal_template),
    frontmatter={
        "status": "proposed",
        "owner": owner,
        "scope": task_id,
        "decision_log": ["Bootstrap coordination artifacts before implementation."],
        "checks": [f"scripts/test-workflow.sh --task-id {task_id}"],
        "links": [
            f"workspace/contracts/{task_id}.md",
            f"workspace/exploration/exploration-lead-{task_id}.md",
        ],
    },
    sections={
        "What": f"Initialize sprint {task_id} with task-bound collaboration artifacts.",
        "Why": "Create the minimum coordination surface before implementation begins.",
        "Non-goals": "- Runtime implementation details outside the sprint bootstrap.",
        "Acceptance": "- Contract, handoffs, exploration log, proposal, and state all exist and point to the same task id.",
        "Verification": f"- Run `scripts/test-workflow.sh --task-id {task_id}`.",
    },
)
proposal_path.write_text(proposal, encoding="utf-8")

print(json.dumps({
    "handoff_paths": handoff_paths,
    "closeout_paths": closeout_paths,
}, ensure_ascii=False))
PY
)

state_json=$("$SCRIPT_DIR/state-init.sh" --task-id "$task_id" --owner "$owner" --experts "$experts" --current-focus "$current_focus" --discussion-policy "$discussion_policy")
payload=$(python3 - <<'PY' "$contract_path" "$exploration_path" "$proposal_path" "$handoff_json" "$state_json"
import json
import sys

contract_path, exploration_path, proposal_path, handoff_json, state_json = sys.argv[1:]
handoff_data = json.loads(handoff_json)
print(json.dumps({
    "contract_path": contract_path,
    "handoff_paths": handoff_data["handoff_paths"],
    "closeout_paths": handoff_data["closeout_paths"],
    "exploration_path": exploration_path,
    "openspec_path": proposal_path,
    "state_path": json.loads(state_json)["state_path"],
}, ensure_ascii=False))
PY
)
json_out "$payload"
