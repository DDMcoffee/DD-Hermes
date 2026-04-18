---
id: "xc-baoxiao-sample-data-location"
type: "fact"
content: "Real XC-BaoXiaoAuto invoice/receipt samples live under the repo's input/ directory in employee-named subdirs; these are gitignored and must never be copied into DD Hermes tracked files."
source: "XC-BaoXiaoAuto/.gitignore lines 32-35 and user confirmation on 2026-04-18"
scope: "xc-baoxiao cross-repo sample-data handling"
confidence: "1.0"
created_at: "2026-04-18T08:30:00Z"
last_validated_at: "2026-04-18T08:30:00Z"
decay_policy: "manual"
status: "active"
---

# Memory Card

## Evidence

- `XC-BaoXiaoAuto/.gitignore:32-35` ignores `input`, `input-<employee>`, `A input-<employee>`, `output`, `A output-<employee>`.
- User confirmed on 2026-04-18 that `XC-BaoXiaoAuto/input/` contains real invoice files organized by employee name.
- Contents contain real PII: employee names, invoice numbers, amounts, merchant info.

## Safe-handling rules for DD Hermes

- MUST NOT read individual file contents from `XC-BaoXiaoAuto/input/` or `output/` into any DD Hermes tracked artifact (contracts / state / handoffs / memory / plans).
- MUST NOT embed real employee names, invoice numbers, or amounts in any DD Hermes tracked artifact.
- MAY reference path with placeholder form: `$XC_INPUT_ROOT/<employee_dir>/` — never real directory names.
- Python worker tests inside XC-BaoXiaoAuto MAY read real samples directly; that happens inside target_repo and doesn't leak into DD Hermes.
- If a slice needs real samples for verification (e.g. worker OCR slice), the verification artifact stays inside XC-BaoXiaoAuto and only a redacted summary (sample-count / pass-rate / no names) crosses back to DD Hermes state.

## When this matters

- M5 slice candidate C (worker adds a new ticket type) — primary consumer of this rule.
- Any future slice touching OCR quality, receipt parsing, or export generation.
- Slice A (web gate green) does not touch samples; rule still applies defensively.
