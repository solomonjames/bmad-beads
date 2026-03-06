# Adversarial Review — TTL Cache Implementation

**Baseline commit:** ghi9012
**Review type:** Inline fallback (Agent tool unavailable — no true information asymmetry)
**Diff size:** ~97 lines (2 new files)

---

## Findings

F1 [High/Real] — Tests use real time.sleep, making them slow and fragile
Tests call `time.sleep(1.1)` to verify TTL expiration. This adds over 2 seconds of wall-clock time to the test suite and introduces flakiness on slow CI runners where timing may drift. The `unittest.mock.patch` import is already present but unused — `time.time` should be mocked instead of relying on real sleep.
Location: tests/test_cache.py:12,17

F2 [High/Real] — Unused import: `patch` from `unittest.mock`
The test file imports `from unittest.mock import patch` on line 2 but never uses it. This suggests the developer intended to mock time but forgot, or left dead code behind. Combined with F1, this indicates an incomplete approach to time-based testing.
Location: tests/test_cache.py:2

F3 [High/Real] — No thread-safety test despite "thread-safe" claim
The class docstring claims "A simple thread-safe TTL cache" and uses a threading lock, but there are zero concurrent tests. Thread-safety claims without concurrent tests are unverifiable. At minimum, a test should exercise concurrent get/set from multiple threads to confirm no data corruption.
Location: tests/test_cache.py (missing test)

F4 [Medium/Real] — `_evict_expired` is not safe to call outside a locked context
The method `_evict_expired` reads and mutates `self._store` without acquiring `self._lock`. It is currently only called from within `set` (which holds the lock), but nothing prevents external or future internal callers from invoking it without the lock, creating a race condition. The method should either acquire the lock or be documented/enforced as lock-required.
Location: lib/cache.py:39-43

F5 [Medium/Undecided] — `get` cannot distinguish missing key from expired key from stored None
Both a missing key and an expired key return `None`. If a caller stores `None` as a value, `get` returns `None` which is indistinguishable from a cache miss. Whether this matters depends on use case, but it limits the API's expressiveness. A sentinel value or a `(found, value)` tuple return could resolve this.
Location: lib/cache.py:16-22

F6 [Medium/Undecided] — Eviction strategy uses O(n) scan to find oldest entry
When the cache is full and no expired entries exist, `min(self._store, key=lambda k: self._store[k][1])` scans the entire store. For `max_size=1000` (the default), this is acceptable, but it scales poorly if max_size grows. A heap or ordered structure would provide O(log n) eviction.
Location: lib/cache.py:29

F7 [Low/Noise] — No `__len__` or `__contains__` dunder methods
The cache has no way to check its size or test membership without calling `get` (which has side effects — it deletes expired keys). This limits usability but may be intentional for a minimal API.
Location: lib/cache.py (class-level)

---

## Summary Table

| Severity | Count | Real | Undecided | Noise |
|----------|-------|------|-----------|-------|
| Critical | 0 | 0 | 0 | 0 |
| High | 3 | 3 | 0 | 0 |
| Medium | 3 | 1 | 2 | 0 |
| Low | 1 | 0 | 0 | 1 |
| **Total** | **7** | **4** | **2** | **1** |

---

## Resolution Options

- **[W] Walk through** — Iterate each finding; choose Fix / Skip / Discuss for each
- **[F] Fix automatically** — Apply fixes for the 4 "Real" findings (F1-F4), skip Noise/Undecided
- **[S] Skip** — Acknowledge findings and proceed without fixes
