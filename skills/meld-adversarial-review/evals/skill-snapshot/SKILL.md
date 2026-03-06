---
name: meld-adversarial-review
description: Use when implementation is complete and you need a code review with information asymmetry — reviewer sees ONLY the diff, not the spec or conversation history
---

# Adversarial Review

This skill performs a code review with **information asymmetry**: the reviewer sees ONLY the diff, not the spec, conversation history, or implementation intent. This simulates a fresh reviewer who judges purely on code quality.

## Prerequisites

- A baseline commit (captured before implementation started)
- Implementation is complete and self-check has passed

## Procedure

### 1. Construct the Diff

**Git available:**
```bash
git diff {baseline_commit}
```
- Include both tracked and untracked new files
- For new files: `git diff --no-index /dev/null {file}` or include full content

**No git fallback:**
- List all files modified/created during the workflow
- Include full content of changed files for review

### 2. Invoke the Reviewer

**REQUIRED:** Use a subagent (Task tool) for true information asymmetry.

The subagent receives ONLY:
- The diff content
- The reviewer prompt (from `reviewer-prompt.md` in this skill directory)
- NO spec, NO conversation history, NO implementation context

If subagent execution is not available, fall back to inline execution with explicit instruction to ignore all prior context.

### 3. Process Findings

For each finding from the review, evaluate:

**Severity:**
- **Critical:** Security vulnerability, data loss risk, crash
- **High:** Incorrect behavior, missing error handling, test gap
- **Medium:** Code smell, performance concern, maintainability issue
- **Low:** Style inconsistency, minor improvement opportunity

**Validity:**
- **Real:** Genuine issue that should be fixed
- **Noise:** False positive, reviewer lacks context
- **Undecided:** Could go either way, needs human judgment

### 4. Present Findings

Number and present in severity order:
```
F1 [Critical/Real] — Description of finding
F2 [High/Undecided] — Description of finding
F3 [Medium/Noise] — Description of finding
```

### 5. Zero Findings Check

If the review produces zero findings:
- Flag this as suspicious
- Consider: was the diff too small? Was the review thorough?
- Note the anomaly but proceed

## Resolution

Present resolution options to the user:
- **[W] Walk through** — Iterate each finding, ask Fix/Skip/Discuss for each
- **[F] Fix automatically** — Apply fixes for "Real" findings, skip Noise/Undecided
- **[S] Skip** — Acknowledge findings and proceed without fixes
