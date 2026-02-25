# BMAD-Beads

BMAD (Business-driven Multi-Agent Development) methodology as a **Claude Code plugin**. Adds structured product development — personas, complexity routing, spec engineering, adversarial review — on top of your existing development workflow.

Self-contained methodology with built-in execution skills (TDD, debugging, verification, parallel agents, worktrees).

## Install

### As a Claude Code plugin (recommended)

```bash
# Add the marketplace
/plugin marketplace add https://github.com/solomonjames/bmad-beads

# Install the plugin
/plugin install bmad
```

### From local clone

```bash
git clone https://github.com/solomonjames/bmad-beads.git
cd bmad-beads
/plugin marketplace add .
/plugin install bmad
```

## Quick Start

### Slash commands

```
/quick-spec          # Conversational spec engineering — produces a ready-for-dev tech spec
/quick-dev           # Implementation flow — mode detection, execution, review
/assess-complexity   # Evaluate complexity and route to right depth of planning
```

### Direct skill invocation

Skills can also be invoked directly via the Skill tool:

```
bmad:bmad-quick-spec
bmad:bmad-quick-dev
bmad:bmad-complexity-assessment
bmad:bmad-spec-engineering
bmad:bmad-adversarial-review
bmad:bmad-personas
bmad:bmad-artifact-templates
```

## How It Works

BMAD provides **methodology skills** that structure how you approach development:

1. **Assess complexity** — Count complexity signals, route to direct execution, quick-spec, or full planning
2. **Spec engineering** — Conversational flow that produces a ready-for-dev tech spec with Given/When/Then acceptance criteria
3. **Implementation** — Mode A (from tech-spec) or Mode B (direct instructions) with continuous execution
4. **Self-check** — 12-point audit covering tasks, tests, ACs, and code quality
5. **Adversarial review** — Code review with information asymmetry (reviewer sees only the diff)
6. **Finding resolution** — Walk through, auto-fix, or skip findings with human approval

## Skills Reference

### Flow Skills

| Skill | Command | Description |
|-------|---------|-------------|
| `bmad-quick-spec` | `/quick-spec` | 4-phase spec engineering: understand, investigate, generate, review |
| `bmad-quick-dev` | `/quick-dev` | 6-phase implementation: mode detect, context, execute, self-check, review, resolve |
| `bmad-complexity-assessment` | `/assess-complexity` | Complexity signals → routing to right depth |

### Methodology Skills

| Skill | Description |
|-------|-------------|
| `bmad-tdd` | Test-driven development (Red-Green-Refactor), built into quick-dev |
| `bmad-debugging` | Systematic debugging: 4-phase root cause methodology |
| `bmad-verification` | Verification before completion: 5-step gate function |
| `bmad-parallel-agents` | Parallel agent dispatch and integration |
| `bmad-worktrees` | Git worktree creation with ticket-based branch naming |
| `bmad-spec-engineering` | Given/When/Then format, task format, ready-for-dev standards |
| `bmad-adversarial-review` | Information-asymmetric code review via subagents |

### Reference Skills

| Skill | Description |
|-------|-------------|
| `bmad-personas` | 8 expert personas (analyst, architect, dev, PM, QA, SM, UX, solo dev) |
| `bmad-artifact-templates` | 8 output templates (tech-spec, story, PRD, architecture, etc.) |

## Agent Personas

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

## Beads Integration (Optional)

BMAD also works as a beads formula system for users who prefer ticket-based orchestration. See [docs/beads-workflows.md](docs/beads-workflows.md) for details.

```bash
# Install for beads (legacy method)
./legacy/install.sh /path/to/your/project

# Pour a formula
bd mol pour bmad-quick-spec --var project_name="MyApp" --var feature="Add avatar upload"
```

### Formula Reference

| Formula | Steps | Gates | Use When |
|---------|-------|-------|----------|
| `bmad-analysis` | 4 | 1 | Product vision, users, metrics, scope |
| `bmad-planning` | 6 | 2 | PRD and UX design specification |
| `bmad-solutioning` | 6 | 2 | Architecture, epics, stories, readiness |
| `bmad-implementation` | 7 | 2 | Sprint execution and review |
| `bmad-quick-spec` | 4 | 1 | Conversational spec engineering |
| `bmad-quick-dev` | 6 | 1 | Flexible implementation |
| `bmad-full` | 23 | 7 | Complete product lifecycle |

## License

MIT
