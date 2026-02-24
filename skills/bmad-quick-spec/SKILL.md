---
name: bmad-quick-spec
description: Use when a feature needs a spec before coding — conversational spec engineering that produces a ready-for-dev tech spec through understand, investigate, generate, and review phases
---

# Quick Spec

Conversational spec engineering flow. Produces a ready-for-dev tech spec from a feature description through four phases: understand, investigate, generate, review.

**Persona:** Adopt the Barry (Solo Dev) persona from `bmad:bmad-personas` — read `quick-flow-solo-dev.md`. Direct, confident, implementation-focused, minimum ceremony.

## Checklist

Track progress using TodoWrite:

- [ ] Resume check — check for existing WIP spec
- [ ] Understand requirement — greet user, capture feature description
- [ ] Orient scan — quick scan of codebase and planning artifacts
- [ ] Ask informed questions — code-anchored clarification questions
- [ ] Capture core understanding — title, slug, problem, solution, scope
- [ ] Initialize WIP file — create tech-spec-wip.md with Overview section
- [ ] Deep code investigation — files, patterns, dependencies, tests
- [ ] Confirm technical context — present findings to user
- [ ] Generate implementation tasks — discrete, dependency-ordered tasks with file paths
- [ ] Generate acceptance criteria — Given/When/Then format with full coverage
- [ ] Verify ready-for-dev standard — actionable, logical, testable, complete, self-contained
- [ ] Human review gate — present spec, handle feedback, finalize

---

## Phase 1: Understand

### Resume Check
Check if `_bmad-output/tech-spec-wip.md` exists:
- **If exists:** Ask — "Found an in-progress spec. Continue where we left off, or archive and start fresh?"
- **If continuing:** Load WIP, check `stepsCompleted` frontmatter, resume from next incomplete phase
- **If archiving:** Rename to `tech-spec-wip-archived-{date}.md`, proceed fresh

### Greet and Get Initial Request
- "Hey! What are we building today?"
- Capture the user's feature/fix description
- Note any constraints or preferences mentioned

### Quick Orient Scan (<30 seconds)
Fast scan for context — not a deep investigation:
- Check planning artifacts for relevant docs
- Check `project-context.md` if it exists
- Search codebase for files/areas the user mentioned

### Ask Informed Questions
Based on the orient scan, ask specific, code-anchored questions:
- Reference actual files, patterns, or conventions discovered
- Ask about scope boundaries (in vs. out)
- Clarify ambiguities
- Do NOT ask generic questions you could answer by reading code

### Capture Core Understanding
Synthesize and confirm with user:
- **Title:** Concise feature/fix name
- **Slug:** kebab-case identifier (e.g., `avatar-upload`)
- **Problem Statement:** What problem does this solve?
- **Solution:** What will we build?
- **In Scope / Out of Scope:** Clear boundaries

### Initialize WIP File
Create `_bmad-output/tech-spec-wip.md` using the tech-spec template from `bmad:bmad-artifact-templates`:
- Fill frontmatter: title, slug, date, `status: 'in-progress'`, `stepsCompleted: [1]`
- Fill Overview section: Problem Statement, Solution, Scope
- Leave remaining sections for subsequent phases

---

## Phase 2: Investigate

### Deep Code Investigation
Build on the orient scan — now go deep:

**Identify relevant files:**
- Glob/grep for files related to the feature area
- Read and analyze existing implementations of similar features
- Map the dependency chain (what calls what)

**Document patterns:**
- Code style and naming conventions
- Import/export patterns, module structure
- Error handling patterns
- Database patterns (migrations, models, relationships)
- API patterns (routes, controllers, form requests, resources)

**Map files to modify:**
- Existing files that need changes (with specific areas)
- New files to create
- Test files — existing test patterns, helpers, factories

### Confirm Technical Context
Present findings and ask: "Here's what I found — anything I'm missing?"
- Highlight technical constraints that affect the approach
- Note decisions the user needs to make

### Update WIP File
- Set `stepsCompleted: [1, 2]`
- Update frontmatter: `tech_stack`, `files_to_modify`, `code_patterns`, `test_patterns`
- Fill "Context for Development" section: Codebase Patterns, Files to Reference, Technical Decisions

---

## Phase 3: Generate

### Generate Implementation Tasks
**REQUIRED SUB-SKILL:** Follow `bmad:bmad-spec-engineering` for task format and quality rules.

Create discrete, actionable tasks ordered by dependency (lowest-level first):
```
- [ ] Task N: {description}
  - File: {specific file path}
  - Action: {what to change/create}
  - Notes: {implementation details, edge cases}
```

### Generate Acceptance Criteria
**REQUIRED SUB-SKILL:** Follow `bmad:bmad-spec-engineering` for AC format and coverage requirements.

Write Given/When/Then criteria covering:
- Happy path for every feature
- Error handling / validation failures
- Edge cases (empty state, boundary values, concurrent access)
- Authorization checks where applicable

### Fill Additional Context
- **Dependencies:** External packages, internal modules, config changes
- **Testing Strategy:** Unit tests, integration tests, manual testing
- **Notes:** Pre-mortem risks, limitations, trade-offs, future considerations

### Write Complete Spec
- Fill all sections — no placeholders
- Set `status: 'review'`, `stepsCompleted: [1, 2, 3]`

### Verify Ready-for-Dev Standard
Before proceeding, the spec MUST pass ALL criteria:
- **Actionable:** Every task has a clear file path and specific action
- **Logical:** Tasks ordered by dependency (lowest level first)
- **Testable:** All ACs follow Given/When/Then, cover happy path and edge cases
- **Complete:** All investigation results inlined, no placeholders or TBD
- **Self-Contained:** A fresh agent can implement without reading workflow history

---

## Phase 4: Review (Human Gate)

### Present Complete Spec
Summary with: title, task count, AC count, file count. Full spec available for review.

### Review Menu
- **[C] Continue** — Approve spec as ready-for-dev
- **[E] Edit** — Make specific changes
- **[Q] Questions** — Answer questions about the spec
- **[R] Adversarial Review** — Invoke `bmad:bmad-adversarial-review` for quality check

### Handle Feedback
- **Edit:** Apply changes, re-verify ready-for-dev standard, return to menu
- **Questions:** Answer, update spec if answers reveal gaps, return to menu
- **Adversarial Review:** Run review against spec content, present findings, user decides which to address

### Finalize
When user approves:
1. Set `status: 'ready-for-dev'`, `stepsCompleted: [1, 2, 3, 4]`
2. Rename: `tech-spec-wip.md` → `tech-spec-{slug}.md`
3. Confirm final path
4. Suggest: "Spec is ready. Start development with `/quick-dev` using this spec."
