# Migrating from Beads to Plugin Model

This guide helps existing bmad-beads users transition from the beads formula model to the Claude Code plugin model.

## What Changed

| Before (Beads) | After (Plugin) |
|----------------|----------------|
| `./install.sh /path/to/project` | `/plugin install bmad` |
| `bd mol pour bmad-quick-spec --var ...` | `/quick-spec` |
| `bd mol pour bmad-quick-dev --var ...` | `/quick-dev` |
| Steps create beads issues | Skills track progress via TodoWrite |
| `bd ready` / `bd close` to navigate | Agent auto-progresses through phases |
| Variables via `--var` flags | State tracked in conversation context |
| Skills at `.beads/skills/bmad/` | Skills at plugin `skills/` directory |

## What Stays the Same

- **Personas** — Same 8 agents with same identities and communication styles
- **Templates** — Same 8 output templates with same structure
- **Methodology** — Same phases, same quality gates, same ready-for-dev standard
- **Adversarial review** — Same information asymmetry pattern
- **Full pipeline formulas** — Still available for users who prefer beads orchestration

## Migration Steps

### 1. Install the Plugin

```bash
# If you cloned bmad-beads locally:
/plugin marketplace add /path/to/bmad-beads
/plugin install bmad

# Or from the remote marketplace:
/plugin marketplace add https://github.com/solomonjames/bmad-beads
/plugin install bmad
```

### 2. Use Slash Commands Instead of Formulas

**Before:**
```bash
bd mol pour bmad-quick-spec --var project_name="MyApp" --var feature="Add avatar upload"
bd ready
bd show understand
bd update understand --status=in_progress
# ... agent works through step ...
bd close understand
bd ready
# ... repeat for each step ...
```

**After:**
```
/quick-spec
# Agent runs the entire flow conversationally
# Human gates still pause for your approval
```

### 3. Update Your Workflow

- **No more formula pouring** — Skills activate via slash commands or auto-triggering
- **No more step navigation** — The agent progresses through phases automatically
- **Human gates still work** — The agent pauses for your approval at review points
- **Output artifacts** — Still written to `_bmad-output/` (or wherever you configure)

### 4. Optional: Keep Beads for Full Pipeline

The full BMAD pipeline (phases 1-4) is still only available via beads formulas. The plugin MVP covers quick-spec and quick-dev flows. If you need the full pipeline:

```bash
# Legacy install still works
./legacy/install.sh /path/to/your/project
```

## Beads Integration Going Forward

Beads formulas remain in the `formulas/` directory and the original step files remain in `skills/bmad/`. The `legacy/install.sh` script copies these into beads-enabled projects. Formula step descriptions now include `Plugin skill:` references alongside `Follow:` paths, so both models point to the same methodology.

## Superpowers Integration

The plugin model enables a new integration with superpowers. When both plugins are installed:

- `bmad-quick-dev` delegates execution to `superpowers:test-driven-development`
- `bmad-adversarial-review` complements `superpowers:verification-before-completion`
- `bmad-complexity-assessment` can route to `superpowers:brainstorming` for design-heavy work

This integration is automatic — BMAD skills reference superpowers skills, and if superpowers is installed, the agent uses them.
