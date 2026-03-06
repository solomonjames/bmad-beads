# Code Review: User Management CRUD Endpoints

**Baseline commit:** abc1234
**Files changed:** `src/api/users.ts`, `src/api/__tests__/users.test.ts` (new)

---

## Critical Issues

### 1. SQL Injection Vulnerabilities (Critical / Security)

Every database query in this diff constructs SQL by interpolating user-supplied values directly into the query string. This is a textbook SQL injection vulnerability and must be fixed before merge.

**Affected locations:**

- **Line 22** -- `SELECT id FROM users WHERE email = '${email}'`
- **Line 32** -- `INSERT INTO users ... VALUES ('${name}', '${email}', '${hashedPassword}', '${role}') ...`
- **Line 45** -- `DELETE FROM users WHERE id = ${id}`
- **Line 56** -- `SELECT ... WHERE name LIKE '%${q}%'`

An attacker can supply a crafted `email`, `name`, `role`, `id`, or `q` value to execute arbitrary SQL -- read the entire database, delete tables, or escalate privileges.

**Fix:** Use parameterized queries throughout:

```ts
// Instead of:
db.query(`SELECT id FROM users WHERE email = '${email}'`);

// Use:
db.query('SELECT id FROM users WHERE email = $1', [email]);
```

Apply the same pattern to all four queries.

### 2. No Input Validation (High)

None of the request body or query parameters are validated before use. The `POST /users` endpoint destructures `name`, `email`, `password`, and `role` from `req.body` with no checks. If any field is `undefined`, the query will insert the literal string `'undefined'` into the database.

- Validate that required fields are present and non-empty.
- Validate `email` format.
- Enforce password strength requirements (minimum length at minimum).
- Validate that `role` is from an allowed set of values to prevent privilege escalation (e.g., a user submitting `role: 'admin'`).

### 3. Mass Assignment / Privilege Escalation via `role` (High)

The `role` field is accepted directly from the request body with no authorization check or allowlist. Any unauthenticated caller can create an admin account by sending `{ "role": "admin" }`. Either remove `role` from the user-supplied input (default it server-side) or require an authorized admin caller.

---

## Significant Issues

### 4. No Authentication or Authorization (High)

All endpoints -- create, delete, search -- appear to be completely unprotected. There is no middleware checking for authentication tokens or verifying the caller has permission to perform these operations. The `DELETE /users/:id` endpoint in particular allows any caller to delete any user.

### 5. No Error Handling (Medium)

None of the route handlers have try/catch blocks. If `db.query` throws (connection error, constraint violation, malformed input), the error will propagate as an unhandled rejection, likely returning a 500 with a stack trace that leaks internal details to the caller.

Wrap each handler body in try/catch and return appropriate error responses.

### 6. Route Ordering: `/users/search` Shadowed by `/users/:id` (Medium)

The `GET /users/search` route is defined after `GET /users/:id` (line 12 in the existing code). Express evaluates routes in definition order, so a request to `GET /users/search` will match the `:id` param route first, with `id` set to `"search"`. The search endpoint will never be reached.

**Fix:** Move the `/users/search` route definition above `/users/:id`, or use a different URL pattern (e.g., `/search/users`).

### 7. Unhandled Promise from `sendWelcomeEmail` (Medium)

`sendWelcomeEmail(email, name)` is called as a fire-and-forget on line 39. If this function returns a promise that rejects, it becomes an unhandled promise rejection, which in Node.js 15+ terminates the process by default.

At minimum, add `.catch()` to log and swallow the error:

```ts
sendWelcomeEmail(email, name).catch(err => logger.error('Welcome email failed', err));
```

---

## Minor Issues

### 8. Password Returned in Response (Low)

The `INSERT ... RETURNING id, name, email, role` on line 32 does not return the password column, which is correct. However, this is only safe as long as that `RETURNING` clause is maintained. Consider using a shared projection or DTO to ensure the password hash is never accidentally leaked.

### 9. DELETE Returns 204 but Search Has No Pagination (Low)

The search endpoint returns all matching rows with no `LIMIT`. On a large dataset, `LIKE '%..%'` is a full table scan and could return an unbounded number of results. Add pagination parameters (`limit`, `offset`).

### 10. Test Coverage Gaps (Low)

- The `DELETE /users/:id` test suite is empty (`// TODO: Add tests`).
- There are no tests for `GET /users/search`.
- There are no tests for invalid input, missing fields, or error cases.
- There are no tests exercising SQL injection payloads to verify the queries are safe (they are not).

---

## Summary

This diff must not be merged in its current state. The SQL injection vulnerabilities alone are a blocking concern -- they are present in every new query and would allow full database compromise. The lack of input validation and authentication are secondary but also critical for a production endpoint.

**Recommended priority for fixes:**
1. Convert all queries to parameterized queries (SQL injection).
2. Add input validation for all endpoints.
3. Remove user-controllable `role` assignment or gate it behind authorization.
4. Add authentication/authorization middleware.
5. Add try/catch error handling to all handlers.
6. Fix the route ordering for `/users/search`.
7. Handle the `sendWelcomeEmail` promise rejection.
8. Complete the test suite.
