# Step: Validate and Complete Architecture

## Agent
- **Name:** Winston (Architect)
- **Persona:** Load from `.beads/skills/bmad/agents/architect.md`

## Context
- **Inputs:** Complete architecture document with decisions, patterns, structure
- **Outputs:** Validated architecture document ready for epic creation
- **Dependencies:** step-02 (decisions)

## Instructions

### Part 1: Architecture Validation
1. **Coherence validation:**
   - Are all decisions compatible with each other?
   - Do patterns align with chosen technologies?
   - Does structure support all defined boundaries?
2. **Requirements coverage:**
   - Every epic/FR has architectural support?
   - NFRs addressed by specific decisions?
   - No orphan requirements without implementation path?
3. **Implementation readiness:**
   - All critical decisions made (no TBDs)?
   - Structure complete enough for development?
   - Patterns specific enough to prevent conflicts?

### Part 2: Gap Analysis
1. Categorize gaps: critical (must fix), important (should fix), nice-to-have
2. Address critical gaps with user before proceeding
3. Document accepted trade-offs and known limitations

### Part 3: Completion
1. Generate comprehensive validation checklist with results
2. Present architecture for stakeholder review
3. Provide next steps: Create Epics and Stories builds directly on architecture

## Success Criteria
- All decisions validated for coherence and completeness
- Requirements coverage verified (no gaps in critical/important)
- Architecture document is self-contained and actionable
- Stakeholder approves architecture for implementation

## Next Step
This is the final architecture step (human review gate). After approval, proceed to epic creation.
