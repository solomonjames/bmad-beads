# Step: Quick Spec — Review and Finalize

## Agent
- **Name:** Barry (Quick Flow Solo Dev)
- **Persona:** Load from `.beads/skills/meld/agents/quick-flow-solo-dev.md`

## Context
- **Inputs:** Complete tech-spec in review status
- **Outputs:** Finalized tech-spec with ready-for-dev status
- **Dependencies:** step-03-generate complete
- **Type:** Human review gate

## Instructions

### 1. Present Complete Spec
Read `{{impl_artifacts}}/tech-spec-wip.md`, extract the slug, and present a summary:
- **Title** and problem statement
- **Task count** and dependency chain overview
- **AC count** and coverage summary
- **Files to modify/create** count
- Full spec available for review

### 2. Review Menu
Present options to the user:
- **[C] Continue** — Approve spec as ready-for-dev
- **[E] Edit** — Make specific changes (user describes what to change)
- **[Q] Questions** — Answer questions about the spec
- **[R] Adversarial Review** — Invoke adversarial review for quality check

### 3. Handle Review Feedback

**Edit mode:**
- Apply requested changes to the spec
- Re-verify ready-for-dev standard after changes
- Return to review menu

**Questions mode:**
- Answer questions about decisions, approach, or scope
- Update spec if answers reveal gaps
- Return to review menu

**Adversarial Review:**
- Invoke adversarial review (use `meld-review-adversarial-general` skill) against the spec content
- Present findings with severity ratings
- User decides which findings to address
- Apply fixes, return to review menu

### 4. Finalize
When user approves (selects Continue):
1. Update frontmatter:
   - `status: 'ready-for-dev'`
   - `stepsCompleted: [1, 2, 3, 4]`
2. Rename file: `tech-spec-wip.md` → `tech-spec-{slug}.md`
3. Confirm final path to user
4. Suggest next step: "Spec is ready. You can start development with `meld-quick-dev` using this spec."

## Success Criteria
- User has reviewed and approved the spec
- All requested edits have been applied
- Spec meets ready-for-dev standard
- File renamed from WIP to final format
- User knows how to proceed to development

## Next Step
This is the final quick-spec step. The output tech-spec can be consumed by `meld-quick-dev` (Mode A) or used as a reference for manual implementation.
