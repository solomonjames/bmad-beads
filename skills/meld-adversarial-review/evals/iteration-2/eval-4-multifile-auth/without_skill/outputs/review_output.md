# Adversarial Code Review: Auth Middleware, Admin Routes, and Profile Routes

**Baseline commit:** jkl3456
**Files reviewed:**
- `src/middleware/auth.ts`
- `src/routes/admin.ts`
- `src/routes/profile.ts`
- `tests/auth.test.ts`

---

## CRITICAL Issues

### 1. Hardcoded JWT Secret (src/middleware/auth.ts, line 4)

```typescript
const JWT_SECRET = 'super-secret-key-do-not-share';
```

The JWT signing secret is hardcoded in source code. This is a severe security vulnerability. The secret will be committed to version control, visible to anyone with repo access, and identical across all environments. This must be loaded from an environment variable (e.g., `process.env.JWT_SECRET`) with a startup check that fails if the variable is not set.

### 2. SQL Injection in Audit Log Endpoint (src/routes/admin.ts, lines 93-95)

```typescript
if (startDate) { query += ` AND created_at >= '${startDate}'`; params.push(startDate); }
if (endDate) { query += ` AND created_at <= '${endDate}'`; params.push(endDate); }
if (action) { query += ` AND action = '${action}'`; params.push(action); }
```

Query parameters from `req.query` are interpolated directly into the SQL string via template literals. The values are also pushed into a `params` array, but the query itself uses string interpolation (`'${startDate}'`) instead of parameterized placeholders (`$1`, `$2`, etc.). This means the params array is never actually used for escaping -- the raw user input is embedded directly in the SQL. This is a textbook SQL injection vulnerability in an admin/auditor endpoint.

The fix must use parameterized queries with positional placeholders:
```typescript
let paramIndex = 1;
if (startDate) { query += ` AND created_at >= $${paramIndex++}`; params.push(startDate); }
if (endDate) { query += ` AND created_at <= $${paramIndex++}`; params.push(endDate); }
if (action) { query += ` AND action = $${paramIndex++}`; params.push(action); }
```

### 3. Password Change Does Not Verify Current Password (src/routes/profile.ts, lines 137-138)

```typescript
// Just update without verifying current password
const hashed = await hashPassword(newPassword);
```

The `currentPassword` variable is destructured from the request body but never used. The comment explicitly acknowledges this omission. This means anyone with a valid session token can change a user's password without knowing the existing one. If a token is stolen, the attacker can immediately lock the real user out by changing the password. The current password must be verified via hash comparison before allowing the update.

---

## HIGH Issues

### 4. Unsafe Type Assertion on JWT Payload (src/middleware/auth.ts, line 24)

```typescript
const decoded = jwt.verify(token, JWT_SECRET) as any;
req.user = decoded;
```

The decoded JWT payload is cast to `any` and assigned directly to `req.user` without any validation. A token could contain unexpected or malicious fields. The decoded payload should be validated to confirm it contains the expected `id`, `email`, and `role` fields with correct types before assignment.

### 5. Profile GET Returns All Columns Including Password (src/routes/profile.ts, line 118)

```typescript
const result = await db.query('SELECT * FROM users WHERE id = $1', [req.user!.id]);
res.json(result.rows[0]);
```

`SELECT *` fetches every column from the `users` table, which almost certainly includes the password hash. This is then serialized directly to the JSON response. The query should explicitly select only the columns intended for the client (e.g., `id, name, email, bio, role`).

### 6. Profile PUT Returns All Columns Including Password (src/routes/profile.ts, lines 124-128)

Same issue as above -- the `RETURNING *` clause returns all columns, including the password hash, in the response body. Use `RETURNING id, name, email, bio` instead.

### 7. No Input Validation on Role Update (src/routes/admin.ts, lines 68-71)

```typescript
const { role } = req.body;
await db.query('UPDATE users SET role = $1 WHERE id = $2', [role, id]);
```

