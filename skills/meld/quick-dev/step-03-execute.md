# Step: Quick Dev — Execute Implementation

## Agent
- **Name:** Barry (Quick Flow Solo Dev)
- **Persona:** Load from `.beads/skills/meld/agents/quick-flow-solo-dev.md`

## Context
- **Inputs:** Confirmed plan (Mode B) or tech-spec tasks (Mode A)
- **Outputs:** All tasks implemented with tests passing
- **Dependencies:** step-02-context-gather complete (Mode B) or step-01-mode-detect complete (Mode A)

## Instructions

### Execution Loop
For each task in the plan/spec:

1. **Load context** — Read relevant files, review patterns for this specific change
2. **Implement** — Write code following existing codebase patterns:
   - Match naming conventions, error handling, code style
   - Add comments only where logic isn't self-evident
   - Handle error cases appropriately
3. **Test** — Red-green-refactor:
   - Write failing test first (if appropriate for the change)
   - Make it pass with the implementation
   - Refactor if needed
   - Run existing tests to verify no regressions
4. **Mark complete** — `- [x] Task N` in tech-spec (Mode A) or mental checklist (Mode B)
5. **Continue immediately** — Move to next task without pausing

### Critical Rules
- **Continuous execution** — Do NOT stop between tasks for approval or status updates
- **Follow patterns** — Match existing codebase conventions exactly
- **Tests are non-negotiable** — Every behavioral change gets a test
- **No gold-plating** — Implement exactly what's specified, nothing more

### Halt Conditions
ONLY halt execution for:
- **3 consecutive failures** on the same task
- **Tests failing** with no obvious fix
- **Blocking dependency** discovered (missing package, API, etc.)
- **Ambiguity** requiring user decision (spec doesn't cover this case)

Do NOT halt for:
- Minor style warnings
- Optional improvements
- "Nice to have" enhancements
- Deprecation notices (note them, continue)

### When Halted
- Clearly state what's blocking and why
- Present options to unblock
- Wait for user input
- Resume execution after resolution

## Success Criteria
- All tasks from plan/spec are implemented
- All new tests pass
- All existing tests still pass
- No regressions introduced
- Code follows codebase conventions

## Next Step
Proceed to step-04-self-check (Self-Audit).
