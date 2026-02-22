# Step: Generate Stories and Validate Coverage

## Agent
- **Name:** John (PM) + Bob (SM)
- **Persona:** Load from `.beads/skills/bmad/agents/pm.md` and `.beads/skills/bmad/agents/sm.md`

## Context
- **Inputs:** Approved epic structure with FR mapping
- **Outputs:** Complete epics.md with all stories, validated for coverage
- **Dependencies:** step-01 (design-epics)

## Instructions

### Part 1: Generate Stories
1. Process epics SEQUENTIALLY (not in parallel)
2. For each epic:
   - Display epic overview and assigned FRs
   - Break down into stories collaboratively
3. Story creation guidelines:
   - Sized for single developer agent completion
   - Clear user value in each story
   - Format: "As a [user], I want [capability], So that [value]"
   - Acceptance Criteria: Given/When/Then format, independently testable, include edge cases
   - Reference requirements being fulfilled
4. **Database/Entity Principle:** Create tables ONLY when needed by the story
5. **Dependency Principle:** Stories must be independently completable in sequence
   - Story N.1: standalone
   - Story N.2: can use N.1's output
   - NO forward dependencies ("depends on Story 1.4")
6. If Architecture specifies starter template: Epic 1, Story 1 MUST be "Set up initial project"

### Part 2: Final Validation
1. **FR Coverage:** Every FR appears in at least one story's acceptance criteria
2. **Architecture Compliance:** Starter template setup in first story if specified
3. **Story Quality:** Each completable by single dev, clear ACs, no forward dependencies
4. **Epic Structure:** Each delivers user value, dependencies flow naturally
5. **Dependency Check:**
   - Epic independence (Epic 2 doesn't require Epic 3)
   - Within-epic flow (N.1 standalone, N.2 uses N.1, etc.)

### Output
- Complete `{{planning_artifacts}}/epics.md` with all epics and stories
- Story files in `{{impl_artifacts}}/` if applicable

## Success Criteria
- All epics have detailed stories with Given/When/Then acceptance criteria
- Every FR traceable to at least one story
- No forward dependencies in stories
- Stories properly sized for single dev completion
- Database entities created only when needed

## Next Step
This step completes epic creation. Recommended: Implementation Readiness Check.
