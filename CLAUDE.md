# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BMAD-Beads is a Claude Code plugin that implements the BMAD (Business-driven Multi-Agent Development) methodology. It provides structured product development with agent personas, complexity routing, spec engineering, and adversarial review. It complements execution-focused plugins like superpowers by adding methodology skills.

This is **not** a code library — it is a plugin/workflow system with no build step, no tests, and no package manager.

## Repository Structure

### Plugin Infrastructure
- `.claude-plugin/plugin.json` — Plugin manifest (name, version, metadata)
- `.claude-plugin/marketplace.json` — Self-hosted marketplace config
- `hooks/` — SessionStart hook that injects `using-bmad` meta-skill into context
- `commands/` — Slash commands (`/quick-spec`, `/quick-dev`, `/assess-complexity`)

### Skills (Plugin Skills)
- `skills/using-bmad/` — Meta-skill: routing table for when to use BMAD vs other skills
- `skills/bmad-quick-spec/` — Merged 4-phase spec engineering flow
- `skills/bmad-quick-dev/` — Merged 6-phase implementation flow + adversarial reviewer prompt
- `skills/bmad-complexity-assessment/` — Complexity signal evaluation and routing
- `skills/bmad-spec-engineering/` — Given/When/Then format, ready-for-dev standards
- `skills/bmad-adversarial-review/` — Information-asymmetric code review + reviewer prompt
- `skills/bmad-personas/` — 8 expert persona files + index
- `skills/bmad-artifact-templates/` — 8 output templates + index

### Beads Integration (Legacy)
- `formulas/` — 7 TOML workflow definitions for beads users
- `skills/bmad/` — Original step-by-step skill files for beads formulas
- `legacy/install.sh` / `legacy/uninstall.sh` — Copy formulas/skills into beads-enabled projects
- `docs/beads-workflows.md` — Beads workflow documentation

## How It Works

### As a Plugin
The SessionStart hook injects the `using-bmad` meta-skill into every session. This provides a routing table so the agent knows when to invoke BMAD skills. Users trigger flows via slash commands (`/quick-spec`) or direct skill invocation (`bmad:bmad-quick-spec`).

### As Beads Formulas
Formulas (TOML) define step sequences with dependencies. Each step references an agent persona and a skill file. The `legacy/install.sh` script copies formulas and skills into a beads-enabled project.

## Skill Authoring

Each plugin skill is a single `SKILL.md` file with:
- **YAML frontmatter:** `name` and `description` (used for skill discovery and auto-triggering)
- **Checklist:** Items tracked via TodoWrite during execution
- **Phases:** Logical groupings of work within the skill
- **Sub-skill references:** `bmad:skill-name` for other BMAD skills, `superpowers:skill-name` for superpowers skills

### Naming Convention
All skills are prefixed `bmad-` to avoid collisions. Invoked as `bmad:bmad-quick-spec` (plugin:skill format).

### Persona Pattern
Skills reference personas by saying "Adopt the Barry persona from `bmad:bmad-personas`." The agent reads the persona file and embodies that identity throughout the workflow.

## Key Patterns

- **Soft dependencies on superpowers:** Skills say `**REQUIRED SUB-SKILL:** Use superpowers:test-driven-development`. If superpowers isn't installed, the agent falls back gracefully.
- **Information asymmetry in reviews:** Adversarial review uses a subagent that sees ONLY the diff, not the spec or conversation.
- **Human gates:** Flow skills pause for human approval at key points (spec review, finding resolution).
- **WIP lifecycle:** Tech specs track progress via `stepsCompleted` in YAML frontmatter and transition through statuses: `in-progress` → `review` → `ready-for-dev` → `completed`.

## Editing Guidelines

- **Plugin skills** (`skills/bmad-*/SKILL.md`): Single file per skill with YAML frontmatter. Follow superpowers' writing-skills guidance for length and structure.
- **Commands** (`commands/*.md`): Lightweight wrappers with YAML frontmatter (`description`, `disable-model-invocation: true`) that invoke a skill.
- **Hooks** (`hooks/`): SessionStart injects meta-skill content. Uses JSON output compatible with both Cursor and Claude Code.
- **Personas** (`skills/bmad-personas/*.md`): Define Identity, Communication Style, Core Principles, Activation Triggers.
- **Templates** (`skills/bmad-artifact-templates/*.md`): Use `{{variable}}` placeholders and YAML frontmatter for metadata.
- **Beads formulas** (`formulas/*.toml`): TOML with `[[step]]` arrays. Each step has `id`, `title`, `description`, `depends_on`.
