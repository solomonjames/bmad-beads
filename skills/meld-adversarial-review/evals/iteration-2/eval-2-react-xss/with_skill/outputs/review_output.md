# Adversarial Review Output

**Baseline commit:** def5678
**Review type:** Inline review (Agent tool unavailable -- no true information asymmetry)
**Diff:** `src/components/Dashboard.tsx` (new, 89 lines) + `src/components/__tests__/Dashboard.test.tsx` (new, 30 lines)

---

## Findings

F1 [Critical/Real] -- XSS vulnerability via dangerouslySetInnerHTML
`event.description` is rendered as raw HTML using `dangerouslySetInnerHTML={{ __html: event.description }}`. If `event.description` contains user-generated or external content, an attacker can inject arbitrary scripts. This is the single most dangerous pattern in React and should never be used without sanitization.
Location: src/components/Dashboard.tsx:80

F2 [High/Real] -- useEffect dependency array is missing `loadMetrics` and `refreshInterval`
The `useEffect` on line 23-27 depends on `loadMetrics` (which closes over `userId` and `selectedPeriod`) and `refreshInterval`, but the dependency array only contains `[selectedPeriod]`. When `userId` or `refreshInterval` changes, the effect will not re-run, leading to stale data fetches and stale intervals. Additionally, changing `selectedPeriod` creates a new interval without guaranteeing the old one is cleaned up before re-running, which can cause race conditions.
Location: src/components/Dashboard.tsx:23-27

F3 [High/Real] -- Error state is never cleared on successful retry
When `loadMetrics` fails, `error` is set to `'Failed to load metrics'`. On the next interval tick, if the fetch succeeds, `error` is never reset to `null`. Since the component returns early when `error` is truthy (line 41), the dashboard will remain stuck on the error screen even after data loads successfully.
Location: src/components/Dashboard.tsx:29-38

F4 [High/Real] -- Potential null dereference on `metrics` after period change
When `selectedPeriod` changes, the effect re-runs, but `loading` is not reset to `true` and `metrics` is not cleared. During the brief window between period change and data arrival, the old metrics remain displayed. More critically, if the new fetch fails, the user sees stale data from a different period with no indication it is outdated. If `metrics` were set to `null` on period change, the existing null guard would catch it, but currently it does not.
Location: src/components/Dashboard.tsx:23-27, 56-83

F5 [High/Real] -- No test coverage for error state
The test file only covers loading state and successful render. There is no test for the error path (`fetchMetrics` rejection), which is one of the three main render branches. This leaves a significant behavioral gap untested.
Location: src/components/__tests__/Dashboard.test.tsx

F6 [Medium/Real] -- `metrics` state typed as `any`
Using `useState<any>(null)` defeats TypeScript's type safety. All property accesses on `metrics` (`.revenue`, `.activeUsers`, `.revenueHistory`, `.recentEvents`, etc.) are unchecked. A typo or API shape change would not be caught at compile time. A proper interface should be defined and used.
Location: src/components/Dashboard.tsx:18

F7 [Medium/Real] -- State update on unmounted component
If the component unmounts while a `fetchMetrics` call is in-flight, the `.then`/`.catch` handlers will call `setMetrics`/`setError`/`setLoading` on an unmounted component. In React 17 and earlier, this produces a warning. An `AbortController` or mounted flag should be used to cancel or ignore stale requests on cleanup.
Location: src/components/Dashboard.tsx:29-38

F8 [Low/Real] -- Revenue displayed without number formatting
Revenue is interpolated as `$${metrics.revenue}`, which produces unformatted numbers like `$50000` instead of `$50,000`. Using `toLocaleString()` or a formatter would improve readability.
Location: src/components/Dashboard.tsx:56

F9 [Low/Real] -- No test for period selection behavior
The select dropdown for changing the time period is not tested. There is no verification that changing the period triggers a new data fetch or updates the UI accordingly.
Location: src/components/__tests__/Dashboard.test.tsx

---

## Summary Table

| Severity | Count | Real | Undecided | Noise |
|----------|-------|------|-----------|-------|
| Critical | 1 | 1 | 0 | 0 |
| High | 4 | 4 | 0 | 0 |
| Medium | 2 | 2 | 0 | 0 |
| Low | 2 | 2 | 0 | 0 |
| **Total** | **9** | **9** | **0** | **0** |

---

## Resolution Options

- **[W] Walk through** -- Iterate each finding, ask Fix/Skip/Discuss for each
- **[F] Fix automatically** -- Apply fixes for all "Real" findings (all 9 in this case)
- **[S] Skip** -- Acknowledge findings and proceed without fixes
