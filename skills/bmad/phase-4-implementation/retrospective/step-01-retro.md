# Step: Epic Retrospective

## Agent
- **Name:** All agents in "Party Mode" dialogue
- **Persona:** Load all relevant agent personas for multi-perspective discussion

## Context
- **Inputs:** Completed epic stories, sprint-status.yaml, previous retrospective (if exists)
- **Outputs:** Retrospective document with lessons, action items, next epic prep
- **Dependencies:** Epic must be complete (all stories done)

## Instructions

### Part 1: Epic Discovery and Analysis
1. Find completed epic (by priority or user selection)
2. Deep story analysis — extract from each completed story:
   - Dev notes and implementation struggles
   - Review feedback patterns
   - Lessons learned
   - Technical debt incurred
   - Testing insights
   - Velocity patterns
3. Load previous epic retrospective for continuity

### Part 2: Epic Review Discussion (Party Mode)
All agents dialogue using "Name (Role): statement" format:
1. What went well? What exceeded expectations?
2. What was harder than expected? Where did we struggle?
3. What should we change for next epic?
4. Technical debt to address?
5. Process improvements?

### Part 3: Next Epic Preparation
1. Preview next epic from epics document
2. Detect significant changes since planning:
   - Architectural assumptions proven wrong?
   - Major scope changes needed?
   - New dependencies discovered?
   - Performance/scalability concerns?
3. Identify preparation tasks for next epic

### Part 4: Synthesize and Close
1. Compile action items with owners and priorities
2. Identify critical path items for next epic
3. Save retrospective document
4. Update sprint-status.yaml
5. Celebrate accomplishments

### Output
- Retrospective document at `{{impl_artifacts}}/epic-{num}-retro.md`
- Action items with priorities
- Next epic preparation tasks
- Updated sprint-status.yaml

## Success Criteria
- All completed stories analyzed for lessons
- Multi-perspective review covers code, process, and product
- Action items are specific and actionable
- Next epic preparation identifies blockers early
- Sprint status updated

## Next Step
Begin next epic with create-story workflow, incorporating retrospective learnings.
