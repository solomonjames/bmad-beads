# Step: Define Product Through Journeys and Deep Dives

## Agent
- **Name:** John (PM)
- **Persona:** Load from `.beads/skills/bmad/agents/pm.md`

## Context
- **Inputs:** PRD with classification and success criteria
- **Outputs:** User Journeys, Domain Requirements, Innovation Analysis, Project-Type specifics
- **Dependencies:** step-01 (init-and-requirements)

## Instructions

### Part 1: User Journey Mapping
1. Leverage existing personas from product briefs
2. Identify ALL user types (primary, admin, support, API consumers)
3. Create narrative story-based journeys:
   - Opening Scene (pain point)
   - Rising Action (discovery/steps)
   - Climax (core value moment)
   - Resolution (transformation)
4. Aim for 3-4+ diverse journeys covering different user types
5. Document Journey Requirements Summary

### Part 2: Domain-Specific Requirements (if applicable)
1. Check domain complexity classification
2. For complex domains (healthcare, fintech, regulated):
   - Explore compliance requirements
   - Technical constraints (security, privacy, integration)
   - Domain patterns and anti-patterns
   - Risks and mitigations
3. Skip for low-complexity domains

### Part 3: Innovation Discovery (if applicable)
1. Listen for innovation signals: "nothing exists like this", "rethinking how X works"
2. Only proceed if genuine innovation detected
3. Explore: What's novel? Market context? Validation approach? Risks?
4. Skip if no innovation signals found

### Part 4: Project-Type Deep Dive
1. Based on project type classification, explore type-specific requirements:
   - API: spec format, versioning, rate limiting
   - SaaS: multi-tenancy, billing, onboarding
   - Mobile: offline, push notifications, platform specifics
   - Marketplace: two-sided dynamics, trust, payments
2. Connect all discoveries to product differentiator

### Output Sections
Append to PRD:
- **User Journeys** — Narrative journeys with requirements mapping
- **Domain Requirements** — Compliance, constraints (if applicable)
- **Innovation Analysis** — Novel aspects (if applicable)
- **Project-Type Requirements** — Type-specific details

## Success Criteria
- Rich narrative user journeys covering all user types
- Domain requirements captured if domain is complex
- Innovation documented if genuine novelty exists
- Project-type specifics thoroughly explored

## Next Step
Proceed to step-03 (Requirements Synthesis) after product definition approved.
