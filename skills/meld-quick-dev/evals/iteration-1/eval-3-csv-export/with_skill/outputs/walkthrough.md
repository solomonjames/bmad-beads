# Quick Dev Walkthrough: Add CSV Export

Narrated execution of the `meld-quick-dev` skill against the provided tech spec.

---

## Progress Tracking (TaskCreate)

Before any work begins, I create the six tasks defined in the skill:

| # | Subject | Status |
|---|---------|--------|
| 1 | Setup and detect mode | pending |
| 2 | Gather context and confirm plan | pending |
| 3 | Execute implementation | pending (blocked by 1 or 2) |
| 4 | Verify and self-check | pending (blocked by 3) |
| 5 | Adversarial review and resolve | pending (blocked by 4) |
| 6 | Write completion summary | pending (blocked by 5) |

---

## Phase 1: Setup & Mode Detection

**Task 1 marked `in_progress`.**

### Capture Baseline Commit

Run `git rev-parse HEAD` and store the result as `baseline_commit`. For this simulation, assume it returns `a1b2c3d`.

### Load Project Context

Check for `project-context.md` in the project root. For this simulation, assume it does not exist. Note that and move on.

### Determine Execution Mode

**Decision: Mode A (Tech Spec / Structured).**

The user explicitly provided an inline tech spec with:
- `status: ready-for-dev` in the frontmatter
- Defined acceptance criteria (3 Given/When/Then statements)
- An explicit task list (5 tasks)

This matches the Mode A trigger: "user provides a tech-spec path" (or in this case, inline spec content) with `status: ready-for-dev`.

I extract from the spec:
- **Tasks (5):**
  1. Create `src/utils/csv-export.ts` with `exportToCsv(data, columns)` function
  2. Add 'Export CSV' button to `src/components/ReportsPage.tsx`
  3. Wire button click to trigger CSV download
  4. Add tests for csv-export utility
  5. Add integration test for export button
- **Acceptance Criteria (3):**
  1. Click 'Export CSV' downloads CSV with all visible report rows
  2. Date columns formatted as YYYY-MM-DD
  3. Empty report exports CSV with only headers

**Because this is Mode A, Phase 2 (Context Gathering) is skipped entirely.** The tech spec IS the context.

### Escalation Evaluation

Skipped. Escalation evaluation is Mode B only.

### Beads Integration

No `{ticket_id}` is set. `{beads_active}` is false. No beads sync occurs.

### Create Worktree

Since beads is not active, I would offer worktree creation as an option. The user did not request one, so I note it and continue. In a real session, I would briefly ask: "Want me to create a worktree for this work, or continue on the current branch?" For this simulation, assume the user declines.

### Phase 1 Completion

**Task 1 marked `completed`.**
**Task 2 marked `completed` immediately** (Mode A note from the skill: "If Mode A, mark task 2 completed immediately").

Stored state:
- `baseline_commit`: `a1b2c3d`
- `execution_mode`: Mode A
- `beads_active`: false

---

## Phase 2: Context Gathering -- SKIPPED

This phase is skipped entirely because we are in Mode A. The skill states: "Mode A skips this phase entirely -- the tech spec IS the context."

No human gate occurs here. In Mode B, this is where the plan would be presented for confirmation. In Mode A, the spec has already been reviewed and approved (it reached `ready-for-dev` status through the spec engineering process).

---

## Phase 3: Execute

**Task 3 marked `in_progress`.**

### TDD Methodology Decision

Before starting, I would examine the project to determine if a test framework exists. I would look for:
- `jest.config.*`, `vitest.config.*`, or similar config files
- A `__tests__` or `*.test.*` or `*.spec.*` pattern in the codebase
- Test-related dependencies in `package.json`

**Simulation assumption:** The project uses Vitest (or Jest) with React Testing Library, based on the TypeScript + React stack implied by `.tsx` files. TDD applies.

### Task Reordering for TDD

The spec lists tasks 4 and 5 as separate "add tests" tasks, but the TDD methodology requires writing tests FIRST. I reorder the execution to follow TDD within each logical unit:

**Reordered execution plan:**
1. **CSV utility (Tasks 1 + 4 merged):** Write tests first, then implement `exportToCsv`
2. **UI integration (Tasks 2 + 3 + 5 merged):** Write integration test first, then add button and wire it up

This reordering is necessary because the skill says "no production code without a failing test first." The original task order (build first, test later) contradicts TDD. I merge them into TDD-compliant units.

### Execution Loop -- Unit 1: CSV Export Utility

**Start task.** Loading context: read existing files in `src/utils/` to understand naming conventions, import patterns, and any existing utility structure. Read `src/components/ReportsPage.tsx` to understand the data shape (what `data` and `columns` look like).

