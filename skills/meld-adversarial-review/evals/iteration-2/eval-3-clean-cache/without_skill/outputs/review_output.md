# Adversarial Code Review: TTL Cache Implementation

**Baseline Commit:** ghi9012
**Files Reviewed:** `lib/cache.py`, `tests/test_cache.py`

---

## Summary

A thread-safe TTL (time-to-live) cache with max-size eviction. The implementation is clean and compact. Several issues found ranging from correctness concerns to test reliability problems.

---

## Critical Issues

### 1. `_evict_expired` is called without the lock from a context that already holds it -- but that is fine here (reentrant by structure). However, `_evict_expired` is never called outside of `set`, meaning expired entries accumulate silently.

**Location:** `lib/cache.py`, lines 52-56

Expired entries are only cleaned up in two situations: (a) when `get` is called for that specific key, or (b) when `set` hits the max-size limit. If callers primarily read keys that are still alive, dead entries pile up consuming memory indefinitely. Consider a periodic or opportunistic sweep, or at minimum an explicit `size()` or `cleanup()` public method so callers can manage this.

### 2. Eviction under max_size races with expired-but-uncollected entries

**Location:** `lib/cache.py`, lines 33-37

When the cache is full, `_evict_expired` runs first, then if still full, the entry with the nearest expiry is evicted. But the "oldest by expiry" heuristic evicts the entry that will expire *soonest*, not the one that was *least recently used*. This means a long-TTL entry that was just inserted could survive while a short-TTL entry that is still actively used gets evicted. The variable name `oldest_key` is misleading -- it finds the entry with the smallest expiry timestamp, which is the one expiring soonest, not the oldest by insertion time.

**Recommendation:** Decide on a clear eviction policy (LRU, soonest-to-expire, or oldest-inserted) and name accordingly. If soonest-to-expire is intentional, rename `oldest_key` to `nearest_expiry_key`.

---

## Moderate Issues

### 3. `time.sleep` in tests makes the test suite slow and flaky

**Location:** `tests/test_cache.py`, lines 79, 85

Two tests use `time.sleep(1.1)` to wait for expiration. This adds over 2 seconds to every test run and is inherently flaky on slow CI machines. The test file already imports `unittest.mock.patch` but never uses it.

**Recommendation:** Mock `time.time` to simulate time advancement:

```python
def test_expired_key_returns_none(self):
    cache = TTLCache(default_ttl=10)
    cache.set("key1", "value1")
    with patch("lib.cache.time.time", return_value=time.time() + 11):
        assert cache.get("key1") is None
```

### 4. `get` returns `None` for both "key not found" and "key expired" -- no way to distinguish from a legitimately stored `None` value

**Location:** `lib/cache.py`, lines 21-29

If a caller does `cache.set("k", None)`, then `cache.get("k")` returns `None`, which is indistinguishable from a cache miss.

**Recommendation:** Either (a) raise `KeyError` on miss (like `dict`), (b) use a sentinel value internally, or (c) provide a `contains` / `has` method. A common pattern is to accept a `default` parameter and use a private sentinel:

```python
_MISSING = object()

def get(self, key: str, default: Any = _MISSING) -> Any:
    ...
    if default is _MISSING:
        raise KeyError(key)
    return default
```

### 5. No `__len__`, `__contains__`, or `keys()` methods

The cache has no way to inspect its current size or contents. This makes debugging and monitoring difficult. At minimum, a `__len__` method would be useful, especially since `max_size` is a configurable parameter.

---

## Minor Issues

### 6. `Optional` import is unnecessary on Python 3.10+

**Location:** `lib/cache.py`, line 3

The type hints use `Optional[Any]` and `Optional[int]`, but since `Any` already encompasses `None`, `Optional[Any]` is redundant -- it is equivalent to `Any`. The `Optional[int]` in `set` is valid, but on Python 3.10+ you can write `int | None` instead.

### 7. Test for max_size eviction is imprecise

**Location:** `tests/test_cache.py`, lines 103-112

The test asserts that "one of the first two should have been evicted" but does not verify *which* one. Given the eviction policy (smallest expiry), the test should assert that `key1` was evicted since it has the earliest expiry. The current test would pass even if the eviction policy were random.

### 8. No test for thread safety

The class docstring claims it is "thread-safe," but no test exercises concurrent access. A basic test with multiple threads doing `set`/`get` concurrently would validate the locking behavior.

### 9. No test for `_evict_expired` behavior during `set`

There is no test that verifies expired entries are cleaned up when `set` is called at capacity. For example: fill to max_size, let some entries expire, then set a new key and verify it succeeds without evicting a live entry.

---

## Verdict

**The implementation is sound for simple use cases** but has a semantic ambiguity in the eviction policy naming, a cache-miss sentinel problem when storing `None` values, and tests that rely on real-time sleeps despite importing the mock machinery to avoid them. The expired-entry accumulation could become a memory concern under write-heavy, read-light workloads.

**Recommended actions before merge:**
1. Fix the misleading `oldest_key` naming or change the eviction policy to match intent.
2. Replace `time.sleep` in tests with mocked time (the import is already there).
3. Decide on a sentinel strategy for `None` values or document the limitation.
4. Add at minimum a `__len__` method for observability.
