# Step: Synthesize Requirements and Define Scope

## Agent
- **Name:** John (PM)
- **Persona:** Load from `.beads/skills/meld/agents/pm.md`

## Context
- **Inputs:** PRD with journeys, domain, and type-specific sections
- **Outputs:** MVP Scope, Functional Requirements, Non-Functional Requirements
- **Dependencies:** step-02 (product-definition)

## Instructions

### Part 1: Scoping Exercise
1. Review complete PRD built so far
2. Guide MVP strategy selection:
   - Problem-solving MVP vs. Experience MVP vs. Platform vs. Revenue
3. Conduct Must-Have vs. Nice-to-Have analysis
4. Create phased roadmap:
   - Phase 1 (MVP): Essential journeys, core functionality
   - Phase 2 (Growth): Additional features, enhanced experience
   - Phase 3 (Vision): Advanced capabilities, new markets
5. Identify and mitigate risks (technical, market, resource)

### Part 2: Functional Requirements Synthesis
**CRITICAL: This is the capability contract for all downstream work**
1. Review ALL previous content to extract capabilities
2. Organize FRs by logical capability areas (5-8 areas, NOT technical layers)
3. Target 20-50 FRs total (20+ for typical projects)
4. Each FR format: "[Actor] can [capability] [context]"
5. Altitude check: WHAT capability exists (not HOW to implement)
6. Self-validation checklist:
   - Completeness: covers all discussed capabilities?
   - Altitude: implementation-agnostic?
   - Clarity: testable and independent?
7. **Warning: No capabilities not listed = won't exist in final product**

### Part 3: Non-Functional Requirements
1. Selective approach — only document NFRs that matter for THIS product
2. Assess relevance of each category:
   - Performance, Security, Scalability, Accessibility, Integration, Reliability
3. For each relevant category: make specific and measurable
4. Include domain-specific compliance requirements if applicable

### Output Sections
Append to PRD:
- **MVP Scope** — Strategy, phased roadmap, risk mitigations
- **Functional Requirements** — Organized by capability area with FR numbering
- **Non-Functional Requirements** — Relevant categories with specifics

## Success Criteria
- MVP scope clearly defined with phased roadmap
- All FRs organized by capability area, implementation-agnostic
- No discussed capability missing from FR list
- NFRs specific and measurable for relevant categories
- Complete capability contract ready for architecture and epics

## Next Step
Proceed to step-04 (PRD Review) for polish and human review.
