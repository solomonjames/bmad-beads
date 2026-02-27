# Step: Quick Dev — Mode Detection

## Agent
- **Name:** Barry (Quick Flow Solo Dev)
- **Persona:** Load from `.beads/skills/meld/agents/quick-flow-solo-dev.md`

## Context
- **Inputs:** Feature description, optional tech_spec_path variable
- **Outputs:** Baseline commit captured, execution mode determined, escalation evaluated
- **Dependencies:** None (first step)

## State Variables
These persist throughout the entire quick-dev workflow:
- `{baseline_commit}` — Git HEAD at start (for diff in adversarial review)
- `{execution_mode}` — "tech-spec" (Mode A) or "direct" (Mode B)
- `{tech_spec_path}` — Path to tech-spec file (Mode A only)

## Instructions

### 1. Capture Baseline Commit
```bash
git rev-parse HEAD
```
- Store result as `{baseline_commit}`
- If not in a git repo, set `{baseline_commit}` = "NO_GIT"

### 2. Load Project Context
- Read `project-context.md` if it exists
- Note project conventions, patterns, and constraints

### 3. Determine Execution Mode

**Mode A — Tech Spec (structured):**
- Triggers when `tech_spec_path` variable is provided
- Set `{execution_mode}` = "tech-spec"
- Load the tech-spec file, verify it has `status: 'ready-for-dev'`
- Extract tasks and acceptance criteria
- **Skip to step-03-execute** (context is already in the spec)

**Mode B — Direct Instructions (ad-hoc):**
- Triggers when no tech_spec_path is provided
- Set `{execution_mode}` = "direct"
- Parse user's feature description for scope and complexity
- Proceed to escalation evaluation

### 4. Escalation Evaluation (Mode B Only)
Count escalation signals:
- Multiple components or systems affected
- System-level language (architecture, infrastructure, migration)
- Uncertainty about the right approach
- Multi-layer scope (backend + frontend + database + tests)
- Extended timeframe or phased delivery needed

**No escalation (0–1 signals):**
- Present: `[P] Plan first (quick-spec)  [E] Execute directly`

**Moderate escalation (2 signals):**
- Present: `[P] Plan first (quick-spec)  [W] Full MELD flow  [E] Execute directly`
- Recommend: Plan first

**High escalation (3+ signals):**
- Present: `[W] Start full MELD flow  [P] Plan first (quick-spec)  [E] Execute directly (feeling lucky)`
- Recommend: Full MELD flow
- Warn about risks of direct execution

### 5. Handle Escalation Choice
- **[P]:** Suggest running `meld-quick-spec` first, then returning with the tech-spec
- **[W]:** Suggest starting with `meld-analysis` or `meld-solutioning`
- **[E]:** Proceed to step-02-context-gather

## Success Criteria
- Baseline commit is captured
- Execution mode is determined and confirmed
- For Mode B: escalation is evaluated and user has chosen approach
- For Mode A: tech-spec is loaded and validated

## Next Step
- **Mode A:** Skip to step-03-execute
- **Mode B:** Proceed to step-02-context-gather
