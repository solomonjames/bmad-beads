# Adversarial Code Review: TTL Cache Implementation

**Baseline commit:** ghi9012
**Files reviewed:** `lib/cache.py`, `tests/test_cache.py`

---

## Summary

A thread-safe TTL (time-to-live) cache implementation with basic CRUD operations, expiry-based eviction, and max-size enforcement. The code is clean, well-typed, and concise. The test suite covers the core paths. Several issues warrant attention before merging.

---

## Critical Issues

### 1. `_evict_expired` is not thread-safe when called standalone

`_evict_expired()` does not acquire `self._lock`. It is currently only called from within `set()`, which already holds the lock, so this is safe today. However, nothing prevents a future caller (or subclass) from invoking `_evict_expired()` outside the lock, which would cause a race condition on `self._store`.

**Recommendation:** Either (a) make `_evict_expired` acquire the lock itself (and use a reentrant lock `threading.RLock()` so `set()` can still call it while holding the lock), or (b) add a clear docstring/comment stating this method must only be called while holding `self._lock`.

### 2. Eviction under max_size uses `min()` over the entire store -- O(n)

When the cache is full and no expired entries exist, the eviction strategy finds the entry with the earliest expiry using `min(self._store, key=lambda k: self._store[k][1])`. This is O(n) per insertion when the cache is at capacity. For `max_size=1000` (the default), this is likely acceptable, but it degrades for larger caches.

**Recommendation:** If larger cache sizes are expected, consider a secondary data structure (e.g., a heap or ordered dict sorted by expiry) to make eviction O(log n). At minimum, document the O(n) eviction cost.

---

## Moderate Issues

### 3. `time.sleep()` in tests makes the suite slow and flaky

`test_expired_key_returns_none` and `test_custom_ttl` both call `time.sleep(1.1)`. This adds at least 2.2 seconds to the test suite and is inherently flaky -- under heavy system load, timing may not behave as expected. The test file already imports `unittest.mock.patch` but never uses it.

**Recommendation:** Mock `time.time` to control expiry deterministically:

```python
def test_expired_key_returns_none(self):
    cache = TTLCache(default_ttl=10)
    with patch("lib.cache.time.time", return_value=1000.0):
        cache.set("key1", "value1")
    with patch("lib.cache.time.time", return_value=1011.0):
        assert cache.get("key1") is None
```

### 4. `get()` returns `None` for both missing keys and expired keys

There is no way for the caller to distinguish between "key was never set" and "key existed but expired." This can mask bugs in consumer code that needs to differentiate these states.

**Recommendation:** Consider raising `KeyError` for missing keys (consistent with dict semantics), or providing a sentinel/default parameter:

```python
_MISSING = object()

def get(self, key: str, default: Any = _MISSING) -> Any:
    ...
    if default is _MISSING:
        raise KeyError(key)
    return default
```

Alternatively, add a `has()` or `__contains__` method so callers can check existence before retrieval.

### 5. No `__len__`, `__contains__`, or iteration support

The cache has no way to inspect its current size or check membership without performing a `get()` (which returns `None` ambiguously). Basic collection-protocol methods would make the class more useful and testable.

**Recommendation:** Add at minimum:
- `__len__` -- returns count of non-expired entries
- `__contains__` -- checks if a non-expired key exists

---

## Minor Issues

### 6. `max_size` eviction test does not verify *which* key was evicted

The test asserts that one of key1/key2 was evicted but does not verify it was the one with the earliest expiry. Since both are set nearly simultaneously, the test cannot actually verify the eviction policy is correct (earliest-expiry-first). A time-mocked test that sets key1 with expiry at T+100 and key2 with expiry at T+200 would properly validate the eviction order.

### 7. No test for concurrent access

The class is documented as "thread-safe" but there are no tests exercising concurrent reads/writes. A basic test with `threading.Thread` workers performing simultaneous `set`/`get`/`delete` operations would provide confidence in the locking strategy.

### 8. Unused import in tests

`from unittest.mock import patch` is imported in `tests/test_cache.py` but never used. Either remove it or (preferably) use it to replace the `time.sleep` calls per issue #3.

### 9. Type annotation uses `Optional[Any]`

`Optional[Any]` is equivalent to `Any` since `Any` already includes `None`. The return type of `get()` could simply be `Any`. This is cosmetic but may confuse readers into thinking `None` has special significance in the type system here (which it does semantically, but `Optional[Any]` doesn't enforce that).

---

## What Looks Good

- Clean, focused class with a single responsibility.
- Thread-safety via `threading.Lock` on all public methods.
- Lazy expiry on `get()` avoids the need for background cleanup threads.
- Two-phase eviction in `set()` (expire first, then evict oldest) is a sensible strategy.
- Type hints throughout.
- Tests cover the happy path for every public method.

---

## Verdict

**Approve with requested changes.** The implementation is solid for a utility class. The critical path issue is the `_evict_expired` thread-safety footgun (#1) -- add at minimum a docstring guard. The `time.sleep` tests (#3) should be converted to mocked time before merge to avoid slow/flaky CI. The remaining items are improvements that could land in a follow-up.
