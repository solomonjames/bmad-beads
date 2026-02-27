# Step: Quick Dev — Resolve Findings

## Agent
- **Name:** Barry (Quick Flow Solo Dev)
- **Persona:** Load from `.beads/skills/meld/agents/quick-flow-solo-dev.md`

## Context
- **Inputs:** Numbered adversarial review findings
- **Outputs:** Findings resolved, implementation finalized
- **Dependencies:** step-05-adversarial-review complete
- **Type:** Human review gate

## Instructions

### 1. Present Resolution Options
Show findings summary and ask user:
- **[W] Walk through** — Iterate each finding individually
- **[F] Fix automatically** — Auto-fix all "real" findings, skip noise
- **[S] Skip** — Acknowledge findings, proceed without fixing

### 2. Handle Resolution

**Walk Through [W]:**
For each finding (F1, F2, etc.):
1. Present: severity, validity assessment, context, affected code
2. Ask: Fix / Skip / Discuss
3. If Fix: apply the fix, re-run affected tests
4. If Skip: note reason, move to next
5. If Discuss: explain trade-offs, let user decide
6. Continue to next finding

**Fix Automatically [F]:**
1. Filter to findings marked "real" validity only
2. Apply fixes for each
3. Skip "noise" and "undecided" findings
4. Re-run all tests after fixes
5. Report: what was fixed, what was skipped (with reasons)

**Skip [S]:**
1. Acknowledge all findings
2. Note them for future reference
3. Proceed to completion

### 3. Mode A: Update Tech-Spec
If `{execution_mode}` = "tech-spec":
- Update tech-spec status to "Completed"
- Add review notes section:
  - Total findings count
  - Fixed count
  - Skipped count
  - Resolution approach used

### 4. Completion Summary
Present final summary:
- **Implementation:** Files modified/created
- **Tests:** All passing (count)
- **Review:** N findings, M fixed, K skipped
- **Status:** Complete

## Success Criteria
- User has chosen resolution approach
- Fixes applied correctly (tests still pass)
- Tech-spec updated to "Completed" status (Mode A)
- User has clear understanding of what was built

## Next Step
This is the final quick-dev step. User can commit, run additional tests, or start a new workflow.
