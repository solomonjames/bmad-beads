---
name: bmad-quick-dev
description: Use when ready to implement a feature — flexible implementation flow with mode detection, execution, self-check, adversarial review, and finding resolution
---

# Quick Dev

Implementation flow that handles both spec-driven (Mode A) and direct instruction (Mode B) development. Includes execution, self-check, adversarial review, and finding resolution.

**Persona:** Adopt the Barry (Solo Dev) persona from `bmad:bmad-personas` — read `quick-flow-solo-dev.md`. Direct, confident, ruthless efficiency.

## Checklist

Track progress using TodoWrite:

- [ ] Capture baseline commit
- [ ] Detect execution mode (tech-spec vs. direct)
- [ ] Gather context and confirm plan (Mode B only)
- [ ] Execute implementation (all tasks, continuous)
- [ ] Run 12-point self-check
- [ ] Adversarial review with information asymmetry
- [ ] Human review gate — resolve findings
- [ ] Completion summary

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

**Mode A — Tech Spec (structured):**
- Triggers when user provides a tech-spec path
- Load the tech-spec, verify it has `status: 'ready-for-dev'`
- Extract tasks and acceptance criteria
- **Skip to Phase 3: Execute**

**Mode B — Direct Instructions (ad-hoc):**
- Triggers when no tech-spec is provided
- Parse user's feature description
- Proceed to escalation evaluation

### Escalation Evaluation (Mode B Only)
**REQUIRED SUB-SKILL:** Use `bmad:bmad-complexity-assessment` to evaluate complexity and route appropriately.

If user chooses to escalate:
- **[P] Plan first** → Suggest `bmad:bmad-quick-spec`, then return with tech spec
- **[W] Full BMAD** → Guide to appropriate phase formula

If user chooses **[E] Execute directly** → Continue to Phase 2.

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

---

## Phase 3: Execute

**REQUIRED SUB-SKILL:** Use `superpowers:test-driven-development` if available for red-green-refactor discipline.

### Execution Loop
For each task in the plan/spec:

1. **Load context** — Read relevant files, review patterns
2. **Implement** — Write code following codebase patterns exactly
3. **Test** — Red-green-refactor: write failing test → make it pass → refactor
4. **Mark complete** — Check off task
5. **Continue immediately** — Next task without pausing

### Critical Rules
- **Continuous execution** — Do NOT stop between tasks for approval
- **Follow patterns** — Match existing codebase conventions exactly
- **Tests are non-negotiable** — Every behavioral change gets a test
- **No gold-plating** — Implement exactly what's specified, nothing more

### Halt Conditions
ONLY halt for:
- 3 consecutive failures on the same task
- Tests failing with no obvious fix
- Blocking dependency (missing package, API, etc.)
- Ambiguity requiring user decision

Do NOT halt for minor warnings, optional improvements, or deprecation notices.

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

### Mode A: Update Tech-Spec
Update status to "Implementation Complete", mark all tasks `[x]`, add implementation notes if approach deviated.

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

### Mode A: Update Tech-Spec
Update status to "Completed". Add review notes: finding count, fixed count, skipped count.

### Completion Summary
- Files modified/created
- Tests: all passing (count)
- Review: N findings, M fixed, K skipped
- Status: Complete

Suggest: commit, run additional tests, or start a new workflow.
