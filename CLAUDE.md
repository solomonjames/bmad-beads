# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BMAD-Beads is a workflow orchestration framework that ports the BMAD (Business-driven Multi-Agent Development) methodology v6.0 into [beads](https://github.com/steveyegge/beads) formulas. It provides structured product development with AI agent personas, human review gates, and a progressive pipeline from product discovery through implementation. This is **not** a code library — it is a template/workflow system with no build step, no tests, and no package manager.

## Repository Structure

- `formulas/` — 7 TOML workflow definitions (copied to target project's `.beads/formulas/`)
- `skills/bmad/agents/` — 8 agent persona files defining communication style and expertise
- `skills/bmad/phase-{1..4}-*/` — Step-by-step skill files for each pipeline phase
- `skills/bmad/quick-spec/` — 4-step conversational spec engineering flow
- `skills/bmad/quick-dev/` — 6-step flexible implementation flow
- `skills/bmad/templates/` — 8 output document templates (tech-spec, story, PRD, etc.)
- `install.sh` / `uninstall.sh` — Copy formulas and skills into a beads-enabled target project
- `docs/beads-workflows.md` — Comprehensive workflow documentation

## How It Works

Formulas (TOML) define **step sequences with dependencies**. Each step references an **agent persona** (who) and a **skill file** (how). Skill files contain detailed instructions, success criteria, and expected outputs. Human review gates require manual approval before the pipeline continues.

When installed into a target project, formulas go to `.beads/formulas/` and skills go to `.beads/skills/bmad/`. The AI agent reads step descriptions, loads the referenced persona, follows the skill file instructions, and produces output artifacts in `_bmad-output/`.

## Key Commands

```bash
# Installation
./install.sh /path/to/target    # Install into a beads-enabled project
./install.sh                     # Install into current directory
./uninstall.sh /path/to/target   # Remove from target project

# Preview a formula without creating anything
bd cook bmad-solutioning --dry-run --var project_name="MyApp"

# Pour a formula (create a persistent molecule)
bd mol pour bmad-full --var project_name="MyApp"

# Work through steps
bd ready                              # Find next unblocked step
bd show <id>                          # Read step description
bd update <id> --status=in_progress   # Claim it
bd close <id>                         # Mark complete
```

## Path Contract

Skill files **must** live at `.beads/skills/bmad/` relative to the target project root. Formula step descriptions reference skill files via these paths (e.g., `Follow: .beads/skills/bmad/phase-3-solutioning/create-architecture/step-02-decisions.md`). These paths are resolved by the AI agent at execution time, not by beads itself. Moving skills breaks formula references.

## Customization Pattern

Override skill files by creating a `bmad-local/` namespace in `.beads/skills/` in the target project, then updating formula step descriptions to point to the override paths. Original `bmad/` files stay untouched for easy updates via `git pull && ./install.sh`.

## Variables

All formulas require `--var project_name="..."`. Quick flows also require `--var feature="..."`. Optional: `tech_spec_path` (quick-dev Mode A), `planning_artifacts`, `impl_artifacts`.

## Editing Guidelines

- Formula files use TOML with `[[step]]` arrays defining workflow sequences. Each step has `id`, `title`, `description`, `depends_on`, and variable interpolation via `{{var_name}}`.
- Skill files are Markdown with consistent sections: Agent, Context (inputs/outputs/dependencies), Instructions, Success Criteria, and Next Step pointer.
- Agent persona files define Identity, Communication Style, Core Principles, and Activation Triggers.
- Templates use YAML frontmatter for metadata tracking (e.g., `stepsCompleted` for WIP lifecycle).
- When adding new steps, maintain the dependency chain — each step's `depends_on` must reference existing step IDs.
