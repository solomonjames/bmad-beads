---
name: bmad-artifact-templates
description: Use when you need a structured output template for BMAD workflow artifacts — provides templates for tech specs, stories, PRDs, architecture decisions, and more
---

# BMAD Artifact Templates

Templates define the **structure and sections** for BMAD workflow outputs. When a skill says "use the tech-spec template," read the referenced file and follow its structure.

## How to Use Templates

1. Read the template file referenced by the current skill
2. Fill in sections progressively as the workflow advances
3. Use YAML frontmatter for metadata tracking (status, stepsCompleted, etc.)
4. Templates use `{{variable}}` placeholders — replace with actual values

## Available Templates

| Template | File | Produced By | Contains |
|----------|------|-------------|----------|
| Tech Spec | `tech-spec.md` | `bmad-quick-spec` | Overview, context, implementation tasks, acceptance criteria |
| Story | `story.md` | Full BMAD pipeline | User story, ACs, tasks, dev notes |
| PRD | `prd.md` | Phase 2 planning | Product requirements, user journeys, scope |
| Product Brief | `product-brief.md` | Phase 1 analysis | Vision, target users, success metrics, MVP scope |
| Architecture Decision | `architecture-decision.md` | Phase 3 solutioning | Tech selection, ADRs, patterns, project structure |
| Epics | `epics.md` | Phase 3 solutioning | Epic/story breakdown, FR coverage |
| UX Design | `ux-design.md` | Phase 2 planning | Design system, user flows, components, accessibility |
| Sprint Status | `sprint-status.yaml` | Phase 4 implementation | YAML tracking of epic/story status |

## Most Common Template

For quick flows, the **tech-spec** template is the primary output. It tracks progress via `stepsCompleted` in frontmatter and transitions through statuses: `in-progress` → `review` → `ready-for-dev` → `completed`.
