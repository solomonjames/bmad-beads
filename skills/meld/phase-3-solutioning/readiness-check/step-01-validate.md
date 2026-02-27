# Step: Implementation Readiness Validation

## Agent
- **Name:** Winston (Architect) — adversarial reviewer
- **Persona:** Load from `.beads/skills/meld/agents/architect.md`

## Context
- **Inputs:** PRD, Architecture, Epics & Stories, UX spec (if exists)
- **Outputs:** Readiness assessment report
- **Dependencies:** Epics and stories must be complete

## Instructions

### Part 1: Document Discovery
1. Find all project documents: PRD, Architecture, Epics, UX
2. Resolve any duplicates (whole vs. sharded versions)
3. Initialize readiness report from template

### Part 2: PRD Analysis
1. Load complete PRD
2. Extract ALL Functional Requirements with numbering (FR1, FR2, etc.)
3. Extract ALL Non-Functional Requirements
4. Document complete requirement lists

### Part 3: Epic Coverage Validation
1. Load epics and stories document
2. Create coverage matrix: each FR, its text, epic coverage, status
3. Identify ALL missing FRs (not covered in any story)
4. Calculate coverage percentage
5. Flag critical gaps

### Part 4: UX Alignment
1. If UX exists: validate UX <-> PRD alignment and UX <-> Architecture alignment
2. If no UX: assess if UX/UI is implied but missing (user-facing app?)
3. Issue warnings for implied but missing UX documentation

### Part 5: Epic Quality Review
1. **Epic Structure:** User value focus (flag "Setup Database" anti-patterns)
2. **Epic Independence:** Epic N can't require Epic N+1
3. **Story Quality:** Sized for single dev, clear ACs, Given/When/Then format
4. **Dependencies:** No forward dependencies within or across epics
5. **Database/Entity:** Created only when needed (not upfront)
6. **Starter Template:** If specified, Epic 1 Story 1 must be project setup
7. Severity assessment: Critical Violations, Major Issues, Minor Concerns

### Part 6: Final Assessment
1. Compile comprehensive findings
2. List critical issues requiring immediate action
3. Determine readiness status: **READY** / **NEEDS WORK** / **NOT READY**
4. Provide specific, actionable recommendations

### Output
- Readiness report with coverage matrix, quality assessment, final status
- Specific action items for any issues found

## Success Criteria
- All FRs validated against epic coverage
- Quality review identifies violations at appropriate severity
- Clear readiness status with actionable next steps
- Report is self-contained and shareable

## Next Step
This is a human review gate. If READY, proceed to `meld-implementation`. If not, address findings first.
