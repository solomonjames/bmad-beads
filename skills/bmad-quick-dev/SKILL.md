---
name: bmad-quick-dev
description: Use when ready to implement a feature — flexible implementation flow with mode detection, execution, self-check, adversarial review, and finding resolution
---

# Quick Dev

Implementation flow that handles both spec-driven (Mode A) and direct instruction (Mode B) development. Includes execution, self-check, adversarial review, and finding resolution.

**Persona:** Adopt the Barry (Solo Dev) persona from `bmad:bmad-personas` — read `quick-flow-solo-dev.md`. Direct, confident, ruthless efficiency.

## Beads Integration (Optional)

If `{ticket_id}` is set and beads is active, the ticket is the primary data source. When the ticket contains a ready-for-dev spec (from quick-spec), all spec content is loaded from ticket fields — no local files needed.

### Detection
1. Check if `{ticket_id}` is set (non-empty). If not, set `{beads_active}` to false.
2. Verify beads is installed: `which bd`. If not found, warn user ("beads not installed, proceeding without ticket tracking"), set `{beads_active}` to false.
3. Ensure working directory: Before running `bd` commands, verify you are within the project directory containing `.beads/`. If session context provides a beads project root, `cd` to it.
4. Load ticket: `bd show {ticket_id} --json`. If the ticket doesn't exist, warn and set `{beads_active}` to false.
5. Store the ticket's current `metadata` JSON for read-merge-write operations.

### Ticket-Driven Mode Detection
When `{beads_active}`, check ticket metadata:
- If `metadata.spec_status == "ready-for-dev"` → load spec from ticket fields: `design` (overview), `notes` (technical context), `acceptance_criteria` (ACs), sub-tickets (implementation tasks via `bd list --parent {ticket_id} --json`). Auto-select **Mode A**.
- If `metadata.bmad_phase == "spec"` and `spec_status != "ready-for-dev"` → warn user that spec is incomplete, suggest running `/quick-spec {ticket_id}` first.
- Otherwise → fall through to normal Mode B detection.

### Metadata Read-Merge-Write Pattern
Every metadata update must:
1. Read current metadata: `bd show {ticket_id} --json` → extract `.metadata`
2. Merge new fields into the existing object (never discard existing keys)
3. Write full merged JSON: `bd update {ticket_id} --metadata '{...}'`

## Checklist

Track progress using TodoWrite:

- [ ] Capture baseline commit
- [ ] Detect execution mode — tech-spec vs. direct (or ticket-driven if beads-active)
- [ ] Gather context and confirm plan (Mode B only)
- [ ] Execute implementation — all tasks continuous, track via sub-tickets if beads-active
- [ ] Run 12-point self-check
- [ ] Adversarial review with information asymmetry
- [ ] Human review gate — resolve findings
- [ ] Completion summary — update ticket or local spec, close sub-tickets

---

## Phase 1: Mode Detection

### Capture Baseline Commit
```bash
git rev-parse HEAD
```
Store as `baseline_commit`. If not in a git repo, set to "NO_GIT".

### Load Project Context
Read `project-context.md` if it exists. Note project conventions, patterns, constraints.

### Determine Execution Mode

**If `{beads_active}`:** Check ticket metadata first (see "Ticket-Driven Mode Detection" above) before falling through to normal detection.

**Mode A — Tech Spec (structured):**
- Triggers when user provides a tech-spec path, or when `{beads_active}` and ticket has `metadata.spec_status == "ready-for-dev"`
- **From ticket:** Load spec from `design` (overview), `notes` (technical context), `acceptance_criteria` (ACs). List sub-tickets as implementation tasks: `bd list --parent {ticket_id} --json`.
- **From file:** Load the tech-spec, verify it has `status: 'ready-for-dev'`, extract tasks and acceptance criteria.
- **Skip to Phase 3: Execute**

**Mode B — Direct Instructions (ad-hoc):**
- Triggers when no tech-spec is provided (and ticket has no ready spec)
- Parse user's feature description
- Proceed to escalation evaluation

### Escalation Evaluation (Mode B Only)
**REQUIRED SUB-SKILL:** Use `bmad:bmad-complexity-assessment` to evaluate complexity and route appropriately.