**RED:** Create test file `src/utils/csv-export.test.ts`. Write minimal failing tests:

- Test 1: `exportToCsv` with simple data produces correct CSV string with headers and rows
- Test 2: Date values are formatted as YYYY-MM-DD in output
- Test 3: Empty data array produces CSV with only header row

Run tests. Confirm they fail because `csv-export.ts` does not exist yet. The errors should be import failures or "function not found" -- this confirms the tests are failing for the right reason (missing feature, not broken test).

**GREEN:** Create `src/utils/csv-export.ts` with the `exportToCsv(data, columns)` function. The simplest implementation:
- Accept an array of data objects and a columns configuration
- Generate CSV header row from column definitions
- Map each data row to CSV values, applying YYYY-MM-DD formatting for date columns
- Trigger browser download via Blob + URL.createObjectURL + programmatic anchor click
- Handle empty data case (return/download headers only)

Run all tests. Confirm all three tests pass.

**REFACTOR:** Review the implementation for:
- Proper CSV escaping (values containing commas, quotes, newlines)
- Clean separation between CSV generation and download triggering (so the generation logic is testable without DOM)
- Naming consistency with existing codebase patterns

Run tests again after refactoring. Confirm still green.

**Continue immediately to next unit.**

### Execution Loop -- Unit 2: UI Integration (Button + Wiring)

**Start task.** Load `src/components/ReportsPage.tsx` to understand the component structure, where the button should go, and how data/columns are accessed.

**RED:** Create or update integration test file (e.g., `src/components/ReportsPage.test.tsx`). Write a failing integration test:

- Test: Render ReportsPage with mock data, click 'Export CSV' button, assert that `exportToCsv` was called with the correct data and columns.

Run. Confirm failure: the button does not exist yet, so `screen.getByText('Export CSV')` (or similar) throws.

**GREEN:** Modify `src/components/ReportsPage.tsx`:
- Import `exportToCsv` from `src/utils/csv-export`
- Add an "Export CSV" button in the appropriate location (near other action buttons or in the toolbar area)
- Wire the button's onClick to call `exportToCsv(visibleData, columns)` where `visibleData` and `columns` come from the component's existing state/props

Run all tests (both unit and integration). Confirm everything passes.

**REFACTOR:** Clean up the component -- ensure the button placement follows existing UI patterns, the handler is clean (possibly extracted if the component is large), and imports are organized per project convention.

Run all tests. Confirm green.

**Task 3 marked `completed`.** (3/6 tasks done)

### Parallel Execution Consideration

I considered whether Units 1 and 2 could run in parallel. Unit 2 depends on Unit 1 (it imports `exportToCsv`), so parallel execution is not appropriate here.

### Halt Conditions

None encountered in this simulation. No consecutive failures, no missing dependencies, no ambiguities.

---

## Phase 4: Verify & Self-Check

**Task 4 marked `in_progress`.**

### Skip Conditions Check

Run `git diff --stat a1b2c3d` to assess diff size. This implementation likely touches 4+ files and adds 50+ lines, so it exceeds the trivial threshold (fewer than 20 lines AND fewer than 3 files). Full audit is required.

### Self-Audit Checklist

**Tasks:**
1. All tasks marked complete -- YES. All 5 original tasks are covered (tasks 1+4 merged into Unit 1, tasks 2+3+5 merged into Unit 2, both completed).
2. No tasks skipped without documented reason -- YES. Tasks were reordered for TDD but none were skipped.
3. Implementation matches task descriptions -- YES. `exportToCsv` created in `src/utils/csv-export.ts`, button added to `ReportsPage.tsx`, wiring done, unit tests and integration test written.

**Tests:**
4. All existing tests still pass -- VERIFY by running full test suite.
5. New tests written for new behavior -- YES. 3 unit tests for csv-export, 1 integration test for button.
6. Coverage covers happy path and error/edge cases -- YES. Happy path (normal data), date formatting (edge), empty report (edge) all covered.

**Acceptance Criteria:**
7. AC1 (click exports CSV with visible rows) -- satisfied by button + `exportToCsv` wiring with visible data.
8. AC2 (dates formatted YYYY-MM-DD) -- satisfied by date formatting logic in `exportToCsv`, verified by test.
9. AC3 (empty report exports headers only) -- satisfied by empty-data handling, verified by test.
10. Edge cases from ACs handled -- YES. The three ACs each represent a distinct case, all implemented.

**Patterns:**
11. Code follows existing conventions -- VERIFY by reviewing import style, naming, file locations.
12. No code smells -- VERIFY by reviewing for duplication or unnecessary complexity.

### Verification Gate

