# Beads Workflow Pipeline

This project uses [beads](https://github.com/steveyegge/beads) formulas to drive a structured development lifecycle adapted from the MELD v6.0 methodology. Formulas define **what** happens and **in what order**; skill files define **how** each step is executed.

## Available Formulas

| Formula | Phase | Steps | Human Gates | Use When |
|---------|-------|-------|-------------|----------|
| `meld-analysis` | 1 | 4 | 1 | Starting a new product — discover vision, users, metrics, scope |
| `meld-planning` | 2 | 6 | 2 | Creating PRD and UX design specification |
| `meld-solutioning` | 3 | 6 | 2 | Architecture decisions, epics, stories, readiness check |
| `meld-implementation` | 4 | 7 | 2 | Sprint execution — plan, develop, review, retrospective |
| `meld-quick-spec` | — | 4 | 1 | Conversational spec engineering — produce implementation-ready tech-spec |
| `meld-quick-dev` | — | 6 | 1 | Flexible implementation — execute tech-specs or direct instructions |
| `meld-full` | 1–4 | 23 | 7 | Full product lifecycle from idea to working code |

List all formulas:

```bash
bd formula list
```

Preview a formula without creating anything:

```bash
bd cook meld-solutioning --dry-run --var project_name="MyApp"
```

## Quick Start

### Option A: Full pipeline (new product)

```bash
bd mol pour meld-full --var project_name="MyApp"
bd ready          # shows first step: "Initialize brief and discover vision for MyApp"
```

### Option B: Single phase

```bash
bd mol pour meld-solutioning --var project_name="MyApp"
```

### Option C: Quick spec (produce a tech-spec)

```bash
bd mol pour meld-quick-spec \
  --var project_name="MyApp" \
  --var feature="Add avatar upload"
```

### Option D: Quick dev (implement from spec or direct)

```bash
# Mode A — from a tech-spec
bd mol pour meld-quick-dev \
  --var project_name="MyApp" \
  --var feature="Add avatar upload" \
  --var tech_spec_path="meld-output/implementation-artifacts/tech-spec-avatar-upload.md"

# Mode B — direct instructions
bd mol pour meld-quick-dev \
  --var project_name="MyApp" \
  --var feature="Add avatar upload"
```

## Working a Step

Once a formula is poured, steps become beads issues with dependencies. The flow is:

```bash
bd ready                              # find next unblocked step
bd show <id>                          # read step description
bd update <id> --status=in_progress   # claim it
# ... do the work (see "Executing a Step" below) ...
bd close <id>                         # mark complete
bd ready                              # next step unlocks
```

### Executing a Step

Each step description tells you which **agent persona** and **skill file** to follow:

```
Agent: Winston (Architect)
Follow: .beads/skills/meld/phase-3-solutioning/create-architecture/step-02-decisions.md
```

1. **Load the persona** — Read `.beads/skills/meld/agents/architect.md` to adopt Winston's communication style and principles.
2. **Read the skill file** — The skill file contains detailed instructions, success criteria, and expected outputs.
3. **Do the work** — Follow the instructions, produce the artifacts.
4. **Close the step** — `bd close <id>` when success criteria are met.

### Human Gates

Steps marked `(human)` in the formula are review gates. They require a person to verify the previous work before the pipeline continues. These steps appear in `bd ready` once their dependencies are satisfied but need manual approval to close.

## Agent Personas

Each workflow step references an agent persona that defines the communication style and expertise for that step:

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

Persona files live in `.beads/skills/meld/agents/`.

## Phase Breakdown

### Phase 1: Analysis (`meld-analysis`)

Produces a **product brief** through collaborative discovery with the Analyst persona.

| Step | ID | Description |
|------|----|-------------|
| 1 | `brief-init` | Discover input docs, define vision and core problem |
| 2 | `brief-discover` | Define target users and success metrics |
| 3 | `brief-draft` | Define MVP scope and future vision |
| 4 | `brief-review` | Human gate — approve product brief |

**Output:** `meld-output/planning-artifacts/product-brief-<name>.md`

### Phase 2: Planning (`meld-planning`)

Produces a **PRD** and **UX design specification**.

| Step | ID | Description |
|------|----|-------------|
| 1 | `prd-init` | Initialize PRD, classify project, define success criteria |
| 2 | `prd-definition` | User journeys, domain requirements, project-type deep dive |
| 3 | `prd-requirements` | Functional requirements (capability contract), NFRs, MVP scope |
| 4 | `prd-review` | Human gate — approve PRD |
| 5 | `ux-design` | UX foundation, visual direction, design system, user flows |
| 6 | `ux-review` | Human gate — approve UX specification |

**Outputs:** `prd.md`, `ux-design-specification.md`

### Phase 3: Solutioning (`meld-solutioning`)

Produces **architecture decisions**, **epics**, and **stories**.

| Step | ID | Description |
|------|----|-------------|
| 1 | `arch-init` | Analyze project context, evaluate starter templates |
| 2 | `arch-decisions` | ADRs, implementation patterns, project structure |
| 3 | `arch-review` | Human gate — approve architecture |
| 4 | `epics-create` | Design epic structure with FR coverage mapping |
| 5 | `stories-create` | Generate stories with Given/When/Then acceptance criteria |
| 6 | `readiness-check` | Human gate — adversarial readiness validation |

**Outputs:** `architecture.md`, `epics.md`, story files

### Phase 4: Implementation (`meld-implementation`)

Executes sprints: **plan → develop → review → retrospective**.

| Step | ID | Description |
|------|----|-------------|
| 1 | `sprint-plan` | Generate sprint-status.yaml, sequence stories |
| 2 | `sprint-plan-review` | Human gate — approve sprint plan |
| 3 | `story-prep` | Prepare next story with full developer context |
| 4 | `story-dev` | Implement story (red-green-refactor, all tests passing) |
| 5 | `story-review` | Adversarial code review (minimum 3 findings) |
| 6 | `story-review-gate` | Human gate — approve story completion |
| 7 | `sprint-retro` | Epic retrospective (all agents, Party Mode) |

For multi-story sprints, repeat steps 3–6 for each story before the retrospective.

**Outputs:** `sprint-status.yaml`, story files, implemented code

### Quick Spec (`meld-quick-spec`)

Conversational spec engineering — ask questions, investigate code, produce implementation-ready tech-spec with WIP file lifecycle and adversarial review option.

| Step | ID | Description |
|------|----|-------------|
| 1 | `understand` | Greet user, orient scan, ask informed questions, capture core understanding, create WIP file |
| 2 | `investigate` | Deep code investigation — map tech stack, patterns, files to modify, test patterns |
| 3 | `generate` | Generate dependency-ordered tasks, Given/When/Then ACs, testing strategy |
| 4 | `review` | Human gate — present spec, iterate feedback, adversarial review option, finalize |

**Output:** `{{impl_artifacts}}/tech-spec-{slug}.md`

### Quick Dev (`meld-quick-dev`)

Flexible implementation engine — execute tech-specs (Mode A) or direct instructions (Mode B) with escalation assessment, continuous execution, self-check, and adversarial review.

| Step | ID | Description |
|------|----|-------------|
| 1 | `mode-detect` | Capture baseline commit, determine Mode A/B, evaluate escalation |
| 2 | `context-gather` | Mode B: identify files/patterns/dependencies, create plan. Mode A: load spec |
| 3 | `execute` | Implement all tasks continuously (red-green-refactor), halt only on blockers |
| 4 | `self-check` | Self-audit: tasks, tests, ACs, patterns. Update tech-spec if Mode A |
| 5 | `adversarial-review` | Construct diff from baseline, adversarial code review with information asymmetry |
| 6 | `resolve-findings` | Human gate — walk through / auto-fix / skip findings, finalize |

## Molecule Lifecycle

Formulas are poured into **molecules** (persistent) or **wisps** (ephemeral):

```bash
# Persistent — tracked in git, survives across sessions
bd mol pour meld-analysis --var project_name="MyApp"

# Ephemeral — auto-cleaned, no git sync
bd mol wisp meld-quick-spec --var project_name="MyApp" --var feature="Fix bug"

# Check molecule progress
bd mol progress <mol-id>

# See current position
bd mol current <mol-id>
```

Use `pour` for feature implementations and multi-session work. Use `wisp` for one-off tasks like health checks or quick fixes.

## File Structure

```
.beads/
├── formulas/                           # 7 TOML workflow definitions
│   ├── meld-analysis.formula.toml
│   ├── meld-planning.formula.toml
│   ├── meld-solutioning.formula.toml
│   ├── meld-implementation.formula.toml
│   ├── meld-quick-spec.formula.toml
│   ├── meld-quick-dev.formula.toml
│   └── meld-full.formula.toml
│
└── skills/meld/
    ├── agents/                         # 8 agent persona files
    ├── phase-1-analysis/               # 4 skill files
    ├── phase-2-planning/               # 6 skill files (PRD + UX)
    ├── phase-3-solutioning/            # 6 skill files (arch + epics + readiness)
    ├── phase-4-implementation/         # 5 skill files (sprint + dev + review + retro)
    ├── quick-spec/                     # 4 skill files (understand + investigate + generate + review)
    ├── quick-dev/                      # 6 skill files (mode-detect + context + execute + self-check + review + resolve)
    └── templates/                      # 8 output document templates
```

## Variables

Each formula accepts variables via `--var key=value`:

| Variable | Required | Default | Used By |
|----------|----------|---------|---------|
| `project_name` | Yes | — | All formulas |
| `feature` | Yes | — | `meld-quick-spec`, `meld-quick-dev` |
| `tech_spec_path` | No | — | `meld-quick-dev` only (Mode A if provided) |
| `planning_artifacts` | No | `meld-output/planning-artifacts` | Phases 1–3, full |
| `impl_artifacts` | No | `meld-output/implementation-artifacts` | Phases 3–4, full |
