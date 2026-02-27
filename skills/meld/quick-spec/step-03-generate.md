# Step: Quick Spec — Generate Implementation Plan

## Agent
- **Name:** Barry (Quick Flow Solo Dev)
- **Persona:** Load from `.beads/skills/meld/agents/quick-flow-solo-dev.md`

## Context
- **Inputs:** WIP tech-spec with technical context from step 2
- **Outputs:** Complete implementation plan with tasks, ACs, testing strategy
- **Dependencies:** step-02-investigate complete

## Instructions

### 1. Load WIP File
Read `{{impl_artifacts}}/tech-spec-wip.md` completely — you need the full context.

### 2. Generate Implementation Tasks
Create discrete, actionable tasks ordered by dependency (lowest-level first):

**Task format:**
```
- [ ] Task N: {description}
  - File: {specific file path}
  - Action: {what to change/create}
  - Notes: {implementation details, edge cases}
```

**Task quality rules:**
- Each task is independently actionable by a developer
- File paths are specific (not "update the controller" — name the file)
- Dependency order is correct (migrations before models, models before controllers, etc.)
- No task depends on implicit knowledge from another task

### 3. Generate Acceptance Criteria
For each significant behavior, write Given/When/Then criteria:

```
**AC-N: {title}**
- Given {precondition}
- When {action}
- Then {expected result}
```

**Coverage requirements:**
- Happy path for every feature
- Error handling / validation failures
- Edge cases (empty state, boundary values, concurrent access)
- Authorization checks where applicable

### 4. Fill Additional Context

**Dependencies:**
- External packages, internal modules, config changes needed
- Migration order if multiple migrations

**Testing Strategy:**
- Unit tests: what to test in isolation
- Feature/integration tests: what end-to-end flows to verify
- Manual testing: any UI flows that need manual verification

**Notes:**
- Pre-mortem risks (what could go wrong)
- Limitations or known trade-offs
- Future considerations (what we're deliberately NOT doing now)

### 5. Write Complete Spec
Update WIP file with all generated content:
- Fill "Implementation Plan" section (Tasks + Acceptance Criteria)
- Fill "Additional Context" section (Dependencies + Testing Strategy + Notes)
- Set `status: 'review'`
- Set `stepsCompleted: [1, 2, 3]`
- **No placeholders** — every section must have real content

### Ready-for-Dev Standard
Before proceeding, verify the spec meets ALL criteria:
- **Actionable:** Every task has a clear file path and specific action
- **Logical:** Tasks ordered by dependency (lowest level first)
- **Testable:** All ACs follow Given/When/Then, cover happy path and edge cases
- **Complete:** All investigation results inlined, no placeholders or TBD
- **Self-Contained:** A fresh agent can implement without reading workflow history

## Success Criteria
- All tasks have specific file paths and actions
- ACs cover happy path, errors, and edge cases
- Testing strategy is concrete (not generic)
- Spec passes ready-for-dev standard check
- No placeholders remain in the document

## Next Step
Proceed immediately to step-04-review (Review and Finalize).
