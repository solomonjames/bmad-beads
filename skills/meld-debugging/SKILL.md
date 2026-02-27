---
name: meld-debugging
description: Systematic debugging — 4-phase root cause methodology with mandatory investigation before any fix. Referenced by quick-dev halt conditions.
---

# Systematic Debugging

## The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

Found a bug? Your first instinct is wrong. Don't fix it. Don't even theorize. **Investigate first.**

- Don't change code "to see what happens"
- Don't add logging "just in case"
- Don't guess at the cause based on the symptom
- Don't copy a fix from StackOverflow without understanding why it works

## The 4 Phases

Every debugging session follows these phases in order. No skipping.

---

### Phase 1: Root Cause Investigation

**Goal:** Understand what's actually happening before changing anything.

#### Reproduce the Bug
1. Find the exact steps to trigger the failure
2. Confirm it fails consistently (or document the intermittent pattern)
3. Write down the expected vs. actual behavior

#### Trace Backward from the Symptom
Use the root cause tracing technique from `root-cause-tracing.md` in this skill directory.

The process:
1. **Start at the symptom** — the error message, wrong output, or crash
2. **Identify the immediate cause** — what line of code produces the wrong result?
3. **Trace up** — what called that code? What data did it pass? Where did that data come from?
4. **Find the source** — keep tracing until you find where correct data becomes incorrect

#### Gather Evidence
- Read error messages completely (not just the first line)
- Check stack traces from bottom to top
- Read log output around the failure
- Check recent changes (`git log`, `git diff`)
- Verify assumptions about inputs and state

#### Document What You Find
Before moving on:
- What is the root cause? (Not the symptom — the cause)
- What evidence supports this conclusion?
- Are there other possible explanations?

---

### Phase 2: Pattern Analysis

**Goal:** Determine if this is an isolated bug or a systemic pattern.

#### Check for Related Issues
- Is the same mistake made elsewhere in the codebase?
- Is there a pattern of similar bugs? (e.g., all date handling is broken)
- Are other callers of the broken code affected?

#### Assess the Blast Radius
- What else depends on the broken code?
- Could fixing it break something else?
- Are there tests that should have caught this?

#### Identify Missing Defenses
Use the defense-in-depth patterns from `defense-in-depth.md` in this skill directory.

Which validation layer is missing?
- Entry point validation?
- Business logic validation?
- Environment guards?
- Debug instrumentation?

---

### Phase 3: Hypothesis Testing

**Goal:** Verify your root cause analysis before implementing a fix.

#### Form a Hypothesis
Based on Phase 1 and 2:
- "The bug occurs because {root cause}"
- "Fixing {specific thing} will resolve the symptom"
- "The fix won't break {related functionality} because {reason}"

#### Test the Hypothesis
- Can you predict the behavior with a specific input?
- Does the hypothesis explain ALL observed symptoms?
- Can you rule out alternative explanations?

#### Write a Failing Test
Before writing any fix:
1. Write a test that reproduces the bug (follows `meld:meld-tdd` Red phase)
2. Run it — confirm it fails
3. Confirm it fails for the reason you expect (not a different reason)

This test serves as both proof of the bug and regression prevention.

---

### Phase 4: Implementation

**Goal:** Fix the root cause with minimal, verified changes.

#### Apply the Fix
- Fix the root cause, not the symptom
- Keep the change as small as possible
- Follow existing code patterns

#### Verify with TDD
Follow `meld:meld-tdd` for the fix:
1. Your failing test from Phase 3 should now pass
2. All existing tests should still pass
3. If the fix is complex, add additional tests

#### Run Full Verification
Use `meld:meld-verification` gate function:
1. Run all tests (not just the one you wrote)
2. Run build and lint
3. Read complete output
4. Match evidence to claims

#### Check for Timing Issues
If the bug involved async operations, race conditions, or timing:
- Use the condition-based waiting patterns from `condition-based-waiting.md` in this skill directory
- Replace any arbitrary sleeps/timeouts with condition polling
- Verify the fix handles both fast and slow execution paths

---

## Red Flags — You're Doing It Wrong

| Red Flag | What You Should Do Instead |
|----------|--------------------------|
| Changing code before understanding the bug | Stop. Read. Trace. Then fix. |
| "Let me try this and see" | Form a hypothesis first. Predict the outcome. |
| Adding broad try/catch to suppress errors | Find why the error occurs. Fix the cause. |
| "It works on my machine" | Reproduce in the failing environment. |
| Fixing the symptom, not the cause | Trace backward to the root cause. |
| Multiple changes at once | One change at a time. Verify each. |

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "I know what's wrong" | Then prove it. Write a failing test for your theory. |
| "The fix is obvious" | Obvious fixes for wrong root causes create new bugs. |
| "No time to investigate" | You'll spend more time debugging the wrong fix. |
| "Just add a null check" | Why is it null? Fix that. |
| "It's a timing issue, just add a delay" | Delays mask bugs. Use condition-based waiting. |
| "The third-party library is broken" | Verify. Most "library bugs" are usage bugs. |

## Debugging Checklist

Before claiming a bug is fixed:

- [ ] Reproduced the bug consistently
- [ ] Traced backward from symptom to root cause
- [ ] Documented the root cause (not just the symptom)
- [ ] Checked for the same pattern elsewhere
- [ ] Wrote a failing test that reproduces the bug
- [ ] Watched the test fail for the expected reason
- [ ] Applied a minimal fix targeting the root cause
- [ ] Watched the test pass
- [ ] All other tests still pass
- [ ] Build and lint clean

## When Halted by Quick-Dev

When `meld:meld-quick-dev` Phase 3 hits a halt condition (3 consecutive failures, tests failing with no obvious fix), this skill activates:

1. **Stop guessing.** Don't try another variation of the same fix.
2. **Start Phase 1.** Reproduce the failure. Trace backward. Gather evidence.
3. **Follow all 4 phases.** No shortcuts because you're in a hurry.
4. **Return to quick-dev** once the fix is verified and all tests pass.

The halt condition exists specifically to force you into systematic debugging. Respect it.
