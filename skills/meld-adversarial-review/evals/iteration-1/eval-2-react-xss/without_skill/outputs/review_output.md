# Adversarial Code Review: Dashboard Component

**Baseline commit:** def5678
**Files reviewed:** `src/components/Dashboard.tsx`, `src/components/__tests__/Dashboard.test.tsx`

---

## CRITICAL

### 1. XSS Vulnerability via `dangerouslySetInnerHTML`

**File:** `src/components/Dashboard.tsx`, line 80
```tsx
<span dangerouslySetInnerHTML={{ __html: event.description }} />
```

This renders `event.description` as raw HTML directly into the DOM. If any event description contains user-supplied or third-party content, an attacker can inject arbitrary scripts (e.g., `<img src=x onerror="steal(document.cookie)">`). This is a textbook cross-site scripting (XSS) vulnerability.

**Recommendation:** Remove `dangerouslySetInnerHTML` entirely and render the description as text content. If rich formatting is genuinely required, sanitize with a library like DOMPurify before rendering:
```tsx
<span>{event.description}</span>
```

---

## HIGH

### 2. Missing `loadMetrics` and `refreshInterval` in useEffect dependency array

**File:** `src/components/Dashboard.tsx`, line 27
```tsx
useEffect(() => {
    loadMetrics();
    const interval = setInterval(loadMetrics, refreshInterval);
    return () => clearInterval(interval);
}, [selectedPeriod]);
```

- `loadMetrics` is defined inside the component and closes over `userId` and `selectedPeriod`, but it is not listed as a dependency. This will trigger an ESLint `react-hooks/exhaustive-deps` warning and can cause stale closure bugs -- if `userId` changes, the effect will continue fetching with the old value.
- `refreshInterval` is also missing. If the prop changes, the interval keeps the old cadence.

**Recommendation:** Either add the missing dependencies, or wrap `loadMetrics` in `useCallback` with its own dependencies and include it plus `refreshInterval` in the effect's dependency array.

### 3. No null-safety on `metrics` access

**File:** `src/components/Dashboard.tsx`, lines 56-83

After loading, `metrics` is accessed directly (`metrics.revenue`, `metrics.recentEvents.map(...)`, etc.). If `fetchMetrics` returns a response missing any of these properties, the component will throw at runtime.

Additionally, `metrics` is typed as `any`, providing zero compile-time safety.

**Recommendation:** Define a proper `Metrics` interface and validate or default each property before rendering.

---

## MEDIUM

### 4. Error state is never cleared

**File:** `src/components/Dashboard.tsx`, lines 29-37

When `loadMetrics` succeeds, `error` is never reset to `null`. If a transient failure occurs and the next auto-refresh succeeds, the user will remain stuck on the error screen because the early return on line 41 (`if (error) return ...`) fires first.

**Recommendation:** Add `setError(null)` at the start of the `try` block or before the `fetchMetrics` call.

### 5. Loading state not reset on period change

When `selectedPeriod` changes, the effect re-runs but `loading` is not set back to `true`. The user sees stale data from the previous period until the new fetch completes. There is no visual indication that a refresh is in progress.

**Recommendation:** Set `setLoading(true)` at the top of `loadMetrics`.

### 6. Revenue value not formatted

**File:** `src/components/Dashboard.tsx`, line 56
```tsx
<MetricCard title="Revenue" value={`$${metrics.revenue}`} />
```

A revenue value of 50000 renders as `$50000` with no thousands separator. For a dashboard, this is a usability issue.

**Recommendation:** Use `Intl.NumberFormat` or `toLocaleString()` for currency formatting.

---

## LOW

### 7. Sparse test coverage

The test file has only two tests: loading state and one metric rendering. There is no coverage for:
- Error state rendering
- Period selection behavior
- The auto-refresh interval lifecycle (setup and teardown)
- The `dangerouslySetInnerHTML` rendering path (the XSS surface is completely untested)
- Passing different `refreshInterval` or `userId` props

### 8. `event` list item missing type annotation

**File:** `src/components/Dashboard.tsx`, line 78
```tsx
{metrics.recentEvents.map((event) => (
```

`event` is implicitly `any` because `metrics` is typed as `any`. This hides potential property access errors.

---

## Summary

The most urgent issue is the **XSS vulnerability** on line 80 via `dangerouslySetInnerHTML`. This must be fixed before merge. The stale-closure bugs in the `useEffect` dependency array and the lack of null-safety on the `metrics` object are also high-priority. The remaining items around error/loading state management and test coverage should be addressed but are lower risk.

**Verdict: Request changes.** The XSS vulnerability alone blocks this PR.
