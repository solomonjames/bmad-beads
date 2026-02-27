# Step: Define Architecture Decisions, Patterns, and Structure

## Agent
- **Name:** Winston (Architect)
- **Persona:** Load from `.beads/skills/meld/agents/architect.md`

## Context
- **Inputs:** Architecture doc with context analysis and technology selection
- **Outputs:** Architecture Decision Records, Implementation Patterns, Project Structure
- **Dependencies:** step-01 (init-and-context)

## Instructions

### Part 1: Core Architectural Decisions
1. Review technical preferences from step-01
2. Identify remaining critical decisions, categorize by priority
3. Decision categories:
   - **Data Architecture:** Database selection, schema strategy, migrations
   - **Authentication & Security:** Auth mechanism, authorization model, encryption
   - **API & Communication:** API style, versioning, real-time patterns
   - **Frontend Architecture:** Component architecture, state management, routing
   - **Infrastructure & Deployment:** Hosting, CI/CD, monitoring, scaling
4. **Web search required:** Verify technology versions
5. Record each decision with rationale and trade-offs
6. Check for cascading implications between decisions

### Part 2: Implementation Patterns & Consistency Rules
1. Identify potential conflict points where multiple agents could diverge
2. Define pattern categories with concrete examples:
   - **Naming patterns:** database columns, API endpoints, code variables, components
   - **Structure patterns:** project organization, file structure, module boundaries
   - **Format patterns:** API responses, data exchange, error handling
   - **Communication patterns:** events, state management, service interaction
   - **Process patterns:** error handling flows, loading states, validation
3. Provide anti-patterns for each (what NOT to do)

### Part 3: Project Structure & Boundaries
1. Map requirements to architectural components
2. Create complete project directory structure (specific, not generic placeholders)
3. Define integration boundaries (API, component, service, data)
4. Map epics/features to specific directories
5. Map cross-cutting concerns to locations
6. Document how components communicate

### Output Sections
Append to architecture document:
- **Architecture Decision Records** — Each ADR with context, decision, rationale, trade-offs
- **Implementation Patterns** — Naming, structure, format, communication, process rules
- **Project Structure** — Complete directory tree with purpose annotations
- **Architectural Boundaries** — Integration points, component communication

## Success Criteria
- All critical decisions documented with verified versions
- Trade-offs discussed for each decision
- Patterns comprehensive enough to prevent agent conflicts
- Project structure maps every requirement to a location
- No ambiguous boundaries between components

## Next Step
Proceed to step-03 (Architecture Review) for validation and human approval.
