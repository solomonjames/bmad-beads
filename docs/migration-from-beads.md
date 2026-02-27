# Migrating from Beads to Plugin Model

This guide helps existing meld users transition from the beads formula model to the Claude Code plugin model.

## What Changed

| Before (Beads) | After (Plugin) |
|----------------|----------------|
| `./install.sh /path/to/project` | `/plugin install meld` |
| `bd mol pour meld-quick-spec --var ...` | `/quick-spec` |
| `bd mol pour meld-quick-dev --var ...` | `/quick-dev` |
| Steps create beads issues | Skills track progress via TodoWrite |
| `bd ready` / `bd close` to navigate | Agent auto-progresses through phases |
| Variables via `--var` flags | State tracked in conversation context |
| Skills at `.beads/skills/meld/` | Skills at plugin `skills/` directory |

## What Stays the Same

- **Personas** — Same 8 agents with same identities and communication styles
- **Templates** — Same 8 output templates with same structure
- **Methodology** — Same phases, same quality gates, same ready-for-dev standard
- **Adversarial review** — Same information asymmetry pattern
- **Full pipeline formulas** — Still available for users who prefer beads orchestration

## Migration Steps

### 1. Install the Plugin

```bash
# If you cloned meld locally:
/plugin marketplace add /path/to/meld
/plugin install meld

# Or from the remote marketplace:
/plugin marketplace add https://github.com/solomonjames/meld
/plugin install meld
```

### 2. Use Slash Commands Instead of Formulas

**Before:**
```bash
bd mol pour meld-quick-spec --var project_name="MyApp" --var feature="Add avatar upload"
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
- **Output artifacts** — Still written to `meld-output/` (or wherever you configure)

### 4. Optional: Keep Beads for Full Pipeline

The full MELD pipeline (phases 1-4) is still only available via beads formulas. The plugin MVP covers quick-spec and quick-dev flows. If you need the full pipeline:

```bash
# Legacy install still works
./legacy/install.sh /path/to/your/project
```

## Beads Integration Going Forward

Beads formulas remain in the `formulas/` directory and the original step files remain in `skills/meld/`. The `legacy/install.sh` script copies these into beads-enabled projects. Formula step descriptions now include `Plugin skill:` references alongside `Follow:` paths, so both models point to the same methodology.
