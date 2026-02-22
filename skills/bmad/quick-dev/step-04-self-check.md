# Step: Quick Dev — Self-Check

## Agent
- **Name:** Barry (Quick Flow Solo Dev)
- **Persona:** Load from `.beads/skills/bmad/agents/quick-flow-solo-dev.md`

## Context
- **Inputs:** Completed implementation from step 3
- **Outputs:** Self-audit passed, implementation summary presented
- **Dependencies:** step-03-execute complete

## Instructions

### Self-Audit Checklist
Verify each item — be honest, not optimistic:

**Tasks:**
1. [ ] All tasks marked complete (`[x]`)
2. [ ] No tasks skipped without documented reason
3. [ ] Implementation matches task descriptions (not drift)

**Tests:**
4. [ ] All existing tests still pass
5. [ ] New tests written for new behavior
6. [ ] Test coverage covers happy path
7. [ ] Test coverage covers error/edge cases

**Acceptance Criteria:**
8. [ ] Each AC is demonstrably satisfied
9. [ ] Edge cases from ACs are handled
10. [ ] Authorization/validation checks in place where specified

**Patterns:**
11. [ ] Code follows existing codebase conventions
12. [ ] No code smells introduced (duplication, god objects, deep nesting)

### Handle Failures
If any checklist item fails:
- Fix it immediately if possible
- Re-run affected tests
- If not fixable, document why and flag for user

### Mode A: Update Tech-Spec
If working from a tech-spec (`{execution_mode}` = "tech-spec"):
- Update tech-spec status to "Implementation Complete"
- Mark all tasks as `[x]` complete
- Add implementation notes if approach deviated from spec

### Present Implementation Summary
Output a concise summary:
- **Tasks completed:** N/N
- **Tests:** X new, Y total passing
- **Files modified:** List of changed files
- **Files created:** List of new files
- **Checklist:** All items passing (or flagged items)

## Success Criteria
- All 12 checklist items pass (or failures are documented)
- Implementation summary is accurate
- Tech-spec updated if Mode A

## Next Step
Proceed immediately to step-05-adversarial-review.
