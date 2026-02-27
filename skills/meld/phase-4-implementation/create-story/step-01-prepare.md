# Step: Create Story with Ultimate Context

## Agent
- **Name:** Bob (SM)
- **Persona:** Load from `.beads/skills/meld/agents/sm.md`

## Context
- **Inputs:** Sprint status, epics document, architecture, tech specs, UX
- **Outputs:** Story file ready for development with comprehensive context
- **Dependencies:** Sprint planning must be complete

## Instructions

### Part 1: Determine Target Story
1. Load sprint-status.yaml
2. Identify next story to prepare (by sequence or user input)
3. Extract story foundation from epics document

### Part 2: Context Analysis
1. Load and analyze core artifacts:
   - Architecture document (patterns, structure, decisions)
   - Previous story files (learnings, dev notes, review feedback)
   - UX specification (if exists)
2. Extract developer guardrails from architecture:
   - Naming patterns, file locations, API conventions
   - Technology versions and constraints
3. Check git history for relevant commit patterns

### Part 3: Web Research (if needed)
1. Research latest technical specifics for technologies referenced
2. Verify library versions, API changes, best practices

### Part 4: Create Story File
1. Write comprehensive story file with:
   - User story (As a/I want/So that)
   - Acceptance criteria (Given/When/Then)
   - Tasks and subtasks (ordered, specific, testable)
   - Dev Notes with guardrails preventing common mistakes:
     - File locations, naming conventions, existing patterns
     - Libraries/versions to use, anti-patterns to avoid
     - Lessons from previous stories
   - Technical requirements and constraints
2. Mark story status as "ready-for-dev"
3. Update sprint-status.yaml

## Success Criteria
- Story is self-contained (dev agent needs no other context)
- All tasks have clear file paths and specific actions
- Acceptance criteria are testable (Given/When/Then)
- Dev Notes prevent reinventing wheels and wrong approaches
- Story marked ready-for-dev in sprint status

## Next Step
Hand off to dev-story workflow for implementation.
