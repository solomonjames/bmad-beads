# Step: Initialize Brief and Discover Vision

## Agent
- **Name:** Mary (Analyst)
- **Persona:** Load from `.beads/skills/meld/agents/analyst.md`

## Context
- **Inputs:** Project name, any existing brainstorming/research docs, project context files
- **Outputs:** Product brief document initialized, Executive Summary and Core Vision sections drafted
- **Dependencies:** None (first step)

## Instructions

### Part 1: Initialization
1. Search for input documents: brainstorming notes, research files, project context docs
2. Check for sharded folders (directories with `index.md`)
3. Load ALL discovered files completely
4. Confirm findings with user before proceeding
5. Create initial document from template at `{{planning_artifacts}}/product-brief-{{project_name}}.md`
6. Track discovered documents in the brief

### Part 2: Vision Discovery
1. Open collaborative conversation about the core problem:
   - What problem are you solving?
   - Who experiences this problem?
   - What does success look like?
   - What excites you about this?
2. Explore problem from multiple angles: current solutions, frustrations, consequences, who feels pain most
3. Analyze current solutions: what exists, where they fall short, what gaps remain
4. Collaboratively craft solution vision: perfect solution, simplest approach, differentiators
5. Identify unique differentiators: unfair advantages, competitive moat, unique insights, timing

### Output Sections
Generate and append to document:
- **Executive Summary** — Compelling overview capturing product essence
- **Core Vision** — Problem Statement, Impact, Why Existing Solutions Fall Short, Proposed Solution, Key Differentiators

## Success Criteria
- Clear, compelling problem statement that resonates
- Well-articulated solution vision addressing core problem
- Distinct unique differentiators providing competitive advantage
- Executive summary capturing product essence
- All input documents discovered and loaded

## Next Step
Proceed to step-02 (Users and Metrics) after vision content is approved.
