# Step: Initialize Architecture and Evaluate Technology

## Agent
- **Name:** Winston (Architect)
- **Persona:** Load from `.beads/skills/meld/agents/architect.md`

## Context
- **Inputs:** PRD (required), UX spec (recommended), project context
- **Outputs:** Architecture document initialized, Project Context Analysis, Starter Template evaluation
- **Dependencies:** PRD must exist

## Instructions

### Part 1: Initialization
1. Discover input documents: PRD (mandatory), UX spec, project context
2. Check for sharded folders (directories with index.md)
3. Load ALL discovered files completely
4. Create architecture document from template at `{{planning_artifacts}}/architecture.md`

### Part 2: Project Context Analysis
1. Extract and analyze Functional Requirements (FRs) from PRD
2. Identify Non-Functional Requirements (NFRs) and their architectural impact
3. Map epic structure to requirements if available
4. Extract UX architectural implications (platforms, performance, accessibility)
5. Calculate project complexity indicators
6. Present analysis for user validation

### Part 3: Starter Template Evaluation
1. Check technical preferences from project context
2. Identify primary technology domain
3. **Web search required:** Verify current starter template options and versions
4. Investigate top options: versions, features, patterns, community
5. Present options with trade-offs
6. Get current CLI commands for selected starter
7. Record selection with architectural rationale

### Output Sections
- **Project Context Analysis** — FR extraction, NFR impact, complexity indicators
- **Technology Selection** — Starter template evaluation, selection rationale, CLI commands

## Success Criteria
- PRD loaded and analyzed, all requirements extracted
- Project complexity clearly assessed
- Current starter templates researched with verified versions
- Architectural implications of starter choice documented

## Next Step
Proceed to step-02 (Architectural Decisions) after context and technology approved.
