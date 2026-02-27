# Step: Quick Dev — Context Gathering

## Agent
- **Name:** Barry (Quick Flow Solo Dev)
- **Persona:** Load from `.beads/skills/meld/agents/quick-flow-solo-dev.md`

## Context
- **Inputs:** Mode B direct instructions from user
- **Outputs:** Implementation plan confirmed and ready for execution
- **Dependencies:** step-01-mode-detect complete
- **Note:** Only runs for Mode B (direct instructions). Mode A skips to step-03-execute.

## Instructions

### 1. Identify Files to Modify
- Glob/grep for files related to the feature area
- Read key files to understand current implementation
- List all files that need changes and new files to create

### 2. Find Relevant Patterns
Analyze the codebase for patterns to follow:
- Code style and naming conventions
- Import/export patterns
- Error handling approach
- Test patterns (framework, helpers, factories)
- Database patterns (migrations, models, relationships)

### 3. Note Dependencies
- External libraries needed (check if already installed)
- Internal modules to integrate with
- Config files that need updates
- Related files that might be affected

### 4. Create Implementation Plan
Synthesize findings into an actionable plan:
- **Tasks:** Ordered list of discrete changes
- **Inferred ACs:** What "done" looks like for each task
- **Order of operations:** Dependency-correct sequence
- **Files to touch:** Complete list with purpose

### 5. Present Plan for Confirmation
Show the user:
- Files to modify/create
- Patterns to follow
- Implementation plan with tasks
- Acceptance criteria

Ask: "Ready to execute? Adjust anything?"

Wait for user confirmation before proceeding.

## Success Criteria
- All relevant files identified
- Codebase patterns documented
- Implementation plan is concrete and actionable
- User has confirmed the plan

## Next Step
Proceed to step-03-execute (Implementation).
