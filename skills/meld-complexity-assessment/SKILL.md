---
name: meld-complexity-assessment
description: Use when a user describes a feature or task to determine the right depth of planning — routes to direct execution, quick-spec, or full MELD flow based on complexity signals
---

# Complexity Assessment

Evaluate the complexity of a feature request and route to the appropriate depth of planning. This prevents over-engineering simple tasks and under-planning complex ones.

## Complexity Signals

Count how many of these signals are present:

- [ ] **Multi-component:** Multiple components or systems affected
- [ ] **System-level scope:** Architecture, infrastructure, or migration language
- [ ] **Uncertainty:** Unclear about the right approach or technology choice
- [ ] **Multi-layer:** Crosses backend + frontend + database + tests
- [ ] **Extended timeframe:** Phased delivery or extended implementation needed

## Routing

### 0–1 signals: Low complexity
Present options:
- **[E] Execute directly** (Recommended) — Jump straight to implementation
- **[P] Plan first** — Run `meld:meld-quick-spec` to create a tech spec

### 2 signals: Moderate complexity
Present options:
- **[P] Plan first** (Recommended) — Run `meld:meld-quick-spec` to create a tech spec
- **[E] Execute directly** — Proceed without a formal spec
- **[W] Full MELD flow** — Start with analysis and planning phases

### 3+ signals: High complexity
Present options:
- **[W] Full MELD flow** (Recommended) — Start with `meld-analysis` or `meld-solutioning`
- **[P] Plan first** — Run `meld:meld-quick-spec` (lighter weight but may miss things)
- **[E] Execute directly** — Proceed without planning (risky)

When recommending full MELD, warn about the risks of under-planning complex work.

## How to Present

1. Briefly list which signals you detected and why
2. State the complexity level (low / moderate / high)
3. Present the routing options with your recommendation
4. Let the user choose — never auto-select

## After Routing

- **[E]** → Invoke `meld:meld-quick-dev` directly
- **[P]** → Invoke `meld:meld-quick-spec`, then `meld:meld-quick-dev` with the resulting tech spec
- **[W]** → Guide user to the appropriate full MELD phase formula
