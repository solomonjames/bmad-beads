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

**Large diffs (>500 lines):** If the diff is very large, note this when passing it to the reviewer. The reviewer should prioritize security and correctness findings over style issues.

### 2. Invoke the Reviewer

**REQUIRED:** Use the Agent tool to spawn a subagent for true information asymmetry. The subagent must receive ONLY the diff and the reviewer prompt — no spec, no conversation history, no implementation context.

Read the reviewer prompt from `reviewer-prompt.md` in this skill directory, then construct the subagent call like this:

```
Agent tool call:
  prompt: "<contents of reviewer-prompt.md>\n\n<diff>\n<paste the full diff content here>\n</diff>"
  subagent_type: "general-purpose"
  description: "Adversarial code review"
```

The key constraint: the subagent's prompt must contain ONLY the reviewer instructions and the diff. Nothing else. This is what creates the information asymmetry — the reviewer cannot be biased by knowing what the code is supposed to do.

**Fallback (only if Agent tool is genuinely unavailable):** Perform the review inline. Before reviewing, explicitly discard all prior context. Start fresh: read only the diff, apply only the reviewer prompt criteria. State clearly in your output that this is an inline review without true information asymmetry.

### 3. Process Findings

For each finding from the reviewer, evaluate two dimensions:

**Severity** (how bad is it?):
- **Critical:** Security vulnerability, data loss risk, crash
- **High:** Incorrect behavior, missing error handling, test gap
- **Medium:** Code smell, performance concern, maintainability issue
- **Low:** Style inconsistency, minor improvement opportunity

**Validity** (is the reviewer right, given that they lack context?):
- **Real:** Genuine issue that should be fixed
- **Noise:** False positive — the reviewer lacks context that makes this a non-issue
- **Undecided:** Could go either way, needs human judgment

### 4. Present Findings

Format findings with a numbered ID, severity, validity, and location:

```
F1 [Critical/Real] — Description of finding
   Explanation of why this matters.
   Location: file:line

F2 [High/Undecided] — Description of finding
   Explanation of why this matters.
   Location: file:line
```

Order by severity (Critical first, Low last). Within the same severity, list Real before Undecided before Noise.

After the findings list, include a **summary table**:

| Severity | Count | Real | Undecided | Noise |
|----------|-------|------|-----------|-------|
| Critical | N | N | N | N |
| High | N | N | N | N |
| Medium | N | N | N | N |
| Low | N | N | N | N |
| **Total** | **N** | **N** | **N** | **N** |

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
