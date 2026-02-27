# Step: Implement Story

## Agent
- **Name:** Amelia (Dev)
- **Persona:** Load from `.beads/skills/meld/agents/dev.md`

## Context
- **Inputs:** Story file with "ready-for-dev" status
- **Outputs:** Implemented story with all tests passing
- **Dependencies:** Story must be prepared and marked ready

## Instructions

### Execution Protocol
1. **Load story file completely** — READ entire file BEFORE any implementation
2. **Mark story in-progress** in sprint-status.yaml
3. **Execute tasks IN ORDER as written** — no skipping, reordering, or improvising
4. For each task/subtask:
   a. Load context and understand the requirement
   b. Implement following architecture patterns and Dev Notes
   c. Write comprehensive tests (unit, integration as appropriate)
   d. Run tests — ALL must pass before proceeding
   e. Mark task [x] ONLY when implementation AND tests complete
   f. Update story File List with ALL changed files
5. **Continue until ALL tasks/subtasks complete** — do NOT stop at milestones
6. Document in Dev Agent Record: what was implemented, tests created, decisions made

### Red-Green-Refactor Cycle
- **Red:** Write failing test for the requirement
- **Green:** Write minimum code to pass the test
- **Refactor:** Clean up while keeping tests green

### Validation Gates (per task)
- Implementation matches acceptance criteria
- Unit tests cover core functionality
- Integration tests cover component interactions
- All existing tests still pass (no regressions)
- Code follows architecture patterns and naming conventions

### Story Completion
1. Verify ALL acceptance criteria satisfied
2. Run full test suite — zero failures
3. Update story File List with every changed file
4. Write Dev Agent Record with implementation notes
5. Mark story status as "review"
6. Update sprint-status.yaml

### Halt Conditions
- 3 consecutive failures on same task
- Tests fail and fix is unclear
- Blocking dependency discovered
- Ambiguity requiring human decision

## Success Criteria
- All tasks/subtasks marked [x]
- Every acceptance criterion satisfied
- All tests pass (unit + integration + existing)
- File List includes every changed file
- Dev Agent Record documents implementation
- Story status updated to "review"

## Next Step
Hand off to code-review workflow.
