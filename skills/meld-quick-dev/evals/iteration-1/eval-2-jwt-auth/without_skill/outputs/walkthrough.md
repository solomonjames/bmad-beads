# Walkthrough: Adding JWT Authentication to an Express API

## The Request

Add user authentication with JWT tokens to an existing Express API. Requirements: login/register endpoints, password hashing, token refresh, route-protection middleware. Stack: TypeScript, Prisma, Jest.

---

## Step 1: Reconnaissance -- Understand the Existing Codebase

Before writing a single line, I would explore the project to understand what already exists.

**Actions:**
- Use `Glob` to find key structural files: `**/tsconfig.json`, `**/package.json`, `**/prisma/schema.prisma`, `**/src/**/*.ts`.
- Use `Read` on `package.json` to check existing dependencies (express version, any auth-related packages already installed, test configuration).
- Use `Read` on `prisma/schema.prisma` to see the current data model -- are there already User-related models?
- Use `Glob` and `Grep` to find the Express app entry point (`app.ts`, `server.ts`, `index.ts`) and understand how routes are currently organized (router files, middleware patterns, folder conventions).
- Use `Grep` to search for any existing auth-related code (`auth`, `jwt`, `bcrypt`, `password`, `token`) to avoid duplicating work or conflicting with partial implementations.

**Decisions I would make based on findings:**
- If routes are organized as `src/routes/someFeature.ts` with a central router registration in `app.ts`, I would follow that pattern exactly.
- If there is already a `User` model in Prisma, I would extend it rather than create a new one. If not, I would create one.
- If the project uses a particular error-handling pattern (e.g., a custom `AppError` class, centralized error middleware), I would adopt it for auth errors.
- I would note the TypeScript strictness level and coding style (semicolons, quotes, import style) to match.

---

## Step 2: Install Dependencies

**Action:** Run a single `npm install` (or `yarn add` / `pnpm add`, matching whatever the project uses) command.

```
npm install bcryptjs jsonwebtoken
npm install -D @types/bcryptjs @types/jsonwebtoken
```

**Decision rationale:**
- `bcryptjs` over `bcrypt` because it is a pure JS implementation with no native compilation step -- fewer platform issues, and the performance difference is negligible for an auth flow.
- `jsonwebtoken` is the standard JWT library for Node.
- If `dotenv` is not already present and the project does not use another config mechanism, I would add it for managing `JWT_SECRET` and `JWT_REFRESH_SECRET`.

---

## Step 3: Update the Prisma Schema

**Action:** Use `Edit` to add a `User` model to `prisma/schema.prisma` (or extend an existing one).

**What I would add:**

```prisma
model User {
  id           String   @id @default(cuid())
  email        String   @unique
  password     String
  refreshToken String?
  createdAt    DateTime @default(now())
  updatedAt    DateTime @updatedAt
}
```

**Decisions:**
- `cuid()` vs `uuid()` -- I would match whatever convention existing models use. If no convention exists, `cuid()` is the default.
- Store `refreshToken` on the User model directly for simplicity. In a production system with multiple devices, a separate `RefreshToken` table with device metadata would be better, but the request does not indicate that level of complexity. I would mention this trade-off to the user.
- `password` stores the bcrypt hash, never the plaintext. The field name `password` is conventional; some prefer `passwordHash` for clarity. I would match existing conventions if any exist.

**Then run:**
```
npx prisma migrate dev --name add-user-model
npx prisma generate
```

---

## Step 4: Create Auth Utility Module

**Action:** Create `src/utils/auth.ts` (or `src/lib/auth.ts`, matching project conventions).

**Contents:**
- `hashPassword(plain: string): Promise<string>` -- wraps `bcryptjs.hash` with a salt rounds constant (12).
- `comparePassword(plain: string, hash: string): Promise<boolean>` -- wraps `bcryptjs.compare`.
- `generateAccessToken(payload: { userId: string }): string` -- calls `jwt.sign` with a short expiry (15 minutes).
- `generateRefreshToken(payload: { userId: string }): string` -- calls `jwt.sign` with a longer expiry (7 days) and a separate secret.
- `verifyAccessToken(token: string): JwtPayload` -- wraps `jwt.verify`, throws on invalid/expired.
- `verifyRefreshToken(token: string): JwtPayload` -- same, but uses the refresh secret.

