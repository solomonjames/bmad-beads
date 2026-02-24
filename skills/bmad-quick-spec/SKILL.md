---
name: bmad-quick-spec
description: Use when a feature needs a spec before coding — conversational spec engineering that produces a ready-for-dev tech spec through understand, investigate, generate, and review phases
---

# Quick Spec

Conversational spec engineering flow. Produces a ready-for-dev tech spec from a feature description through four phases: understand, investigate, generate, review.

**Persona:** Adopt the Barry (Solo Dev) persona from `bmad:bmad-personas` — read `quick-flow-solo-dev.md`. Direct, confident, implementation-focused, minimum ceremony.

## Beads Integration (Optional)

If `{ticket_id}` is set and beads is active, the ticket becomes the spec artifact. No local files are created — all content is written directly to beads fields and sub-tickets.

### Detection
1. Check if `{ticket_id}` is set (non-empty). If not, set `{beads_active}` to false.
2. Verify beads is installed: `which bd`. If not found, warn user ("beads not installed, proceeding without ticket tracking"), set `{beads_active}` to false.
3. Ensure working directory: Before running `bd` commands, verify you are within the project directory containing `.beads/`. If session context provides a beads project root, `cd` to it.
4. Load ticket: `bd show {ticket_id} --json`. If the ticket doesn't exist, warn and set `{beads_active}` to false.
5. Store the ticket's current `metadata` JSON for read-merge-write operations.

### Storage Routing
- **Without beads:** Write to `_bmad-output/tech-spec-wip.md` (local file flow)
- **With beads:** Write to ticket fields (`design`, `notes`, `acceptance_criteria`) + create sub-tickets for implementation tasks

### Metadata Read-Merge-Write Pattern
Every metadata update must:
1. Read current metadata: `bd show {ticket_id} --json` → extract `.metadata`
2. Merge new fields into the existing object (never discard existing keys)
3. Write full merged JSON: `bd update {ticket_id} --metadata '{...}'`

## Checklist

Track progress using TodoWrite:

- [ ] Resume check — check for existing WIP spec (or ticket state if beads-active)
- [ ] Understand requirement — greet user, capture feature description
- [ ] Orient scan — quick scan of codebase and planning artifacts
- [ ] Ask informed questions — code-anchored clarification questions
- [ ] Capture core understanding — title, slug, problem, solution, scope
- [ ] Write spec overview — to WIP file or ticket design field
- [ ] Deep code investigation — files, patterns, dependencies, tests
- [ ] Confirm technical context — present findings to user
- [ ] Write technical context — to WIP file or ticket notes field
- [ ] Generate implementation tasks — as spec tasks or sub-tickets
- [ ] Generate acceptance criteria — Given/When/Then format
- [ ] Verify ready-for-dev standard
- [ ] Human review gate — present spec, handle feedback, finalize

---

## Phase 1: Understand

### Resume Check

**If `{beads_active}`:** Check `metadata.bmad_step` on the ticket. If set, offer to resume from that phase. Skip local file check.

**Otherwise:** Check if `_bmad-output/tech-spec-wip.md` exists:
- **If exists:** Ask — "Found an in-progress spec. Continue where we left off, or archive and start fresh?"
- **If continuing:** Load WIP, check `stepsCompleted` frontmatter, resume from next incomplete phase
- **If archiving:** Rename to `tech-spec-wip-archived-{date}.md`, proceed fresh

### Greet and Get Initial Request
- If `{beads_active}` and ticket has a title and description, use them as initial context: "I see ticket `{ticket_id}` — '{title}'. Let me use that as our starting point." Skip the open-ended question.
- Otherwise: "Hey! What are we building today?"
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

### Write Spec Overview

**If `{beads_active}`:**
1. `bd update {ticket_id} --status in_progress`
2. `bd update {ticket_id} --design "**Problem:** {problem_statement}\n\n**Solution:** {solution}\n\n**Scope:**\nIn: {in_scope}\nOut: {out_of_scope}"`
3. Read-merge-write metadata: merge `{"bmad_phase": "spec", "bmad_step": "understand", "spec_slug": "{slug}"}`
4. `bd comment {ticket_id} "BMAD quick-spec Phase 1 (Understand) complete — core understanding captured"`

**Otherwise:** Create `_bmad-output/tech-spec-wip.md` using the tech-spec template from `bmad:bmad-artifact-templates`:
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

### Write Technical Context

**If `{beads_active}`:**
1. `bd update {ticket_id} --notes "**Technical Context:**\n\n**Files to modify:**\n{full_list_with_areas}\n\n**Codebase Patterns:**\n{detailed_patterns}\n\n**Dependencies:**\n{deps}\n\n**Tech Stack:** {stack}\n\n**Test Patterns:** {test_patterns}"`
2. Read-merge-write metadata: merge `{"bmad_step": "investigate"}`
3. `bd comment {ticket_id} "BMAD quick-spec Phase 2 (Investigate) complete — {file_count} files mapped"`

**Otherwise:**
- Set `stepsCompleted: [1, 2]`
- Update frontmatter: `tech_stack`, `files_to_modify`, `code_patterns`, `test_patterns`
- Fill "Context for Development" section: Codebase Patterns, Files to Reference, Technical Decisions

---

## Phase 3: Generate

### Generate Implementation Tasks
**REQUIRED SUB-SKILL:** Follow `bmad:bmad-spec-engineering` for task format and quality rules.

**If `{beads_active}`:** Create a sub-ticket for each task:
```
bd create --parent {ticket_id} "Task N: {description}" \
  --notes "File: {file_path}\nAction: {action}\nNotes: {details}"
```
Store sub-ticket IDs in metadata for Quick-Dev to consume.

**Otherwise:** Create discrete, actionable tasks ordered by dependency (lowest-level first):
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

### Write Implementation Plan

**If `{beads_active}`:**
1. `bd update {ticket_id} --acceptance-criteria "{all_given_when_then}"`
2. Append to notes: testing strategy, dependencies, additional notes
3. Read-merge-write metadata: merge `{"bmad_step": "generate", "spec_status": "review"}`
4. `bd comment {ticket_id} "BMAD quick-spec Phase 3 (Generate) complete — {task_count} sub-tickets, {ac_count} acceptance criteria"`

**Otherwise:**
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

**If `{beads_active}`:**
1. Read-merge-write metadata: merge `{"bmad_step": "review", "spec_status": "ready-for-dev"}`
2. `bd comment {ticket_id} "BMAD quick-spec Phase 4 (Review) complete — spec finalized as ready-for-dev. Start implementation with /quick-dev {ticket_id}"`
3. Suggest: "Spec is ready. Start development with `/quick-dev {ticket_id}`."

**Otherwise:**
1. Set `status: 'ready-for-dev'`, `stepsCompleted: [1, 2, 3, 4]`
2. Rename: `tech-spec-wip.md` → `tech-spec-{slug}.md`
3. Confirm final path
4. Suggest: "Spec is ready. Start development with `/quick-dev` using this spec."
