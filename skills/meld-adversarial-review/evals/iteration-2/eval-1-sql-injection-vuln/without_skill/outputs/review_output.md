# Code Review: User Management CRUD Endpoints

**Baseline commit:** abc1234
**Files changed:** `src/api/users.ts`, `src/api/__tests__/users.test.ts` (new)

---

## Critical Issues

### 1. SQL Injection Vulnerabilities (CRITICAL / SECURITY)

Every new query in this diff interpolates user-controlled input directly into SQL strings. This is the single most dangerous class of web vulnerability (OWASP A03:2021 - Injection).

**Affected locations:**

- **Line 22** -- `SELECT` with `email` interpolated:
  ```ts
  `SELECT id FROM users WHERE email = '${email}'`
  ```
- **Line 32** -- `INSERT` with `name`, `email`, `hashedPassword`, `role` interpolated:
  ```ts
  `INSERT INTO users (name, email, password, role) VALUES ('${name}', '${email}', '${hashedPassword}', '${role}') ...`
  ```
- **Line 45** -- `DELETE` with `id` interpolated:
  ```ts
  `DELETE FROM users WHERE id = ${id}`
  ```
- **Line 56** -- `SELECT` with `q` interpolated inside a `LIKE` clause:
  ```ts
  `SELECT id, name, email FROM users WHERE name LIKE '%${q}%'`
  ```

An attacker can exploit any of these to read, modify, or destroy the entire database. For example, a POST to `/users` with `email` set to `'; DROP TABLE users; --` would execute arbitrary SQL.

**Fix:** Use parameterized queries throughout:
```ts
const existing = await db.query(
  'SELECT id FROM users WHERE email = $1',
  [email]
);
```

Apply the same pattern to every query.

### 2. No Input Validation (HIGH)

The `POST /users` endpoint destructures `name`, `email`, `password`, and `role` from `req.body` with no validation whatsoever. Missing or malformed values will either produce database errors or insert garbage data.

- No check that required fields are present.
- No email format validation.
- No password strength requirements.
- `role` is accepted directly from user input (see Privilege Escalation below).

**Fix:** Validate all inputs before processing. Use a schema validation library (e.g., `zod`, `joi`) or at minimum add explicit checks. Return 400 for invalid input.

### 3. Privilege Escalation via User-Controlled `role` (HIGH / SECURITY)

The `role` field is taken directly from the request body and inserted into the database. Any caller can set themselves as `admin` (or any other privileged role) at account creation time.

**Fix:** Either remove `role` from the accepted body fields and assign a default, or enforce an authorization check ensuring only admins can set roles.

---

## Major Issues

### 4. No Authentication or Authorization (HIGH)

None of the endpoints have any authentication or authorization middleware. The `DELETE /users/:id` endpoint is particularly dangerous -- any unauthenticated caller can delete any user.

**Fix:** Add authentication middleware to all routes. Add authorization checks (e.g., only admins can delete users or only the user themselves can modify their own record).

### 5. No Error Handling (MEDIUM)

Every route handler uses `async` but has no `try/catch` blocks. If `db.query`, `hashPassword`, or `sendWelcomeEmail` throws, the error will propagate as an unhandled promise rejection (or, depending on Express version, a 500 with a stack trace leak).

**Fix:** Wrap each handler body in a `try/catch` that returns a generic 500 response and logs the error internally. Alternatively, use an Express error-handling middleware and wrap async handlers.

### 6. Route Ordering Bug: `/users/search` Is Unreachable (MEDIUM)

The `GET /users/search` route is defined after `GET /users/:id` (which exists in the pre-existing code, visible in the diff context). Express evaluates routes in order, so a request to `/users/search` will match `/users/:id` first, with `id` set to `"search"`.

**Fix:** Move the `/users/search` route definition above the `/users/:id` route.

---

## Minor Issues

### 7. Unhandled `sendWelcomeEmail` Failures (LOW)

`sendWelcomeEmail(email, name)` is called as a fire-and-forget promise. If it rejects, the rejection is unhandled. This won't affect the response but will produce unhandled rejection warnings/crashes in Node.

**Fix:** At minimum, add `.catch()` to log and suppress the error:
```ts
sendWelcomeEmail(email, name).catch(err => logger.error('Welcome email failed', err));
```

### 8. Password Returned in Response (MEDIUM / SECURITY)

The `INSERT ... RETURNING id, name, email, role` clause looks correct, but if the query or ORM is later changed to `RETURNING *`, the hashed password would leak. The current code is safe but fragile. Consider explicitly selecting fields from the result rather than trusting the SQL projection.

### 9. Incomplete Tests (LOW)

- `DELETE /users/:id` describe block is empty (`// TODO: Add tests`).
- No tests for `GET /users/search`.
- No tests for `PUT /users/:id`.
- No tests for error cases (missing fields, invalid data).
- No tests for SQL injection resistance.

---

## Summary

This diff has **four separate SQL injection vulnerabilities** that are immediately exploitable. That alone makes this code unsafe to merge. Beyond injection, there is no input validation, no auth, no error handling, and a privilege escalation vector through the `role` field. The route ordering will also make the search endpoint unreachable.

**Verdict: Do not merge.** All parameterized query fixes and input validation must be applied before this code should be reconsidered.