If user chooses to escalate:
- **[P] Plan first** → Suggest `bmad:bmad-quick-spec`, then return with tech spec
- **[W] Full BMAD** → Guide to appropriate phase formula

If user chooses **[E] Execute directly** → Continue to Phase 2.

### Phase 1 Sync
If `{beads_active}`:
1. `bd update {ticket_id} --status in_progress`
2. Read-merge-write metadata: merge `{"bmad_phase": "dev", "bmad_step": "mode-detect", "baseline_commit": "{baseline_commit}", "execution_mode": "{mode_a_or_mode_b}"}`
3. `bd comment {ticket_id} "BMAD quick-dev Phase 1 (Mode Detection) complete — {Mode A: tech-spec | Mode B: direct} execution, baseline commit {baseline_commit}"`

---

## Phase 2: Context Gathering (Mode B Only)

Mode A skips this phase entirely — the tech spec IS the context.

### Identify Files to Modify
- Glob/grep for files related to the feature area
- Read key files to understand current implementation
- List all files that need changes and new files to create

### Find Relevant Patterns
- Code style and naming conventions
- Import/export patterns
- Error handling approach
- Test patterns (framework, helpers, factories)
- Database patterns (migrations, models, relationships)

### Note Dependencies
- External libraries needed (check if already installed)
- Internal modules to integrate with
- Config files that need updates

### Create Implementation Plan
- **Tasks:** Ordered list of discrete changes
- **Inferred ACs:** What "done" looks like for each task
- **Order of operations:** Dependency-correct sequence

### Present Plan for Confirmation
Show files, patterns, plan, and acceptance criteria. Ask: "Ready to execute? Adjust anything?"

**Wait for user confirmation before proceeding.**

### Phase 2 Sync (Mode B Only)
If `{beads_active}`:
1. `bd update {ticket_id} --notes "**Implementation Plan:**\n\n{task_list}\n\n**Files to modify:** {files_list}\n\n**Dependencies:** {dependencies}"`
2. `bd update {ticket_id} --acceptance-criteria "{inferred_acceptance_criteria}"`
3. Read-merge-write metadata: merge `{"bmad_step": "context-gather"}`
4. `bd comment {ticket_id} "BMAD quick-dev Phase 2 (Context Gathering) complete — {task_count} tasks planned, {file_count} files identified"`

---

## Phase 3: Execute

**METHODOLOGY:** This phase follows TDD (test-driven development). Read `bmad:bmad-tdd` for the full methodology, rationalizations table, and red flags. The core rule: **no production code without a failing test first.**

**Exception:** If the project has no test framework or the task is configuration-only, skip TDD steps (3-5) and implement directly. Note the exception in the phase sync comment.

### Execution Loop
For each task in the plan/spec:

1. **Start task** — If `{beads_active}` and tasks are sub-tickets: `bd update {sub_id} --status in_progress`
2. **Load context** — Read relevant files, review patterns, identify test file locations and testing conventions
3. **RED — Write failing test** — Write one minimal test capturing the expected behavior. Run it. Confirm it **fails** because the feature is missing (not because of errors or typos). If it passes immediately, you're testing existing behavior — fix the test.
4. **GREEN — Minimal implementation** — Write the simplest code to make the failing test pass. Run all tests. Confirm everything is green.
5. **REFACTOR** — Clean up while keeping tests green. Remove duplication, improve names. Do not add behavior.
6. **Mark complete** — Check off task. If `{beads_active}` and tasks are sub-tickets: `bd close {sub_id}`
7. **Continue immediately** — Next task without pausing

### Critical Rules
- **Test first** — Every behavioral change starts with a failing test. No exceptions without user approval. See `bmad:bmad-tdd` for the full Iron Law.
- **Continuous execution** — Do NOT stop between tasks for approval
- **Follow patterns** — Match existing codebase conventions exactly
- **No gold-plating** — Implement exactly what's specified, nothing more

### Halt Conditions
ONLY halt for:
- 3 consecutive failures on the same task
- Tests failing with no obvious fix
- Blocking dependency (missing package, API, etc.)
- Ambiguity requiring user decision

Do NOT halt for minor warnings, optional improvements, or deprecation notices.

