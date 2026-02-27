# Step: Validate Prerequisites and Design Epic Structure

## Agent
- **Name:** John (PM) + Bob (SM)
- **Persona:** Load from `.beads/skills/meld/agents/pm.md` and `.beads/skills/meld/agents/sm.md`

## Context
- **Inputs:** PRD (required), Architecture (required), UX spec (optional)
- **Outputs:** Epic structure with FR coverage mapping
- **Dependencies:** Architecture must be approved

## Instructions

### Part 1: Validate Prerequisites
1. Search for required documents: PRD (mandatory), Architecture (mandatory), UX (optional)
2. Extract ALL Functional Requirements (FRs) with numbering
3. Extract ALL Non-Functional Requirements (NFRs)
4. Extract additional requirements from Architecture (especially starter template)
5. Extract UX requirements (responsive, accessibility, browser compatibility)
6. Present extracted requirements for user confirmation

### Part 2: Design Epic Structure
1. Epic design principles:
   - **User-Value First:** Each epic delivers user outcome (NOT technical layers)
   - **Requirements Grouping:** Related FRs grouped logically
   - **Incremental Delivery:** Each epic can be built and validated independently
   - **Logical Flow:** Epics enable future epics without requiring them
2. **CRITICAL: Anti-patterns to avoid:**
   - "Setup Database" / "API Development" / "Frontend Components" (technical layers)
   - Epics with no direct user value
   - Epic N requiring Epic N+1 to function
3. Identify user value themes and propose epic structure
4. Create requirements coverage map (FR -> epic mapping)
5. Verify NO FRs are missed
6. Get explicit user approval (allow refinement iterations)

### Output
- Epic list with title, goal statement, FR coverage for each
- Requirements coverage map showing all FRs mapped
- Template populated with epic structure

## Success Criteria
- Epics designed around user value, not technical layers
- ALL FRs mapped to at least one epic
- Each epic can be built and validated independently
- Epic structure approved by user

## Next Step
Proceed to step-02 (Create Stories) after epic structure approved.
