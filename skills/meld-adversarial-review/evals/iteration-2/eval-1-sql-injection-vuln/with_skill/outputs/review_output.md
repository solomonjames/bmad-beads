# Adversarial Review Results

**Review type:** Inline review (Agent tool unavailable -- no true information asymmetry)
**Diff reviewed:** `diff-1-sql-injection.diff` (src/api/users.ts + src/api/__tests__/users.test.ts)

---

## Findings

F1 [Critical/Real] -- SQL injection in POST /users via string interpolation in SELECT query
The `email` value from `req.body` is interpolated directly into the SQL string without parameterization: `` `SELECT id FROM users WHERE email = '${email}'` ``. An attacker can supply a crafted email value (e.g., `' OR '1'='1`) to bypass the duplicate check or exfiltrate data. This is a textbook SQL injection vulnerability.
Location: src/api/users.ts:22

F2 [Critical/Real] -- SQL injection in POST /users via string interpolation in INSERT query
The INSERT statement interpolates `name`, `email`, `hashedPassword`, and `role` directly into SQL: `` `INSERT INTO users (name, email, password, role) VALUES ('${name}', '${email}', '${hashedPassword}', '${role}')` ``. All four fields are attacker-controlled (or derived from attacker input). This enables SQL injection for data manipulation, privilege escalation (injecting `role`), or data exfiltration.
Location: src/api/users.ts:32

F3 [Critical/Real] -- SQL injection in DELETE /users/:id via unparameterized id
The DELETE query interpolates `id` from `req.params` directly: `` `DELETE FROM users WHERE id = ${id}` ``. Since `id` is not quoted and not parameterized, an attacker can inject arbitrary SQL (e.g., `1 OR 1=1` to delete all users).
Location: src/api/users.ts:45

F4 [Critical/Real] -- SQL injection in GET /users/search via unparameterized query string
The search endpoint interpolates `q` from `req.query` directly into a LIKE clause: `` `SELECT id, name, email FROM users WHERE name LIKE '%${q}%'` ``. This is exploitable for SQL injection via the query string parameter, which is trivially accessible.
Location: src/api/users.ts:56

F5 [High/Real] -- No input validation on any endpoint
None of the new endpoints validate that required fields are present or well-formed. POST /users does not check that `name`, `email`, `password`, or `role` are non-null, non-empty, or of the expected type. DELETE and search endpoints similarly accept any input. Missing fields will result in `undefined` being interpolated into SQL, causing errors or unexpected behavior.
Location: src/api/users.ts:18, 43, 54

F6 [High/Real] -- No authorization or authentication check on any endpoint
The DELETE endpoint allows anyone to delete any user by ID. The POST endpoint allows anyone to create a user with any role (including presumably admin/elevated roles). The search endpoint exposes user data. None of the endpoints check for authentication or authorization.
Location: src/api/users.ts:17, 43, 54

F7 [High/Real] -- Role field is user-controlled with no validation
The `role` field is taken directly from `req.body` and inserted into the database. An attacker can set their own role to "admin" or any privileged value. There is no allowlist or validation of permitted role values.
Location: src/api/users.ts:18, 32

F8 [High/Real] -- Unhandled promise rejection from sendWelcomeEmail
`sendWelcomeEmail(email, name)` is called without `await` and without a `.catch()` handler. If this function returns a rejected promise, it will cause an unhandled promise rejection, which in Node.js can crash the process. Fire-and-forget async calls need explicit error suppression.
Location: src/api/users.ts:38

F9 [High/Real] -- No error handling / try-catch around database operations
None of the three new route handlers wrap their database calls in try-catch blocks. A database connection failure, constraint violation, or malformed query will result in an unhandled exception, returning a 500 with a stack trace (information leakage) or crashing the process.
Location: src/api/users.ts:17-41, 43-51, 54-58

F10 [High/Real] -- DELETE and search endpoints have no tests
The test file contains `describe('DELETE /users/:id')` with only a TODO comment and zero test cases. The GET /users/search endpoint has no test describe block at all. This leaves critical functionality (including a destructive operation) entirely untested.
Location: src/api/__tests__/users.test.ts:92-94

F11 [Medium/Real] -- Password returned in INSERT RETURNING clause
The INSERT query uses `RETURNING id, name, email, role` which appears correct, but the hashed password is stored. If the RETURNING clause were ever changed or if the `result.rows[0]` object is logged/serialized elsewhere, the hashed password could leak. This is acceptable as-is but worth noting as a fragility.
Location: src/api/users.ts:32

F12 [Medium/Real] -- Search endpoint has no pagination or result limiting
The search query returns all matching rows with no LIMIT clause. A broad search term (or an empty `q` parameter) could return the entire users table, causing performance issues and excessive data exposure.
Location: src/api/users.ts:56

F13 [Medium/Real] -- Route ordering issue: /users/search may be shadowed by /users/:id
Express matches routes in order. If `router.get('/users/:id')` is defined before `router.get('/users/search')`, then a request to `/users/search` will match the `:id` route with `id = "search"`. The diff shows the search route is added after the existing `:id` route, so it will never be reached.
Location: src/api/users.ts:54 (relative to existing route at line 12)

F14 [Low/Real] -- Test uses weak password value
The test sends `password: 'pass123'` which, while fine for testing, may trigger password policy violations if any are added later. Minor concern.
Location: src/api/__tests__/users.test.ts:76

---

## Summary Table

| Severity | Count | Real | Undecided | Noise |
|----------|-------|------|-----------|-------|
| Critical | 4 | 4 | 0 | 0 |
| High | 6 | 6 | 0 | 0 |
| Medium | 3 | 3 | 0 | 0 |
| Low | 1 | 1 | 0 | 0 |
| **Total** | **14** | **14** | **0** | **0** |

---

## Resolution Options

- **[W] Walk through** -- Iterate each finding, ask Fix/Skip/Discuss for each
- **[F] Fix automatically** -- Apply fixes for all "Real" findings, skip Noise/Undecided
- **[S] Skip** -- Acknowledge findings and proceed without fixes

The most urgent items are **F1-F4** (SQL injection in every query). These should be converted to parameterized queries immediately. **F5-F9** address missing validation, authorization, error handling, and unsafe async patterns. **F13** (route shadowing) will cause the search endpoint to be unreachable entirely.

How would you like to proceed? [W/F/S]