**Decisions:**
- Secrets come from environment variables (`process.env.JWT_SECRET`, `process.env.JWT_REFRESH_SECRET`). I would throw a clear error at startup if they are missing.
- Access token expiry: 15 minutes is a reasonable default. Refresh token: 7 days.
- I would define a `TokenPayload` interface (`{ userId: string; iat: number; exp: number }`) for type safety.

---

## Step 5: Create Auth Middleware

**Action:** Create `src/middleware/auth.ts` (or follow whatever middleware directory pattern exists).

**Contents:**
- `authenticate` middleware function that:
  1. Reads the `Authorization` header, expects `Bearer <token>`.
  2. Calls `verifyAccessToken`.
  3. On success, attaches `req.user = { userId }` to the request object.
  4. On failure, returns 401 with a JSON error.
- Augment the Express `Request` type to include `user` via declaration merging (a `src/types/express.d.ts` file or inline module augmentation).

**Decisions:**
- Middleware returns JSON errors (`{ error: "Unauthorized" }`), not HTML -- this is an API.
- I would check whether the project already has a pattern for extending the Request type and follow it.
- The middleware is a standard Express `(req, res, next)` function. No class-based patterns unless the project uses them.

---

## Step 6: Create Auth Routes

**Action:** Create `src/routes/auth.ts` (or `src/controllers/auth.ts` + `src/routes/auth.ts` if the project separates controllers from route definitions).

**Endpoints:**

### POST /auth/register
1. Validate request body: `email` (valid email format), `password` (minimum 8 characters).
2. Check if user with that email already exists (`prisma.user.findUnique`). Return 409 if so.
3. Hash password with `hashPassword`.
4. Create user with `prisma.user.create`.
5. Generate access and refresh tokens.
6. Store hashed refresh token on the user record.
7. Return `{ accessToken, refreshToken, user: { id, email } }` with 201 status.

### POST /auth/login
1. Validate request body.
2. Find user by email. Return 401 ("Invalid credentials") if not found -- do not reveal whether the email exists.
3. Compare password. Return 401 if mismatch.
4. Generate both tokens.
5. Store refresh token on user.
6. Return `{ accessToken, refreshToken, user: { id, email } }`.

### POST /auth/refresh
1. Accept `{ refreshToken }` in body.
2. Verify the refresh token (signature + expiry).
3. Find user by `userId` from token payload.
4. Compare the provided refresh token against the stored one (guards against reuse after rotation).
5. Generate new access token and new refresh token (token rotation).
6. Store the new refresh token, invalidating the old one.
7. Return `{ accessToken, refreshToken }`.

### POST /auth/logout (optional but good practice)
1. Requires `authenticate` middleware.
2. Clear the user's stored refresh token (`prisma.user.update({ refreshToken: null })`).
3. Return 204.

**Decisions:**
- Input validation: If the project uses a validation library (zod, joi, express-validator), I would use it. If not, I would use simple manual checks rather than introducing a new dependency for this task alone -- but I would mention to the user that a validation library is recommended.
- Error responses follow whatever pattern the project uses. If no pattern exists, I would use `{ error: string }` consistently.
- Refresh token rotation (issuing a new refresh token on each refresh call) is a security best practice that prevents replay attacks. I would implement this by default.
- The refresh token stored in the DB should be hashed (using bcrypt), not stored in plaintext, for the same reason passwords are hashed. This adds a `comparePassword` call to the refresh flow. I would note this to the user.

---

## Step 7: Register Routes and Apply Middleware

**Action:** Use `Edit` to modify the main app file (`app.ts` or `server.ts`).

**Changes:**
- Import and mount the auth router: `app.use('/auth', authRouter)`.
- Apply the `authenticate` middleware to existing protected routes. This depends on how routes are structured:
  - If there is a clear grouping (e.g., `/api/...` routes that should all be protected), apply middleware at the router level: `app.use('/api', authenticate, apiRouter)`.
  - If protection is route-by-route, apply it selectively.
- I would ask the user which routes should be protected if it is not obvious from context.

**Decisions:**
- Auth routes (`/auth/register`, `/auth/login`, `/auth/refresh`) must NOT be behind the auth middleware -- they are public by definition.
- I would place the auth router registration before protected routes to ensure proper ordering.

---

## Step 8: Environment Configuration

**Action:** Edit `.env.example` (or create it if it does not exist) to document required variables.