### Phase 3 Sync
If `{beads_active}` (after ALL tasks complete, not per-task):
1. Read-merge-write metadata: merge `{"bmad_step": "execute"}`
2. `bd comment {ticket_id} "BMAD quick-dev Phase 3 (Execute) complete — {completed_count}/{total_count} tasks implemented"`

---

## Phase 4: Self-Check

### 12-Point Self-Audit
Verify each item honestly:

**Tasks:**
1. All tasks marked complete
2. No tasks skipped without documented reason
3. Implementation matches task descriptions (no drift)

**Tests:**
4. All existing tests still pass
5. New tests written for new behavior
6. Test coverage covers happy path
7. Test coverage covers error/edge cases

**Acceptance Criteria:**
8. Each AC is demonstrably satisfied
9. Edge cases from ACs are handled
10. Authorization/validation checks in place where specified

**Patterns:**
11. Code follows existing codebase conventions
12. No code smells introduced (duplication, god objects, deep nesting)

### Handle Failures
Fix immediately if possible. Re-run affected tests. If not fixable, document and flag for user.

### Update Spec Artifact

**If `{beads_active}`:**
- Read-merge-write metadata: merge `{"bmad_step": "self-check"}`
- `bd comment {ticket_id} "BMAD quick-dev Phase 4 (Self-Check) complete — {pass_count}/12 checks passing, {new_test_count} new tests"`

**Otherwise (Mode A with local tech-spec):**
- Update status to "Implementation Complete", mark all tasks `[x]`, add implementation notes if approach deviated.

### Present Summary
- Tasks completed: N/N
- Tests: X new, Y total passing
- Files modified/created
- Checklist: all items passing (or flagged)

---

## Phase 5: Adversarial Review

**REQUIRED SUB-SKILL:** Use `bmad:bmad-adversarial-review` for the full review procedure.

### Construct Diff
From `baseline_commit`:
```bash
git diff {baseline_commit}
```
Include new files. Use NO_GIT fallback if needed.

### Invoke Review
Use a subagent (Task tool) for true information asymmetry. The reviewer sees ONLY the diff and the reviewer prompt from `adversarial-reviewer-prompt.md` — NO spec, NO conversation history.

### Process and Present Findings
Number findings (F1, F2...) with severity and validity ratings. Order by severity. Flag zero findings as suspicious.

### Phase 5 Sync
If `{beads_active}`:
1. Read-merge-write metadata: merge `{"bmad_step": "adversarial-review", "finding_count": {total_findings}}`
2. `bd comment {ticket_id} "BMAD quick-dev Phase 5 (Adversarial Review) complete — {finding_count} findings ({critical_count} critical, {warning_count} warnings, {info_count} info)"`

---

## Phase 6: Resolve Findings (Human Gate)

### Present Options
- **[W] Walk through** — Iterate each finding: Fix / Skip / Discuss
- **[F] Fix automatically** — Fix all "Real" findings, skip Noise/Undecided
- **[S] Skip** — Acknowledge and proceed

### Apply Resolution
- **Walk through:** Per-finding decision with test re-runs after fixes
- **Fix automatically:** Filter to "Real" only, apply, re-run all tests, report
- **Skip:** Note findings for future reference

### Update Spec Artifact

**If `{beads_active}`:**
1. Read-merge-write metadata: merge `{"bmad_phase": "done", "bmad_step": "resolve-findings", "findings_fixed": {fixed_count}, "findings_skipped": {skipped_count}, "spec_status": "completed"}`
2. `bd comment {ticket_id} "BMAD quick-dev Phase 6 (Resolve Findings) complete — implementation done. {fixed_count} findings fixed, {skipped_count} skipped. All tests passing."`
3. Ask user: "Implementation is complete. Close this ticket? (`bd close {ticket_id} --reason 'Implementation complete — {summary}'`)"

**Otherwise (Mode A with local tech-spec):**
- Update status to "Completed". Add review notes: finding count, fixed count, skipped count.

### Completion Summary
- Files modified/created
- Tests: all passing (count)
- Review: N findings, M fixed, K skipped
- Status: Complete

Suggest: commit, run additional tests, or start a new workflow.
