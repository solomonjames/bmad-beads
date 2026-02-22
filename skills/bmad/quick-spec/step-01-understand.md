# Step: Quick Spec — Understand Requirement

## Agent
- **Name:** Barry (Quick Flow Solo Dev)
- **Persona:** Load from `.beads/skills/bmad/agents/quick-flow-solo-dev.md`

## Context
- **Inputs:** Feature description from user, existing codebase
- **Outputs:** WIP tech-spec initialized with overview, problem, solution, scope
- **Dependencies:** None (first step)

## Instructions

### 1. WIP Resume Check
Before anything else, check if `{{impl_artifacts}}/tech-spec-wip.md` exists:
- **If exists:** Ask user — "Found an in-progress spec. Continue where we left off, or archive it and start fresh?"
- **If continuing:** Load WIP, check `stepsCompleted` frontmatter, resume from next incomplete step
- **If archiving:** Rename to `tech-spec-wip-archived-{date}.md`, proceed with new spec

### 2. Greet and Get Initial Request
- "Hey! What are we building today?"
- Capture the user's initial feature/fix description
- Note any constraints or preferences mentioned

### 3. Quick Orient Scan (<30 seconds)
Do a fast scan to build context — not a deep investigation:
- Check planning artifacts (`{{planning_artifacts}}`) for relevant docs
- Check `project-context.md` if it exists
- Search codebase for files/areas mentioned by the user
- Note what you find but don't go deep — that's step 2

### 4. Ask Informed Questions
Based on what you found in the orient scan, ask specific, code-anchored questions:
- Reference actual files, patterns, or conventions you discovered
- Ask about scope boundaries (what's in, what's out)
- Clarify ambiguities in the requirement
- **Do NOT** ask generic questions you could answer by reading code

### 5. Capture Core Understanding
Synthesize into structured understanding and confirm with user:
- **Title:** Concise feature/fix name
- **Slug:** kebab-case identifier (e.g., `avatar-upload`)
- **Problem Statement:** What problem does this solve?
- **Solution:** What will we build?
- **In Scope / Out of Scope:** Clear boundaries

### 6. Initialize WIP File
Create `{{impl_artifacts}}/tech-spec-wip.md` from template (`.beads/skills/bmad/templates/tech-spec.md`):
- Fill frontmatter: title, slug, created date, `status: 'in-progress'`, `stepsCompleted: [1]`
- Fill Overview section: Problem Statement, Solution, Scope (In/Out)
- Leave remaining sections empty for subsequent steps

## Success Criteria
- User's requirement is clearly understood and confirmed
- WIP file exists with Overview section complete
- Core understanding is specific enough to guide deep investigation
- No ambiguities remain about what we're building

## Next Step
Proceed to step-02-investigate (Deep Investigation).
