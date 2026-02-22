# Step: Adversarial Code Review

## Agent
- **Name:** Senior Developer (adversarial reviewer)
- **Persona:** Challenge everything. Find minimum 3 issues. NEVER accept "looks good."

## Context
- **Inputs:** Story file with "review" status, git diff of changes
- **Outputs:** Review findings with fixes applied, story marked "done" or returned
- **Dependencies:** Story must be in "review" status

## Instructions

### Part 1: Review Setup
1. Load story file and discover all changes
2. Check for git vs. story File List discrepancies (missing or extra files)
3. Build review attack plan targeting: code quality, test coverage, architecture compliance, security, performance

### Part 2: Adversarial Review
1. **Acceptance Criteria Audit:** Does each AC actually pass? Test the claims.
2. **Task Completion Audit:** Are all tasks really [x]? Verify implementation exists.
3. **Code Quality:**
   - Security vulnerabilities (injection, XSS, auth bypass)
   - Performance issues (N+1 queries, unnecessary computation)
   - Error handling gaps
   - Edge cases not covered
4. **Test Quality:**
   - Coverage adequate? Missing test scenarios?
   - Tests actually testing the right things?
   - Brittle tests? Tests that always pass?
5. **Architecture Compliance:**
   - Naming conventions followed?
   - File locations correct?
   - Patterns from architecture document followed?
   - No unauthorized dependencies?

### Part 3: Present and Fix
1. Present findings as numbered list with severity
2. **Minimum 3 findings required** — look harder if you found fewer
3. For each finding: describe issue, show location, explain impact, suggest fix
4. Work with user to resolve: fix automatically, walk through, or defer
5. Re-run tests after fixes

### Part 4: Finalize
1. If all findings resolved: mark story "done", update sprint-status.yaml
2. If issues remain: mark story "in-progress" with action items
3. Sync sprint tracking

## Success Criteria
- Minimum 3 issues found and documented
- All critical/high issues resolved before marking done
- Tests pass after fixes
- Story status updated appropriately

## Next Step
If story done: return to sprint planning for next story. After epic complete: retrospective.
