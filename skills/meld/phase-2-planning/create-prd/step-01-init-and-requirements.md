# Step: Initialize PRD and Define Requirements Foundation

## Agent
- **Name:** John (PM)
- **Persona:** Load from `.beads/skills/meld/agents/pm.md`

## Context
- **Inputs:** Product brief (required), research documents, project context
- **Outputs:** PRD document initialized, Project Discovery and Success Criteria sections
- **Dependencies:** Product brief must exist

## Instructions

### Part 1: Initialization
1. Search for input documents: product briefs, research, brainstorming, project context
2. Check for sharded folders (directories with index.md)
3. Load ALL discovered files completely - PRD is MANDATORY
4. Create output document from template at `{{planning_artifacts}}/prd.md`

### Part 2: Project Discovery
1. Load classification data to guide conversation
2. Conduct natural conversation discovering:
   - Project type (API, SaaS, mobile app, marketplace, etc.)
   - Domain (healthcare, fintech, e-commerce, etc.)
   - Complexity level (low, medium, high)
   - Project context (greenfield vs. brownfield)
3. Document classification in PRD

### Part 3: Success Criteria Definition
1. Review existing documents for success criteria
2. Guide conversation on three levels:
   - **User Success:** What does user value/accomplishment look like?
   - **Business Success:** Metrics, timelines, growth targets
   - **Technical Success:** Reliability, performance, scalability requirements
3. Challenge vague metrics to specificity
4. Negotiate scope (MVP vs. Growth vs. Vision phases)

### Output Sections
- **Project Classification** — Type, Domain, Complexity
- **Success Criteria** — User Success, Business Success, Technical Success
- **Product Scope** — Phase definitions

## Success Criteria
- PRD initialized from template with all input documents loaded
- Project correctly classified by type, domain, complexity
- Success criteria defined at all three levels with specific, measurable targets
- Scope phases clearly delineated

## Next Step
Proceed to step-02 (Product Definition) after requirements foundation approved.
