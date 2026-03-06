# Adversarial Review: User Management CRUD Endpoints

**Baseline commit:** abc1234
**Diff source:** eval-files/diff-1-sql-injection.diff
**Review method:** Information-asymmetric inline review (reviewer saw ONLY the diff, no spec or conversation context)

---

## Findings

### F1 [Critical/Real] -- SQL Injection via string interpolation in all queries

All four SQL queries use template literal string interpolation to embed user-supplied values directly into SQL strings. This is textbook SQL injection affecting the SELECT (duplicate check), INSERT (user creation), DELETE, and search SELECT queries. An attacker can inject arbitrary SQL via email, name, id, role, or search query parameters.

**Fix:** Replace all string-interpolated queries with parameterized queries using `$1, $2, ...` placeholders and passing values as a separate array.

**Location:** src/api/users.ts lines ~21-22, ~30-31, ~39, ~50

---

### F2 [Critical/Real] -- Mass assignment / privilege escalation via role parameter

The POST /users endpoint destructures `role` from `req.body` and inserts it directly into the database with no validation. Any caller can self-assign any role (e.g., "admin") by including it in the request body.

**Fix:** Either remove `role` from user-controllable input (assign a default), or validate against an allowlist of permitted roles with authorization checks.

**Location:** src/api/users.ts line ~18, ~31

---

### F3 [High/Real] -- No input validation on any endpoint

No endpoint validates that required fields are present, non-empty, or well-formed. Missing `name`, `email`, or `password` on POST will produce undefined values in the query. Missing `q` on search produces the literal string "undefined" in SQL. The DELETE endpoint does not validate that `id` is numeric.

**Fix:** Add input validation (check required fields exist, validate email format, validate id is numeric, validate q is a non-empty string).

**Location:** src/api/users.ts lines ~18, ~38, ~49

---

### F4 [High/Real] -- No error handling / missing try-catch

All async route handlers lack try-catch blocks. Database errors will propagate to Express's default error handler, likely returning 500 with a stack trace that leaks internal information.

**Fix:** Wrap each handler body in try-catch, return structured error responses, and log errors appropriately.

**Location:** src/api/users.ts all route handlers

---

### F5 [High/Real] -- Unhandled promise rejection from sendWelcomeEmail

`sendWelcomeEmail(email, name)` is called without `await` and without `.catch()`. If it returns a rejecting promise, this causes an unhandled promise rejection that can crash the Node.js process.

**Fix:** Add `.catch()` handler: `sendWelcomeEmail(email, name).catch(err => logger.error(err))`.

**Location:** src/api/users.ts line ~35

---

### F6 [High/Undecided] -- DELETE endpoint missing authorization

The DELETE /users/:id endpoint has no visible authentication or authorization check. Any unauthenticated caller could delete any user by ID. However, auth middleware might be applied at the router level in code not visible in this diff.

**Location:** src/api/users.ts lines ~37-45

---

### F7 [High/Real] -- Search endpoint route ordering bug

`/users/search` is defined AFTER `/users/:id` in the router. Express matches routes in registration order, so requests to `/users/search` will be captured by the `:id` route (with `id = "search"`). The search endpoint will never be reached.

**Fix:** Move the `/users/search` route definition BEFORE the `/users/:id` route.

**Location:** src/api/users.ts line ~48 vs line ~14

---

### F8 [Medium/Real] -- Tests lack coverage for critical paths

DELETE tests contain only a TODO comment. No tests exist for the search endpoint. No tests cover error cases, missing fields, or security scenarios. Only happy-path creation and duplicate-email detection are tested.

**Location:** src/api/__tests__/users.test.ts lines ~25-27

---

### F9 [Medium/Undecided] -- No rate limiting on user creation

POST /users has no rate limiting visible in the diff. However, rate limiting may exist at the middleware or infrastructure level outside this diff's scope.

**Location:** src/api/users.ts POST route

---

### F10 [Low/Noise] -- Weak test password

Test fixtures use "pass123" as the password. This is normal for test data and not a production concern. The observation about missing password-strength validation is not evidenced by the diff.

**Location:** src/api/__tests__/users.test.ts

---

## Summary

| Severity | Count | Real | Undecided | Noise |
|----------|-------|------|-----------|-------|
| Critical | 2 | 2 | 0 | 0 |
| High | 5 | 4 | 1 | 0 |
| Medium | 2 | 1 | 1 | 0 |
| Low | 1 | 0 | 0 | 1 |
| **Total** | **10** | **7** | **2** | **1** |

The diff contains **2 critical security vulnerabilities** (SQL injection and privilege escalation) that must be fixed before merge. There are also 4 confirmed high-severity issues including a route-ordering bug that makes the search endpoint unreachable.

---

## Resolution Options

- **[W] Walk through** -- Iterate each finding, decide Fix/Skip/Discuss for each
- **[F] Fix automatically** -- Apply fixes for all "Real" findings, skip Noise/Undecided
- **[S] Skip** -- Acknowledge findings and proceed without fixes
