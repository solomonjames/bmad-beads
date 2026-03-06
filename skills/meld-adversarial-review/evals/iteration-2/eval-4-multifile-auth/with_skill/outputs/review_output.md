# Adversarial Review: Auth Middleware, Admin Routes, and Profile Routes

**Baseline commit:** jkl3456
**Review type:** Inline review (Agent tool unavailable -- no true information asymmetry)
**Diff size:** ~155 lines across 4 files

---

## Findings

F1 [Critical/Real] -- SQL injection in audit-log endpoint
The audit-log query constructs SQL by interpolating user-supplied query parameters directly into the string (`'${startDate}'`, `'${endDate}'`, `'${action}'`). A `params` array is populated but the query itself uses string concatenation instead of parameterized placeholders (`$1`, `$2`, etc.). An attacker with admin or auditor access can inject arbitrary SQL.
Location: src/routes/admin.ts:93-95

F2 [Critical/Real] -- Hardcoded JWT secret in source code
The JWT signing secret is hardcoded as `'super-secret-key-do-not-share'` directly in the middleware file. This secret will be committed to version control and visible to anyone with repository access. It should be loaded from an environment variable or secrets manager.
Location: src/middleware/auth.ts:4

F3 [High/Real] -- Password change does not verify current password
The `/profile/password` endpoint destructures `currentPassword` from the request body but never uses it. The comment explicitly states "Just update without verifying current password." This means any authenticated session (including a stolen token) can change the user's password without knowing the original.
Location: src/routes/profile.ts:137-139

F4 [High/Real] -- Profile endpoint leaks sensitive fields via SELECT *
The `GET /profile` endpoint uses `SELECT * FROM users`, which will return all columns including the password hash. This hash is then sent directly to the client in the JSON response.
Location: src/routes/profile.ts:118-119

F5 [High/Real] -- No error handling in any async route handler
All route handlers are `async` but lack try/catch blocks. Any database error or unexpected exception will result in an unhandled promise rejection and a hung response (no error sent to the client). Express does not automatically catch errors from async handlers.
Location: src/routes/admin.ts:61-99, src/routes/profile.ts:117-147

F6 [High/Real] -- No input validation on role assignment
The `PUT /admin/users/:id/role` endpoint accepts any string as a `role` value from the request body without validation. An admin could set roles to arbitrary values (e.g., `"superadmin"`, empty string, or `null`), potentially causing authorization logic to behave unpredictably.
Location: src/routes/admin.ts:67-71

F7 [High/Real] -- Empty test suites for admin and profile routes
The test file contains only two meaningful tests (token generation and missing-token rejection). The `Admin routes` and `Profile routes` describe blocks are empty TODOs. This means zero test coverage for the route handlers, including the SQL injection and auth bypass issues.
Location: tests/auth.test.ts:25-31

F8 [Medium/Real] -- JWT payload cast to `any` with no validation
The decoded JWT payload is cast to `any` and assigned directly to `req.user` without verifying that it contains the expected `id`, `email`, and `role` fields. A malformed or tampered token (signed with the known hardcoded secret) could inject unexpected data.
Location: src/middleware/auth.ts:24-25

F9 [Medium/Real] -- No input validation on profile update fields
The `PUT /profile` endpoint passes `name`, `email`, and `bio` directly from the request body to the database with no validation. Email format is not checked, and any of these values could be undefined, causing the DB to set columns to NULL.
Location: src/routes/profile.ts:123-129

F10 [Medium/Undecided] -- Hard deletes with no soft-delete or confirmation
Both `DELETE /profile` and `DELETE /admin/users/:id` perform hard deletes with no soft-delete mechanism, audit trail, or multi-step confirmation. Whether this is appropriate depends on the application's data retention requirements.
Location: src/routes/profile.ts:144-146, src/routes/admin.ts:74-84

F11 [Medium/Undecided] -- JWT tokens lack audience and issuer claims
The `jwt.sign` call does not include `audience` or `issuer` options. In a multi-service environment, tokens could be replayed across services. Whether this matters depends on the deployment architecture.
Location: src/middleware/auth.ts:45

F12 [Low/Noise] -- Test hardcodes the JWT secret
The test file duplicates the hardcoded secret string to verify tokens. This is a direct consequence of F2 and will resolve when the secret is moved to configuration.
Location: tests/auth.test.ts:9

---

## Summary Table

| Severity     | Count | Real | Undecided | Noise |
|--------------|-------|------|-----------|-------|
| Critical     | 2     | 2    | 0         | 0     |
| High         | 5     | 5    | 0         | 0     |
| Medium       | 4     | 2    | 2         | 0     |
| Low          | 1     | 0    | 0         | 1     |
| **Total**    | **12**| **9**| **2**     | **1** |

---

## Resolution Options

- **[W] Walk through** -- Iterate each finding, decide Fix/Skip/Discuss for each one
- **[F] Fix automatically** -- Apply fixes for the 9 "Real" findings, skip Noise and Undecided
- **[S] Skip** -- Acknowledge findings and proceed without fixes

**Recommendation:** F1 (SQL injection) and F2 (hardcoded secret) are critical security vulnerabilities that should be fixed before merging. F3 (password change bypass) and F4 (password hash leak) are also high-priority. Option [W] is recommended to walk through findings given the severity of several issues.
