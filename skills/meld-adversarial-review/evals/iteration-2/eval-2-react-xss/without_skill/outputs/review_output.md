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

This renders `event.description` as raw HTML. If the API returns user-supplied or unsanitized content in `event.description`, an attacker can inject arbitrary scripts (stored XSS). This is the most severe issue in the diff.

**Recommendation:** Remove `dangerouslySetInnerHTML` entirely and render the description as text:
```tsx
<span>{event.description}</span>
```
If HTML rendering is genuinely required, sanitize with a library like DOMPurify before injection.

---

## HIGH

### 2. Stale closure over `loadMetrics` in `useEffect`

**File:** `src/components/Dashboard.tsx`, lines 23-27
```tsx
useEffect(() => {
    loadMetrics();
    const interval = setInterval(loadMetrics, refreshInterval);
    return () => clearInterval(interval);
}, [selectedPeriod]);
```

- `loadMetrics` is defined after the `useEffect` call and closes over `userId` and `selectedPeriod`. However, `userId` and `refreshInterval` are not in the dependency array. If `userId` or `refreshInterval` change after mount, the interval will continue calling with stale values.
- The React exhaustive-deps lint rule would flag this. `loadMetrics` should be wrapped in `useCallback` with proper dependencies, or the effect should include `userId`, `refreshInterval`, and `loadMetrics` in the dependency array.

**Recommendation:** Use `useCallback` for `loadMetrics` and list it (or its dependencies) in the `useEffect` dependency array:
```tsx
const loadMetrics = useCallback(async () => { ... }, [userId, selectedPeriod]);

useEffect(() => {
    loadMetrics();
    const interval = setInterval(loadMetrics, refreshInterval);
    return () => clearInterval(interval);
}, [loadMetrics, refreshInterval]);
```

### 3. No null/undefined guard on `metrics` properties before render

**File:** `src/components/Dashboard.tsx`, lines 56-83

After the loading/error early returns, the component accesses `metrics.revenue`, `metrics.recentEvents.map(...)`, etc. with no null-safety checks. If the API returns a partial object (missing `recentEvents`, for example), this will throw at runtime. The `useState<any>(null)` typing makes this invisible to TypeScript.

**Recommendation:** Define a proper TypeScript interface for the metrics shape and validate or provide defaults before rendering.

---

## MEDIUM

### 4. `useState<any>` loses type safety

**File:** `src/components/Dashboard.tsx`, line 18
```tsx
const [metrics, setMetrics] = useState<any>(null);
```

Using `any` defeats TypeScript's purpose. A `Metrics` interface should be defined and used here, which would also surface the null-guard issues mentioned above at compile time.

### 5. Error state is not recoverable

When an error occurs, `loading` is set to `false` and `error` is set to a message. However, there is no retry mechanism or way for the user to recover. Changing the period selector will trigger a new fetch (via the `useEffect` dependency), but if the user does not change the period, they are stuck on the error screen while the interval continues silently failing in the background. The interval also keeps running after an error, which may be undesirable.

### 6. Revenue displayed without formatting

**File:** `src/components/Dashboard.tsx`, line 56
```tsx
<MetricCard title="Revenue" value={`$${metrics.revenue}`} />
```

A revenue of 50000 renders as `$50000` rather than `$50,000`. Use `toLocaleString()` or a number formatting library for display currency values.

---

## LOW

### 7. Test coverage is minimal

The test file only covers two cases: initial loading state and a single metric rendering after load. There are no tests for:
- Error state rendering
- Period selector changes triggering a re-fetch
- The `dangerouslySetInnerHTML` behavior / recent events rendering
- Interval setup and cleanup
- Props changes (different `userId`, custom `refreshInterval`)

### 8. Missing `key` type safety on `event`

**File:** `src/components/Dashboard.tsx`, line 78
```tsx
{metrics.recentEvents.map((event) => (
```

`event` is implicitly `any` because `metrics` is `any`. This should be typed via the metrics interface.

---

## Summary

| Severity | Count | Key Concern |
|----------|-------|-------------|
| Critical | 1     | XSS via `dangerouslySetInnerHTML` |
| High     | 2     | Stale closures in useEffect; no null guards on API data |
| Medium   | 3     | Loss of type safety; non-recoverable errors; no number formatting |
| Low      | 2     | Thin test coverage; untyped event iteration |

The critical XSS vulnerability must be resolved before merge. The high-severity hook and null-safety issues should also be addressed as they will cause runtime failures under realistic conditions.
