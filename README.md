# BMAD-Beads

BMAD (Business-driven Multi-Agent Development) methodology ported to [beads](https://github.com/steveyegge/beads) formulas. Framework-agnostic, language-agnostic — works with any AI coding assistant in any project.

BMAD provides a structured development lifecycle with agent personas, human review gates, and a progressive pipeline from product discovery through implementation. Beads formulas orchestrate the workflow; skill files define how each step is executed.

## Prerequisites

- [beads](https://github.com/steveyegge/beads) v0.55+ installed
- `bd init` run in your target project
- An AI coding assistant (Claude Code, Cursor, etc.)

## Install

```bash
git clone https://github.com/solomonjames/bmad-beads.git
cd bmad-beads
./install.sh /path/to/your/project
```

This copies formulas into `.beads/formulas/` and skills into `.beads/skills/bmad/` in your target project.

To install into the current directory (if it has `.beads/`):

```bash
./install.sh
```

### Linked install

Use `--link` to create symlinks instead of copies:

```bash
./install.sh --link /path/to/your/project
```

With a linked install, updates to the bmad-beads source files are reflected immediately in the target project — no need to re-run `install.sh` after `git pull`. The flag can appear before or after the target path.

This also enables a **self-referencing** workflow for developing bmad-beads itself:

```bash
bd init
./install.sh --link
```

## Quickstart

### Full pipeline (new product, idea to code)

```bash
bd mol pour bmad-full --var project_name="MyApp"
bd ready    # first step: "Initialize brief and discover vision for MyApp"
```

### Single phase

```bash
bd mol pour bmad-solutioning --var project_name="MyApp"
```

### Quick spec (produce a tech-spec conversationally)

```bash
bd mol pour bmad-quick-spec \
  --var project_name="MyApp" \
  --var feature="Add avatar upload"
```

### Quick dev (implement from spec or direct instructions)

```bash
# Mode A — from a tech-spec
bd mol pour bmad-quick-dev \
  --var project_name="MyApp" \
  --var feature="Add avatar upload" \
  --var tech_spec_path="path/to/tech-spec-avatar-upload.md"

# Mode B — direct instructions (no tech-spec)
bd mol pour bmad-quick-dev \
  --var project_name="MyApp" \
  --var feature="Add avatar upload"
```

## Formula Reference

| Formula | Phase | Steps | Human Gates | Use When |
|---------|-------|-------|-------------|----------|
| `bmad-analysis` | 1 | 4 | 1 | Starting a new product — discover vision, users, metrics, scope |
| `bmad-planning` | 2 | 6 | 2 | Creating PRD and UX design specification |
| `bmad-solutioning` | 3 | 6 | 2 | Architecture decisions, epics, stories, readiness check |
| `bmad-implementation` | 4 | 7 | 2 | Sprint execution — plan, develop, review, retrospective |
| `bmad-quick-spec` | — | 4 | 1 | Conversational spec engineering — produce implementation-ready tech-spec |
| `bmad-quick-dev` | — | 6 | 1 | Flexible implementation — execute tech-specs or direct instructions |
| `bmad-full` | 1–4 | 23 | 7 | Full product lifecycle from idea to working code |

Preview any formula without creating anything:

```bash
bd cook bmad-solutioning --dry-run --var project_name="MyApp"
```

## Variable Reference

| Variable | Required | Default | Used By |
|----------|----------|---------|---------|
| `project_name` | Yes | — | All formulas |
| `feature` | Yes | — | `bmad-quick-spec`, `bmad-quick-dev` |
| `tech_spec_path` | No | — | `bmad-quick-dev` only (Mode A if provided) |
| `planning_artifacts` | No | `_bmad-output/planning-artifacts` | Phases 1–3, full |
| `impl_artifacts` | No | `_bmad-output/implementation-artifacts` | Phases 3–4, quick-spec, quick-dev, full |

## Working a Step

Once a formula is poured, steps become beads issues with dependencies:

```bash
bd ready                              # find next unblocked step
bd show <id>                          # read step description
bd update <id> --status=in_progress   # claim it
# ... do the work ...
bd close <id>                         # mark complete
bd ready                              # next step unlocks
```

Each step description names an **agent persona** and a **skill file**:

```
Agent: Winston (Architect)
Follow: .beads/skills/bmad/phase-3-solutioning/create-architecture/step-02-decisions.md
```

1. **Load the persona** — Read the agent file to adopt communication style and principles
2. **Read the skill file** — Contains detailed instructions, success criteria, expected outputs
3. **Do the work** — Follow the instructions, produce artifacts
4. **Close the step** — `bd close <id>` when success criteria are met

Steps marked `(human)` are review gates requiring manual approval before the pipeline continues.

### Agent Personas

| Agent | Name | Specialty |
|-------|------|-----------|
| `analyst.md` | Mary | Business analysis, market research, requirements |
| `architect.md` | Winston | System architecture, technology selection, patterns |
| `pm.md` | John | Product management, PRD creation, stakeholder alignment |
| `dev.md` | Amelia | Implementation, TDD, strict story adherence |
| `qa.md` | Quinn | Test automation, coverage, quality assurance |
| `sm.md` | Bob | Scrum mastery, story preparation, sprint planning |
| `ux-designer.md` | Sally | UX design, user research, visual direction |
| `quick-flow-solo-dev.md` | Barry | Full-stack quick flow, spec-to-implementation |

## Customization

To override BMAD skill files without modifying the originals, create a `bmad-local/` namespace:

```
.beads/skills/bmad-local/
  agents/architect.md          # your custom architect persona
  phase-4-implementation/...   # your custom implementation steps
```

Then update the formula step descriptions to point to your override paths. The original `bmad/` files remain untouched for easy updates.

## Updating

For **copy** installs, re-run the install after pulling:

```bash
cd /path/to/bmad-beads
git pull
./install.sh /path/to/your/project
```

After updating, review changes with `git diff .beads/` in your project.

For **linked** installs, just pull — symlinks point to the source files directly:

```bash
cd /path/to/bmad-beads
git pull
# Done — target project already sees the updated files
```

## Uninstall

```bash
cd /path/to/bmad-beads
./uninstall.sh /path/to/your/project
```

Removes all `bmad-*.formula.toml` files and the `.beads/skills/bmad/` directory.

## Path Contract

Skills **must** live at `.beads/skills/bmad/` relative to the project root. Formulas reference skill files via these paths in step descriptions (e.g., `Follow: .beads/skills/bmad/...`). These paths are resolved by the AI agent at execution time, not by beads itself. Moving skills to a different location will break the formula references.

## License

MIT
