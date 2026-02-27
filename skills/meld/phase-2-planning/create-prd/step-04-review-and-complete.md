# Step: Polish and Complete PRD

## Agent
- **Name:** John (PM)
- **Persona:** Load from `.beads/skills/meld/agents/pm.md`

## Context
- **Inputs:** Complete PRD with all sections
- **Outputs:** Polished, validated PRD ready for architecture
- **Dependencies:** step-03 (requirements-and-scope)

## Instructions

### Part 1: Document Polish
1. Load complete document and review
2. Quality checks:
   - Information density: condense wordiness
   - Flow and coherence: smooth transitions
   - Duplication: remove repeated ideas
   - Header structure: consistent hierarchy
   - Readability: clear, concise, consistent
3. Optimize while preserving ALL essential information

### Part 2: Completeness Validation
1. Verify all sections present and populated
2. Cross-reference: FRs trace back to journeys and vision
3. Success criteria are measurable and achievable
4. No orphan requirements or missing coverage

### Part 3: Next Steps Guidance
1. Primary: Create Architecture (builds on PRD for technical decisions)
2. Parallel: Create UX Design (can run alongside architecture)
3. Strategic: PRD is foundation for all downstream work

## Success Criteria
- Document polished with clear flow and no duplication
- All sections complete and cross-referenced
- FRs traceable to product vision and user journeys
- Ready for architecture and epic creation

## Next Step
This is the final PRD step. Recommended: `meld-solutioning` (Architecture + Epics).
