# Step: Component Strategy, Patterns, and UX Completion

## Agent
- **Name:** Sally (UX Designer)
- **Persona:** Load from `.beads/skills/meld/agents/ux-designer.md`

## Context
- **Inputs:** UX Design Specification with foundation and visual direction
- **Outputs:** Complete UX Design Specification with components, patterns, responsive strategy
- **Dependencies:** step-01 (design-and-foundation)

## Instructions

### Part 1: Component Strategy (MELD Step 11)
1. Analyze design system coverage vs. product needs (gap analysis)
2. Design custom components systematically:
   - Purpose, content/data, user actions, states, variants, accessibility
3. Document component specifications: purpose, anatomy, states, variants, ARIA/keyboard, content guidelines
4. Plan implementation roadmap:
   - Phase 1: Core components for critical flows
   - Phase 2: Supporting components
   - Phase 3: Enhancement components

### Part 2: UX Consistency Patterns (MELD Step 12)
1. Define critical pattern categories:
   - Button hierarchy, feedback patterns, form patterns, navigation patterns
   - Modal/overlay patterns, empty/loading states, search/filtering
2. For each pattern: when to use, visual design, behavior, accessibility, mobile considerations
3. Ensure design system integration rules

### Part 3: Responsive Design and Accessibility (MELD Step 13)
1. Define responsive strategy per breakpoint:
   - Mobile (320-767px): bottom nav, collapsed layouts, critical info first
   - Tablet (768-1023px): touch-optimized, simplified layouts
   - Desktop (1024px+): multi-column, side navigation, content density
2. Choose WCAG compliance level (typically AA)
3. Accessibility requirements: contrast, keyboard nav, screen reader, touch targets (44x44px min)
4. Plan testing strategy: responsive + accessibility + user testing

### Part 4: Completion and Review
1. Summarize all 14 sections of UX Design Specification
2. Validate completeness and consistency
3. Suggest next steps: wireframes, prototypes, architecture, epic creation

### Output Sections
Append to UX Design Specification:
- **Component Strategy** — System coverage, custom components, implementation roadmap
- **UX Patterns** — Consistency patterns by category
- **Responsive Strategy** — Breakpoint definitions and layout rules
- **Accessibility Strategy** — WCAG level, requirements, testing plan

## Success Criteria
- Component strategy covers all critical user flows
- Patterns ensure visual and interaction consistency
- Responsive strategy addresses all target devices
- Accessibility meets chosen WCAG level
- Complete specification ready for architecture and development

## Next Step
This is the final UX step. Recommended: `meld-solutioning` (Architecture + Epics).