The role value from the request body is not validated. An admin could set a role to any arbitrary string, potentially creating inconsistent data or bypassing authorization checks that depend on a known set of roles. Validate against an allowlist of permitted roles.

### 8. No Input Validation on Profile Update (src/routes/profile.ts, lines 123-128)

The `name`, `email`, and `bio` fields are accepted from the request body with no validation -- no length limits, no email format check, no sanitization. This could lead to data integrity issues or abuse (e.g., extremely long strings, invalid email formats).

### 9. No Input Validation on Password Change (src/routes/profile.ts, lines 131-141)

`newPassword` is not validated for minimum length, complexity, or even presence. A user could set an empty string as their password.

---

## MEDIUM Issues

### 10. No Error Handling on Database Queries (all route files)

None of the `async` route handlers have try/catch blocks. If any `db.query` call throws (connection error, constraint violation, etc.), the error will propagate as an unhandled promise rejection, likely resulting in a 500 with a stack trace leak or, worse, a crashed process if unhandled rejection handling is not configured.

Wrap handlers in try/catch or use an async error-handling middleware wrapper.

### 11. Self-Deletion Check Uses String Comparison (src/routes/admin.ts, line 79)

```typescript
if (id === adminId) {
```

`req.params.id` is always a string from the URL. `req.user!.id` is typed as `string` but comes from a JWT payload cast to `any`, so there is no guarantee it is actually a string at runtime. If the JWT stores `id` as a number, this comparison would silently fail, allowing an admin to delete their own account. Use a consistent type or coerce both sides.

### 12. Account Deletion Has No Cascading or Cleanup Logic (src/routes/admin.ts, line 83; src/routes/profile.ts, line 145)

Both admin user deletion and self-deletion perform a raw `DELETE FROM users`. There is no mention of cascading deletes, soft deletes, session invalidation, or cleanup of related data (audit logs, user content, etc.). If foreign key constraints exist without `ON DELETE CASCADE`, these queries will fail silently or throw. If they do not exist, orphaned data will remain.

### 13. Token Expiration Is Long (src/middleware/auth.ts, line 45)

The token expiration is set to 24 hours. Depending on the application's risk profile, this may be too long -- especially given that there is no token revocation mechanism. Consider shorter-lived access tokens paired with a refresh token flow.

### 14. No Audit Logging on Sensitive Operations

The admin routes include an audit log read endpoint, but none of the write operations (role changes, user deletion, password changes) create audit log entries. This undermines the value of the audit log.

---

## LOW Issues

### 15. Test Coverage Is Skeletal (tests/auth.test.ts)

Only two basic unit tests exist for the auth middleware. The admin and profile route test suites are empty TODO stubs. There is no coverage for:
- Token expiration behavior
- Authorization role checks
- Any route handler behavior
- SQL injection resistance
- Error handling paths

### 16. Test Hardcodes the JWT Secret (tests/auth.test.ts, line 9)

```typescript
const decoded = jwt.verify(token, 'super-secret-key-do-not-share') as any;
```

The test duplicates the hardcoded secret. Once the secret is moved to an environment variable, this test will break. The test should use the same configuration source as the application code.

### 17. Non-null Assertions on req.user (multiple locations)

`req.user!.id` is used throughout with the non-null assertion operator. While `authenticate` middleware runs first and should populate `req.user`, the TypeScript type system does not enforce middleware execution order. A safer pattern is a runtime check or a helper that throws a clear error if `req.user` is missing.

---

## Summary

The most urgent items to fix before merge are:

1. **Hardcoded JWT secret** -- move to environment variable immediately.
2. **SQL injection in audit log** -- the string interpolation must be replaced with parameterized placeholders.
3. **Password change skips verification** -- current password must be validated.
4. **Profile endpoints leak password hashes** -- replace `SELECT *` and `RETURNING *` with explicit column lists.

These four issues represent concrete, exploitable vulnerabilities. The remaining items (input validation, error handling, audit logging, test coverage) are important for production readiness but are lower priority than the security fixes above.
