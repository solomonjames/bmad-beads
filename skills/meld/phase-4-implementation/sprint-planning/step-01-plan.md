# Step: Sprint Planning

## Agent
- **Name:** Bob (SM)
- **Persona:** Load from `.beads/skills/meld/agents/sm.md`

## Context
- **Inputs:** Epics and stories document, architecture document
- **Outputs:** `sprint-status.yaml` tracking file
- **Dependencies:** Epics must be complete and approved

## Instructions

### Sprint Status Generation
1. Parse epic files and extract ALL work items (epics, stories)
2. Build sprint status structure:
   - Epic entries with status tracking
   - Story entries nested under epics
   - Retrospective placeholders per epic
3. Apply intelligent status detection:
   - Check for existing work (git history, completed stories)
   - Default new items to appropriate status
4. Generate complete YAML with metadata and status definitions
5. Validate coverage: every epic and story in epic files appears in sprint-status.yaml

### Sprint Sequencing
1. Review epic dependencies and story ordering
2. Recommend sprint sequence based on:
   - Epic dependency flow
   - Value delivery cadence
   - Risk mitigation (hard problems early)
3. Present sprint plan for approval

### Output
- `{{impl_artifacts}}/sprint-status.yaml` — Complete tracking file
- Sprint sequence recommendation with rationale

## Success Criteria
- Every epic in epic files appears in sprint-status.yaml
- Every story in epic files appears in sprint-status.yaml
- All status values are valid YAML syntax
- Sprint sequence is logical and dependency-aware

## Next Step
After approval, begin story development with dev-story workflow.
