# Step: Quick Spec — Investigate Technical Constraints

## Agent
- **Name:** Barry (Quick Flow Solo Dev)
- **Persona:** Load from `.beads/skills/meld/agents/quick-flow-solo-dev.md`

## Context
- **Inputs:** WIP tech-spec with core understanding from step 1
- **Outputs:** Technical context fully mapped — stack, patterns, files, tests documented
- **Dependencies:** step-01-understand complete

## Instructions

### 1. Load WIP File
Read `{{impl_artifacts}}/tech-spec-wip.md`, extract problem statement and scope to guide investigation.

### 2. Deep Code Investigation
Build on the orient scan from step 1 — now go deep:

**Identify relevant files:**
- Glob/grep for files related to the feature area
- Read and analyze existing implementations of similar features
- Map the dependency chain (what calls what, what depends on what)

**Document patterns:**
- Code style and naming conventions in relevant areas
- Import/export patterns, module structure
- Error handling patterns
- Database patterns (migrations, models, relationships)
- API patterns (routes, controllers, form requests, resources)

**Map files to modify:**
- Existing files that need changes (with specific areas)
- New files that need to be created
- Test files — existing test patterns, test helpers, factories

**Handle clean slate:**
- If no similar features exist, document the closest patterns to follow
- Note any scaffolding or boilerplate needed

### 3. Confirm Technical Context with User
Present findings and ask:
- "Here's what I found — anything I'm missing?"
- Highlight any technical constraints that affect the approach
- Note any decisions the user needs to make

### 4. Update WIP File
Update `{{impl_artifacts}}/tech-spec-wip.md`:
- Set `stepsCompleted: [1, 2]`
- Update frontmatter: `tech_stack`, `files_to_modify`, `code_patterns`, `test_patterns`
- Fill "Context for Development" section:
  - **Codebase Patterns:** Conventions discovered
  - **Files to Reference:** Table of File | Purpose
  - **Technical Decisions:** Any decisions made during investigation

## Success Criteria
- All relevant files identified and analyzed
- Codebase patterns documented (not assumed)
- Files to modify/create listed with specific purposes
- Test patterns identified (how to test, what frameworks, existing helpers)
- User has confirmed the technical context is accurate

## Next Step
Proceed to step-03-generate (Generate Implementation Plan).