Invoke `meld:meld-verification`. This means:
- Run the full test suite fresh: `npm test` (or `npx vitest run`)
- Run the linter: `npm run lint` (or equivalent)
- Run the build: `npm run build`
- Read complete output of all three commands
- Match each passing claim from the audit above to specific evidence in the output

If any claim lacks fresh evidence (e.g., a test I thought I wrote does not appear in output), go back and investigate.

### Handle Failures

If the build or linter reports issues (e.g., unused import, type error), fix immediately and re-run. For this simulation, assume all pass cleanly.

### Present Summary

- Tasks completed: 5/5
- Tests: 4 new, N total passing (where N is existing suite + 4)
- Files created: `src/utils/csv-export.ts`, `src/utils/csv-export.test.ts`
- Files modified: `src/components/ReportsPage.tsx`, `src/components/ReportsPage.test.tsx` (or created if it did not exist)
- Checklist: all 10 items passing

**Task 4 marked `completed`.**

---

## Phase 5: Adversarial Review & Resolution

**Task 5 marked `in_progress`.**

### Construct Diff

Run `git diff a1b2c3d` to capture the full diff including all new and modified files.

### Invoke Review

**This is a critical step.** I dispatch a subagent (via Task tool) that receives ONLY:
1. The raw diff output
2. The adversarial reviewer prompt from `meld:meld-adversarial-review`

The subagent does NOT receive:
- The tech spec
- The acceptance criteria
- Any conversation history
- Any context about what the feature is supposed to do

This information asymmetry is intentional -- the reviewer catches issues that the implementing agent is blind to because it "knows too much."

### Expected Findings

The reviewer, seeing only the diff, might surface findings like:

- **F1 (Medium):** CSV values containing commas or quotes are not escaped -- potential data corruption. (This may or may not be valid depending on whether I handled escaping in the REFACTOR step.)
- **F2 (Low):** No loading/disabled state on the Export button during download generation -- could lead to double-clicks.
- **F3 (Low):** The `exportToCsv` function uses `document.createElement('a')` which is not SSR-safe.
- **F4 (Noise):** Stylistic preference about button placement.

Each finding gets a severity (Critical/High/Medium/Low) and validity rating (Real/Possible/Noise/Undecided).

### Human Gate

Present the numbered findings with options:
- **[W] Walk through** -- iterate each finding
- **[F] Fix automatically** -- fix all "Real" findings
- **[S] Skip** -- acknowledge and proceed

**Wait for user decision.** This is a mandatory human gate.

For this simulation, assume the user chooses **[F] Fix automatically**.

### Apply Resolution

Filter to "Real" findings only. For example, if F1 (CSV escaping) is rated Real:
- Add proper CSV escaping (wrap values containing commas/quotes/newlines in double quotes, escape internal double quotes)
- Add a test for the escaping behavior
- Re-run all tests
- Confirm everything passes

Skip Noise/Undecided findings.

### Final Verification

**Run `meld:meld-verification` one last time** to catch any regressions introduced during finding resolution. Full test suite, linter, build -- all must pass.

### Worktree Completion

No worktree was created, so this sub-step is skipped.

**Task 5 marked `completed`.**

---

## Completion Summary

**Task 6 marked `in_progress`.**

### Final Output

- **Files created:**
  - `src/utils/csv-export.ts` -- CSV generation and download utility
  - `src/utils/csv-export.test.ts` -- Unit tests for CSV export
- **Files modified:**
  - `src/components/ReportsPage.tsx` -- Added Export CSV button with click handler
  - `src/components/ReportsPage.test.tsx` -- Added integration test for export button
- **Tests:** 4-5 new tests, all passing
- **Review:** N findings, M fixed, K skipped (specific numbers depend on review outcome)
- **Acceptance Criteria:** All 3 satisfied with test evidence
- **Status:** Complete

Suggest: commit changes, run any additional CI checks, or start a new workflow.

**Task 6 marked `completed`.**

---

## Key Decisions Summary

| Decision | Rationale |
|----------|-----------|
| **Mode A detected** | Spec has `status: ready-for-dev`, explicit ACs and tasks |
| **Phase 2 skipped** | Mode A -- the spec IS the context |
| **Tasks reordered for TDD** | Original order (build then test) contradicts TDD; merged into test-first units |
| **Two execution units, not five** | Tasks 1+4 and 2+3+5 are natural TDD pairs; executing them separately would violate "no production code without a failing test" |
| **No parallel execution** | Unit 2 depends on Unit 1's output (imports `exportToCsv`) |
| **Full audit (not skipped)** | Diff exceeds trivial threshold (4+ files, 50+ lines) |
| **Subagent review with no spec context** | Information asymmetry is the core value of adversarial review |