```
JWT_SECRET=your-secret-key-here
JWT_REFRESH_SECRET=your-refresh-secret-key-here
```

**Then** add actual values to `.env` (which should already be in `.gitignore`). For development, I would generate random strings.

**Decision:** I would verify `.env` is in `.gitignore` before proceeding. If not, I would add it and warn the user.

---

## Step 9: Write Tests

**Action:** Create test files following the project's test structure (likely `__tests__/` or `tests/` or colocated `*.test.ts` files).

### Unit Tests: `src/utils/auth.test.ts`
- `hashPassword` produces a string that is not the original password.
- `comparePassword` returns true for correct password, false for incorrect.
- `generateAccessToken` produces a valid JWT that can be verified.
- `verifyAccessToken` throws for expired or tampered tokens.
- Same tests for refresh token functions.

### Integration Tests: `src/routes/auth.test.ts`
- **Register:** successful registration returns 201 with tokens and user data; duplicate email returns 409; missing fields return 400.
- **Login:** correct credentials return 200 with tokens; wrong password returns 401; nonexistent email returns 401 (same error message as wrong password).
- **Refresh:** valid refresh token returns new token pair; expired refresh token returns 401; reused (rotated-out) refresh token returns 401.
- **Protected route access:** request with valid token succeeds; request without token returns 401; request with expired token returns 401.

**Decisions:**
- For integration tests, I need a test database. I would check if the project already has a test DB setup (e.g., a `prisma/test-setup.ts` or `jest.setup.ts` that resets the DB). If not, I would create one using Prisma's test utilities or an in-memory SQLite database if the project supports it.
- I would use `supertest` for HTTP-level integration tests if it is already a dependency. If not, I would add it (`npm install -D supertest @types/supertest`).
- Each test suite should clean up its data (delete created users) to avoid test pollution. I would use `beforeEach` or `afterEach` hooks for this.
- I would mock time-dependent behavior (token expiry) using Jest's timer mocks or by generating tokens with very short expiry in tests.

---

## Step 10: Verify Everything Works

**Actions (in sequence):**
1. Run `npx tsc --noEmit` to check for type errors.
2. Run `npx jest` (or whatever test command the project uses) to run all tests.
3. Fix any failures.
4. Manually trace through the flow one more time by reading the code to check for security issues: password never logged, tokens never logged, secrets not hardcoded, proper HTTP status codes, consistent error shapes.

---

## Summary of Files Created or Modified

**New files:**
- `prisma/migrations/<timestamp>_add_user_model/migration.sql` (generated by Prisma)
- `src/utils/auth.ts` -- token and password utilities
- `src/middleware/auth.ts` -- route protection middleware
- `src/routes/auth.ts` -- register, login, refresh, logout endpoints
- `src/types/express.d.ts` -- Request type augmentation (if not already handled)
- `src/utils/auth.test.ts` -- unit tests for auth utilities
- `src/routes/auth.test.ts` -- integration tests for auth endpoints

**Modified files:**
- `prisma/schema.prisma` -- added User model
- `src/app.ts` (or equivalent) -- registered auth routes, applied middleware
- `.env.example` -- documented new environment variables
- `.env` -- added actual secret values
- `package.json` / lock file -- new dependencies

---

## Key Considerations and Trade-offs

1. **Refresh token storage:** Storing a single refresh token per user means only one session at a time. For multi-device support, a `RefreshToken` table with device identifiers would be needed. I would flag this to the user but not over-engineer the initial implementation.

2. **Token rotation:** Implementing refresh token rotation (new refresh token on each refresh call) adds security but introduces complexity around race conditions if two refresh calls happen simultaneously. For a standard API this is acceptable.

3. **Password hashing cost:** bcrypt with 12 salt rounds balances security and performance. In tests, this can be slow -- I would consider using a lower cost factor (4) in the test environment via an environment variable, or mocking the hash function entirely in unit tests.

4. **No rate limiting:** The request did not ask for it, so I would not add it, but I would mention that login and register endpoints should have rate limiting in production.

5. **No email verification:** Not requested, not added. Worth mentioning as a follow-up.

6. **HTTPS assumption:** JWTs sent over HTTP are vulnerable to interception. I would note that HTTPS is assumed in production but would not add TLS configuration to the Express server (that is typically handled by a reverse proxy).
