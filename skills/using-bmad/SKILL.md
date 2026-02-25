---
name: using-bmad
description: Use when starting any conversation - establishes when to use BMAD methodology skills for structured product development, spec engineering, and adversarial review
---

# Using BMAD

BMAD (Business-driven Multi-Agent Development) provides a complete methodology for structured product development — from planning through execution to review. It includes:

- **Personas** — Expert viewpoints for different phases of work
- **Complexity routing** — Match approach depth to problem complexity
- **Spec engineering** — Structured Given/When/Then specifications with ready-for-dev standards
- **Adversarial review** — Information-asymmetric code review using subagents
- **Execution skills** — TDD, debugging, verification, parallel agents, worktrees

## When to Use BMAD Skills

| Situation | BMAD Skill | Pairs With |
|-----------|-----------|------------|
| User describes a feature or asks "build X" | `bmad:bmad-complexity-assessment` | — |
| Feature needs a spec before coding | `bmad:bmad-quick-spec` | — |
| Ready to implement (with or without spec) | `bmad:bmad-quick-dev` | TDD built-in (`bmad:bmad-tdd`) |
| Writing acceptance criteria | `bmad:bmad-spec-engineering` | — |
| Bug needs investigation | `bmad:bmad-debugging` | `bmad:bmad-tdd` |
| Claiming work is complete | `bmad:bmad-verification` | — |
| 2+ independent tasks | `bmad:bmad-parallel-agents` | — |
| Starting isolated work on a ticket | `bmad:bmad-worktrees` | Built into quick-dev |
| Implementation complete, need review | `bmad:bmad-adversarial-review` | `bmad:bmad-verification` |
| Need a specific expert perspective | `bmad:bmad-personas` | — |
| Need an output template (tech-spec, PRD, etc.) | `bmad:bmad-artifact-templates` | — |

## When NOT to Use BMAD Skills

- **Simple bug fixes with obvious cause** — Go straight to TDD. If cause is NOT obvious, use `bmad:bmad-debugging`
- **One-line changes** — Just do it
- **Exploration/research** — Use exploration tools directly
- **Refactoring with no behavior change** — Execution skills suffice

## Beads Integration (Optional)

BMAD skills optionally integrate with **beads** for issue-based tracking. When a ticket ID is provided, the ticket becomes the spec artifact. No local files are created — all content lives in beads fields and sub-tickets.

### Ticket-Based Workflow
```
bd create "Add avatar upload" -t feature    # idea captured
... later ...
/quick-spec bd-abc123                       # spec develops IN the ticket
/quick-dev bd-abc123                        # implementation tracked via sub-tickets
bd close bd-abc123                          # done
```

### Issue Field Mapping

| BMAD Artifact | Beads Field | Purpose |
|---|---|---|
| Spec summary (problem, solution, scope) | `design` | Design notes |
| Acceptance criteria (Given/When/Then) | `acceptance_criteria` | Exact purpose match |
| Technical context + task list | `notes` | Implementation details |
| Implementation tasks | Sub-tickets | Individual task tracking |
| BMAD state machine | `metadata` (JSON) | Machine-readable phase/step tracking |
| Phase transitions + decisions | `comments` | Human-readable audit trail |

### How It Works
- **Detection:** Skills check for beads by running `which bd`. **The `bd` CLI discovers `.beads/` by walking up from CWD, so all `bd` commands must be run from within the project directory.** If beads is not installed, CWD is outside the project tree, or no ticket ID is provided, all beads steps are silently skipped.
- **Beads-primary:** When a ticket ID is provided, all spec content is written to ticket fields. Local files are only created when beads is not active.
- **Sub-tickets as tasks:** Implementation tasks from quick-spec become sub-tickets. Quick-dev tracks progress by updating and closing sub-tickets.
- **Metadata read-merge-write:** `bd update --metadata` replaces the full JSON blob, so skills always read current metadata first (`bd show {ticket_id} --json`), merge new fields, then write the full object back.
- **Comments at phase boundaries only:** One comment per phase transition (4 for quick-spec, 6 for quick-dev) to avoid noise.

## Available Skills

### Flow Skills (invoke these to run a workflow)
- **`bmad-quick-spec`** — Conversational spec engineering: understand → investigate → generate → review. Produces a ready-for-dev tech spec.
- **`bmad-quick-dev`** — Implementation flow: mode detection → context gathering → execution → self-check → adversarial review → resolve findings.
- **`bmad-complexity-assessment`** — Evaluate complexity signals and route to the right depth of planning.

### Methodology Skills (invoked by flow skills or standalone)
- **`bmad-tdd`** — Test-driven development: Iron Law, Red-Green-Refactor cycle, rationalizations, red flags. Built into quick-dev's execution loop.
- **`bmad-debugging`** — Systematic debugging: 4-phase root cause methodology (investigate → analyze → hypothesize → implement). Activated by quick-dev halt conditions. Includes 3 supporting docs (root-cause-tracing, defense-in-depth, condition-based-waiting).
- **`bmad-verification`** — Verification before completion: 5-step gate function requiring fresh evidence for every completion claim. Invoked at quick-dev Phases 4 and 6.
- **`bmad-parallel-agents`** — Parallel agent dispatch: identify independent domains, craft focused prompts, dispatch via Task tool, review and integrate. Optional in quick-dev Phase 3.
- **`bmad-worktrees`** — Git worktree creation with ticket-based branch naming. Auto-creates worktrees for beads tickets. Invoked at quick-dev Phases 1 and 6.
- **`bmad-spec-engineering`** — Given/When/Then acceptance criteria format and ready-for-dev standards.
- **`bmad-adversarial-review`** — Code review with information asymmetry using subagents.

### Reference Skills (look up personas and templates)
- **`bmad-personas`** — Index of 8 expert personas (analyst, architect, dev, PM, QA, scrum master, UX designer, solo dev).
- **`bmad-artifact-templates`** — Index of 8 output templates (tech-spec, story, PRD, product brief, architecture decision, epics, UX design, sprint status).

## Slash Commands

- **`/quick-spec [ticket-id]`** — Start the quick-spec flow (optionally against a beads ticket)
- **`/quick-dev [ticket-id]`** — Start the quick-dev flow (optionally against a beads ticket)
- **`/assess-complexity`** — Run complexity assessment

## Self-Contained Methodology

BMAD owns all its methodology and execution skills — from planning (spec engineering, complexity routing) through execution (TDD, debugging, verification, parallel agents, worktrees) to review (adversarial review). No external plugin dependencies are required.
