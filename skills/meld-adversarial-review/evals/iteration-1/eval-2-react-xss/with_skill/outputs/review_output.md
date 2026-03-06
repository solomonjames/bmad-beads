# Adversarial Review -- Dashboard Component

**Baseline commit:** def5678
**Diff source:** eval-files/diff-2-react-component.diff
**Review method:** Inline cold review (information asymmetry -- reviewer saw ONLY the diff, no spec or conversation context)

---

## Reviewer Findings (Raw)

F1 [Critical] -- XSS vulnerability via dangerouslySetInnerHTML
The component renders `event.description` using `dangerouslySetInnerHTML={{ __html: event.description }}` without any sanitization. If `event.description` contains user-supplied or API-sourced HTML, this is a direct cross-site scripting (XSS) vector. An attacker who can control event description content can execute arbitrary JavaScript in users' browsers.
Location: src/components/Dashboard.tsx:80

F2 [High] -- useEffect dependency array missing refreshInterval and userId
The `useEffect` depends on `selectedPeriod` but omits `refreshInterval` and `userId` (used inside `loadMetrics`). If `refreshInterval` or `userId` changes, the interval will not be reconfigured. Additionally, `loadMetrics` is defined outside the effect but closes over `userId` and `selectedPeriod`, creating a stale closure risk.
Location: src/components/Dashboard.tsx:23-27

F3 [High] -- No null/undefined guard on metrics properties before render
After loading, the code accesses `metrics.revenue`, `metrics.activeUsers`, `metrics.recentEvents.map(...)`, etc. without null-checking. State is `useState<any>(null)` and `loading` is set to false in the catch block, meaning `metrics` could still be null when rendering if error state is not set.
Location: src/components/Dashboard.tsx:56-83

F4 [High] -- Error state is never cleared on retry
When `loadMetrics` is called again (via interval or period change), `setError(null)` is never called at the start. Once an error occurs, the error view persists even if subsequent fetches succeed.
Location: src/components/Dashboard.tsx:29-38, 41

F5 [High] -- Tests do not cover error state, period selection, or XSS
Only two tests exist: loading state and rendered metrics. No tests for error handling, period selection, refresh interval, or the dangerouslySetInnerHTML usage.
Location: src/components/__tests__/Dashboard.test.tsx

F6 [Medium] -- Using `any` type for metrics state
`useState<any>(null)` discards all type safety. A proper interface should be defined matching the metrics shape.
Location: src/components/Dashboard.tsx:18

F7 [Medium] -- No cleanup of in-flight fetch on unmount or re-render
When the effect cleans up, only the interval is cleared. An in-flight `fetchMetrics` call will still complete and call state setters on an unmounted component.
Location: src/components/Dashboard.tsx:23-27, 29-38

F8 [Low] -- Revenue displayed without number formatting
`$${metrics.revenue}` renders as `$50000` instead of `$50,000`. Financial data should use locale-aware formatting.
Location: src/components/Dashboard.tsx:56

---

## Severity and Validity Assessment

| # | Severity | Validity | Rationale |
|---|----------|----------|-----------|
| F1 | Critical | **Real** | `dangerouslySetInnerHTML` with unsanitized API data is a textbook XSS vulnerability. This must be fixed before shipping. |
| F2 | High | **Real** | Missing deps in the useEffect array is a genuine React bug. The `refreshInterval` and `userId` props changing will not trigger effect re-runs, and the stale closure over `loadMetrics` is a real correctness issue. |
| F3 | High | **Real** | If the fetch errors without setting error state (or in a race), `metrics` remains null and the render will throw. The code path from error -> loading=false -> error=null (not set) -> metrics=null -> crash is possible. |
| F4 | High | **Real** | Error state is never reset. Once the component enters the error view, it stays there permanently even if the interval fetch later succeeds, because error state is checked first in the render. |
| F5 | High | **Real** | Two tests for a component with this many behaviors (error handling, polling, period switching, XSS-prone rendering) is clearly insufficient. |
| F6 | Medium | **Real** | Using `any` in TypeScript is a genuine code quality issue. The shape is known from usage and from the test mock. |
| F7 | Medium | **Real** | Setting state on unmounted components is a known React anti-pattern. Should use an AbortController or a mounted flag. |
| F8 | Low | **Real** | Minor UX issue. Not a bug but a polish item for financial display. |

**Summary:** 8 findings total. 0 noise -- all findings are genuine issues. 1 Critical (XSS), 4 High, 2 Medium, 1 Low.

---

## Final Findings List (Severity Order)

```
F1 [Critical/Real] -- XSS vulnerability: dangerouslySetInnerHTML renders unsanitized event.description
F2 [High/Real]     -- useEffect missing refreshInterval and userId in dependency array; stale closure risk
F3 [High/Real]     -- No null guard on metrics object; potential crash when metrics is null after error
F4 [High/Real]     -- Error state never cleared on retry; component stuck in error view after transient failure
F5 [High/Real]     -- Insufficient test coverage: no tests for error, period change, interval, or XSS vector
F6 [Medium/Real]   -- useState<any> discards TypeScript safety; metrics shape should be a typed interface
F7 [Medium/Real]   -- No AbortController or cleanup for in-flight fetch on unmount/re-render
F8 [Low/Real]      -- Revenue lacks locale-aware number formatting ($50000 vs $50,000)
```

---

## Resolution Options

- **[W] Walk through** -- Iterate each finding; decide Fix/Skip/Discuss for each
- **[F] Fix automatically** -- Apply fixes for all "Real" findings
- **[S] Skip** -- Acknowledge findings and proceed without fixes
