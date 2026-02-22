# Step: Quick Dev — Adversarial Review

## Agent
- **Name:** Barry (Quick Flow Solo Dev)
- **Persona:** Load from `.beads/skills/bmad/agents/quick-flow-solo-dev.md`

## Context
- **Inputs:** Implementation diff from baseline commit
- **Outputs:** Numbered findings with severity and validity ratings
- **Dependencies:** step-04-self-check complete

## Instructions

### 1. Construct Diff
Use the `{baseline_commit}` captured in step 1:

**Git available:**
```bash
git diff {baseline_commit}
```
- Include both tracked and untracked new files
- For new files: `git diff --no-index /dev/null {file}` or include full content

**NO_GIT fallback:**
- List all files modified/created during the workflow
- Include full content of changed files for review

### 2. Invoke Adversarial Review
Execute adversarial code review with **information asymmetry**:
- The review should see ONLY the diff — not the spec, not the conversation history
- This simulates a fresh reviewer who judges purely on code quality
- Use `bmad-review-adversarial-general` skill or equivalent task
- If subagent execution available, prefer separate context for true asymmetry
- Fallback: inline execution with instruction to ignore prior context

### 3. Process Findings
For each finding from the review:

**Evaluate severity:**
- **Critical:** Security vulnerability, data loss risk, crash
- **High:** Incorrect behavior, missing error handling, test gap
- **Medium:** Code smell, performance concern, maintainability issue
- **Low:** Style inconsistency, minor improvement opportunity

**Evaluate validity:**
- **Real:** Genuine issue that should be fixed
- **Noise:** False positive, reviewer lacks context
- **Undecided:** Could go either way, needs human judgment

**Number and present:**
```
F1 [Critical/Real] — Description of finding
F2 [High/Undecided] — Description of finding
F3 [Medium/Noise] — Description of finding
```

### 4. Zero Findings Check
If the review produces zero findings:
- This is suspicious — flag it
- Consider: was the diff too small? Was the review thorough?
- Note the anomaly but proceed

## Success Criteria
- Diff is constructed from baseline (not guessed)
- Review is adversarial with information asymmetry
- Findings are numbered, severity-rated, and validity-assessed
- Findings are ordered by severity (critical first)

## Next Step
Proceed to step-06-resolve-findings (Resolution).
