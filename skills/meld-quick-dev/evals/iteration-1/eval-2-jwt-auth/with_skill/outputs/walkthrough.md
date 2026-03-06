# Quick-Dev Walkthrough: JWT Authentication for Express API

**User Request:** "Add user authentication with JWT tokens to this Express API. Need login/register endpoints, password hashing, token refresh, and middleware to protect existing routes. Using TypeScript, Prisma for DB, Jest for tests."

**Conditions:** No beads ticket. No tech spec file. No actual project to inspect (simulated).

---

## Phase 1: Setup & Mode Detection

### Capture Baseline Commit

Run `git rev-parse HEAD` and store the result as `baseline_commit`. Assume we get something like `a1b2c3d`.

### Load Project Context

Look for `project-context.md` in the project root. In this simulation, assume none exists. Note the absence and move on.

### Determine Execution Mode

**Mode B detected.** The user provided a direct feature description with no tech-spec path and no beads ticket. There is no `{ticket_id}` set, so `{beads_active}` is false. No ticket metadata to check for `spec_status == "ready-for-dev"`. This is ad-hoc, direct-instruction development.

### Escalation Evaluation (Mode B Only)

**REQUIRED:** Invoke `meld:meld-complexity-assessment` to evaluate complexity signals.

**Signal evaluation against the five complexity signals:**

1. **Multi-component:** YES. This touches auth middleware, route handlers (login, register, refresh), token utilities, password hashing utilities, and existing route files (to add middleware). That is at least 4-5 distinct components.

2. **System-level scope:** NO. This is a feature addition within an existing Express API. No architecture migration, no infrastructure changes. It extends the current system rather than restructuring it.

3. **Uncertainty:** NO. The user has specified the technology stack clearly (JWT, bcrypt/argon2, TypeScript, Prisma, Jest). The approach is well-understood and conventional.

4. **Multi-layer:** YES. This crosses backend logic (route handlers, middleware), database (Prisma schema for User model, migrations), and tests (Jest). No frontend mentioned, but three layers are involved.

5. **Extended timeframe:** NO. This is a single cohesive feature that can be implemented in one session. No phased delivery needed.

**Signal count: 2 (Multi-component + Multi-layer)**

**Complexity level: Moderate**

**Routing options presented to user:**
- **[P] Plan first** (Recommended) -- Run `meld:meld-quick-spec` to create a tech spec
- **[E] Execute directly** -- Proceed without a formal spec
- **[W] Full MELD flow** -- Start with analysis and planning phases

**My recommendation and reasoning:** I would recommend **[P] Plan first**. Two signals puts this at moderate complexity. The feature has enough moving parts (schema changes, middleware integration, token lifecycle, multiple endpoints) that a lightweight spec would catch sequencing issues and clarify acceptance criteria before implementation begins. However, this is a well-understood pattern, so full MELD would be overkill.

**Human gate: Wait for user to choose.**

**Simulated user response:** Assume the user picks **[E] Execute directly** -- they want to move fast and the pattern is familiar to them.

### Create Worktree (Optional)

Since `{beads_active}` is false, I would offer worktree creation: "Would you like me to create a git worktree for this work? Branch would be named something like `feature/jwt-auth`."

**Simulated user response:** Assume user declines. Note it and continue.

### Beads Sync

Skipped -- `{beads_active}` is false.

### Progress Tracking

Create 6 tasks via TaskCreate:

1. "Setup and detect mode" -- mark `completed` (just finished)
2. "Gather context and confirm plan" -- mark `in_progress` (entering Phase 2 since Mode B)
3. "Execute implementation" -- blocked by task 2
4. "Verify and self-check" -- blocked by task 3
5. "Adversarial review and resolve" -- blocked by task 4
6. "Write completion summary" -- blocked by task 5

---

## Phase 2: Context Gathering (Mode B)

This phase is NOT skipped because we are in Mode B. The user's request IS the only context we have.

### Identify Files to Modify

I would search the project to understand its structure:

- **Glob for project layout:** `**/*.ts` to see overall structure, `**/routes/**` or `**/src/**` for the Express app organization
- **Grep for Express setup:** Search for `express()` or `app.listen` to find the main entry point
- **Grep for existing middleware:** Search for `app.use` to understand how middleware is applied
- **Grep for Prisma schema:** Look at `prisma/schema.prisma` for existing models
- **Grep for existing tests:** Search for `.test.ts` or `.spec.ts` patterns to understand test conventions

**Simulated findings:**
- `src/app.ts` -- Express app setup
- `src/routes/` -- Existing route files (e.g., `src/routes/posts.ts`, `src/routes/users.ts`)
- `src/middleware/` -- May or may not exist yet
- `prisma/schema.prisma` -- Existing schema with some models
- `src/__tests__/` or `tests/` -- Jest test files
- `jest.config.ts` -- Jest configuration
- `tsconfig.json` -- TypeScript config
- `package.json` -- Dependencies (check for existing bcrypt, jsonwebtoken, etc.)

### Find Relevant Patterns

- **Code style:** Check if project uses classes or functional handlers, async/await vs callbacks
- **Import patterns:** ES modules (`import`) vs CommonJS (`require`) -- likely ES modules given TypeScript
- **Error handling:** Look for existing error handling middleware, custom error classes
- **Test patterns:** Supertest for HTTP testing? Test factories? In-memory DB or mocks for Prisma?
- **Database patterns:** How Prisma client is instantiated (singleton?), migration naming conventions

**Simulated patterns found:**
- Functional route handlers with `async/await`
- Centralized error handling middleware at `src/middleware/errorHandler.ts`
- Prisma client singleton at `src/lib/prisma.ts`
- Tests use supertest with a test app instance
- Prisma mocking via `jest.mock` or `prismock`

### Note Dependencies

**New packages needed (check `package.json` first):**
- `jsonwebtoken` + `@types/jsonwebtoken` -- JWT signing/verification
- `bcryptjs` + `@types/bcryptjs` -- Password hashing (or `bcrypt` if native bindings are acceptable)

**Internal modules to integrate with:**
- `src/lib/prisma.ts` -- Prisma client for User queries
- `src/routes/index.ts` or `src/app.ts` -- Route registration
- Existing route files -- Apply auth middleware

**Config updates:**
- `.env` -- Add `JWT_SECRET`, `JWT_REFRESH_SECRET`, `JWT_EXPIRY`, `JWT_REFRESH_EXPIRY`
- `prisma/schema.prisma` -- Add User model (if not present) with email, passwordHash, refreshToken fields

### Create Implementation Plan

**Ordered task list:**

1. **Add dependencies** -- Install `jsonwebtoken`, `@types/jsonwebtoken`, `bcryptjs`, `@types/bcryptjs`
2. **Update Prisma schema** -- Add `User` model with `id`, `email`, `passwordHash`, `refreshToken`, `createdAt`, `updatedAt`. Run `prisma migrate dev`.
3. **Create auth utilities** -- `src/lib/auth.ts` with functions: `hashPassword()`, `comparePassword()`, `generateAccessToken()`, `generateRefreshToken()`, `verifyAccessToken()`, `verifyRefreshToken()`
4. **Create auth middleware** -- `src/middleware/authenticate.ts` that extracts Bearer token from Authorization header, verifies it, attaches user to request, returns 401 on failure
5. **Create auth routes** -- `src/routes/auth.ts` with:
   - `POST /auth/register` -- validate input, hash password, create user, return tokens
   - `POST /auth/login` -- validate credentials, compare password, return tokens
   - `POST /auth/refresh` -- validate refresh token, issue new access token
6. **Register routes and apply middleware** -- Mount `/auth` routes, apply `authenticate` middleware to protected routes
7. **Write tests** -- Tests for each endpoint (happy path + error cases), middleware tests, utility tests

**Inferred Acceptance Criteria:**
- AC1: `POST /auth/register` creates a user with hashed password and returns access + refresh tokens
- AC2: `POST /auth/register` returns 400 for duplicate email
- AC3: `POST /auth/login` returns tokens for valid credentials
- AC4: `POST /auth/login` returns 401 for invalid credentials
- AC5: `POST /auth/refresh` returns new access token for valid refresh token
- AC6: `POST /auth/refresh` returns 401 for invalid/expired refresh token
- AC7: Protected routes return 401 without token, 401 with invalid token, and 200 with valid token
- AC8: Passwords are never stored in plain text
- AC9: All existing tests continue to pass

### Present Plan for Confirmation

I would present the full task list, file list, dependencies, and acceptance criteria to the user and ask: "Ready to execute? Adjust anything?"

**Human gate: Wait for user confirmation before proceeding.**

**Simulated user response:** "Looks good, go ahead."

Mark task 2 as `completed`. Mark task 3 as `in_progress`.

---

## Phase 3: Execute

### TDD Methodology

The project uses Jest for tests, so TDD applies. Follow Red-Green-Refactor for each task.

### Execution Loop

**Task 1: Add dependencies**

No TDD needed for package installation. Run:
```bash
npm install jsonwebtoken bcryptjs
npm install -D @types/jsonwebtoken @types/bcryptjs
```
Verify `package.json` updated. Continue immediately.

**Task 2: Update Prisma schema**

No TDD for schema changes. Add User model to `prisma/schema.prisma`:
```prisma
model User {
  id           String   @id @default(cuid())
  email        String   @unique
  passwordHash String
  refreshToken String?
  createdAt    DateTime @default(now())
  updatedAt    DateTime @updatedAt
}
```
Run `npx prisma migrate dev --name add-user-model`. Verify migration succeeds. Continue immediately.

**Task 3: Create auth utilities** (`src/lib/auth.ts`)

- **RED:** Write tests in `src/__tests__/lib/auth.test.ts`:
  - `hashPassword` returns a string different from input
  - `comparePassword` returns true for matching password
  - `comparePassword` returns false for wrong password
  - `generateAccessToken` returns a valid JWT string
  - `verifyAccessToken` decodes a valid token correctly
  - `verifyAccessToken` throws/returns null for expired token
  - Same for refresh token functions
  Run tests. Confirm they fail (module not found).

- **GREEN:** Implement `src/lib/auth.ts` with all six functions. Use `bcryptjs` for hashing (salt rounds 10), `jsonwebtoken` for token operations. Use environment variables for secrets and expiry. Run tests. Confirm all pass.

- **REFACTOR:** Extract constants (salt rounds, default expiry). Ensure consistent error handling. Tests still green.

**Task 4: Create auth middleware** (`src/middleware/authenticate.ts`)

- **RED:** Write tests in `src/__tests__/middleware/authenticate.test.ts`:
  - Returns 401 when no Authorization header
  - Returns 401 when token is malformed
  - Returns 401 when token is expired/invalid
  - Attaches `req.user` with decoded payload when token is valid
  - Calls `next()` on valid token
  Run tests. Confirm failure.

- **GREEN:** Implement middleware that extracts Bearer token, calls `verifyAccessToken`, attaches user to request or sends 401. Run tests. All pass.

- **REFACTOR:** Clean up types (extend Express Request interface with `user` property via declaration merging in `src/types/express.d.ts`). Tests still green.

**Task 5: Create auth routes** (`src/routes/auth.ts`)

- **RED:** Write integration tests in `src/__tests__/routes/auth.test.ts` using supertest:
  - Register: valid input returns 201 with tokens
  - Register: duplicate email returns 400
  - Register: missing fields returns 400
  - Login: valid credentials returns 200 with tokens
  - Login: wrong password returns 401
  - Login: non-existent user returns 401
  - Refresh: valid refresh token returns new access token
  - Refresh: invalid refresh token returns 401
  Run tests. Confirm failure.

- **GREEN:** Implement three route handlers. Input validation (check email format, password length). Hash password on register. Compare on login. Store refresh token in DB. Return `{ accessToken, refreshToken }` on success. Run tests. All pass.

- **REFACTOR:** Extract validation logic if needed. Ensure consistent error response format matching existing patterns. Tests still green.

**Task 6: Register routes and apply middleware**

- **RED:** Write test that existing protected route returns 401 without auth header (currently it would return 200). Run test. It fails because middleware isn't applied yet.

- **GREEN:** In `src/app.ts` or route registration file, mount `authRouter` at `/auth`. Apply `authenticate` middleware to existing routes that should be protected. Run tests. All pass (including the new test and all existing tests).

- **REFACTOR:** Verify route ordering is correct (auth routes before protected routes). Tests still green.

**Task 7: Write remaining tests**

Review test coverage. Fill gaps:
- Edge cases: very long passwords, email case sensitivity, expired tokens, malformed JSON body
- Verify password is never returned in any response
- Verify `passwordHash` is never in response bodies

Run full test suite. All pass.

### Halt Conditions

No halts expected in this simulation. The pattern is well-understood and the tasks are sequential but straightforward.

### Parallel Execution

Tasks 3 and 4 could potentially be parallelized (auth utilities and middleware are independent modules), but the middleware depends on `verifyAccessToken` from auth utilities, so they must be sequential. No parallel dispatch recommended here.

Mark task 3 as `completed`. Mark task 4 as `in_progress`.

---

## Phase 4: Verify & Self-Check

### Skip Conditions Check

Run `git diff --stat a1b2c3d`. This change would involve roughly:
- 8-12 new/modified files
- 300-500 lines of code

This exceeds the skip threshold (20 lines / 3 files), so full audit is required.

### Self-Audit Checklist

**Tasks:**
1. All 7 tasks marked complete -- YES
2. No tasks skipped -- YES, all implemented
3. Implementation matches task descriptions -- YES, no drift from the plan

**Tests:**
4. All existing tests still pass -- VERIFY by running `npm test` fresh
5. New tests written for new behavior -- YES: utility tests, middleware tests, route integration tests
6. Coverage covers happy path and error/edge cases -- YES: valid credentials, invalid credentials, missing fields, duplicate email, expired tokens, no auth header, malformed tokens

**Acceptance Criteria:**
7. Each AC satisfied:
   - AC1: Register creates user, returns tokens -- covered by test
   - AC2: Duplicate email returns 400 -- covered
   - AC3: Login returns tokens -- covered
   - AC4: Invalid credentials returns 401 -- covered
   - AC5: Refresh returns new access token -- covered
   - AC6: Invalid refresh token returns 401 -- covered
   - AC7: Protected routes enforce auth -- covered
   - AC8: Passwords never stored plain text -- hashing verified in test
   - AC9: Existing tests pass -- verified by full suite run
8. Edge cases from ACs handled -- YES

**Patterns:**
9. Code follows codebase conventions -- matched existing handler style, error handling, Prisma usage
10. No code smells -- no duplication, no god objects, middleware is focused

### Verification Gate

**REQUIRED:** Invoke `meld:meld-verification`. Run fresh:
- `npm test` -- all tests pass (e.g., 45 passing, 0 failing)
- `npx tsc --noEmit` -- no type errors
- Lint (if configured, e.g., `npm run lint`) -- no new warnings

Read complete output. Match evidence to every audit claim.

**Simulated result:** All checks pass. 12 new tests, 45 total passing.

### Present Summary

- Tasks completed: 7/7
- Tests: 12 new, 45 total passing
- Files created: `src/lib/auth.ts`, `src/middleware/authenticate.ts`, `src/routes/auth.ts`, `src/types/express.d.ts`, `prisma/migrations/xxxx_add_user_model/migration.sql`, test files (3)
- Files modified: `prisma/schema.prisma`, `src/app.ts`, `package.json`, `package-lock.json`
- Checklist: 10/10 passing

Mark task 4 as `completed`. Mark task 5 as `in_progress`.

---

## Phase 5: Adversarial Review & Resolution

### Construct Diff

Run `git diff a1b2c3d` to capture the complete diff including all new files.

### Invoke Review

**REQUIRED:** Use `meld:meld-adversarial-review`. Spawn a subagent via the Task tool. The subagent receives ONLY:
1. The raw diff
2. The adversarial reviewer prompt from the skill

The subagent does NOT see the user's original request, the implementation plan, the acceptance criteria, or this conversation. This information asymmetry is intentional -- it catches issues the implementing agent is blind to because of context bias.

### Simulated Review Findings

The adversarial reviewer, seeing only the diff, would likely surface these findings:

**F1 (High Severity): JWT secret hardcoded fallback**
If the code has a pattern like `process.env.JWT_SECRET || 'default-secret'`, the reviewer would flag that the fallback means the app runs with a known secret if the env var is missing. Should throw on startup if secrets are not configured.

**F2 (Medium Severity): No rate limiting on auth endpoints**
Login and register endpoints have no rate limiting, making them vulnerable to brute-force and credential-stuffing attacks. The reviewer would note this as a security concern.

**F3 (Medium Severity): Refresh token not invalidated on login**
If a user logs in again, the old refresh token may still be valid. Should invalidate previous refresh tokens when issuing new ones (already handled if storing single refresh token in DB and overwriting).

**F4 (Low Severity): Missing input sanitization**
Email input might not be normalized (lowercase, trimmed) before storage and lookup, which could lead to duplicate accounts with different casing.

**F5 (Low Severity): No logout endpoint**
The diff adds login, register, and refresh but no logout. While not requested, the reviewer might flag this as an incomplete auth lifecycle.

### Process and Present Findings

| # | Severity | Finding | Validity |
|---|----------|---------|----------|
| F1 | High | JWT secret fallback allows insecure startup | Real |
| F2 | Medium | No rate limiting on auth endpoints | Real (but out of scope) |
| F3 | Medium | Refresh token invalidation unclear | Undecided -- need to check implementation |
| F4 | Low | Email not normalized | Real |
| F5 | Low | No logout endpoint | Noise -- not in requirements |

### Human Gate

Present options:
- **[W] Walk through** -- Iterate each finding: Fix / Skip / Discuss
- **[F] Fix automatically** -- Fix all "Real" findings, skip Noise/Undecided
- **[S] Skip** -- Acknowledge and proceed

**Simulated user response:** "[F] Fix automatically"

### Apply Resolution

Filter to "Real" findings only: F1, F2, F4 (F5 is Noise, F3 is Undecided so skipped).

**F1 fix:** Change auth utility to throw an error at startup if `JWT_SECRET` or `JWT_REFRESH_SECRET` is not set. Remove any fallback values. Add a startup check.

**F2 fix:** This is real but arguably out of scope (user didn't ask for rate limiting). Since the user chose "Fix automatically" and it was marked Real, I would add a note but defer -- rate limiting is a separate concern that should be its own task. Mark as "acknowledged, deferred."

**F4 fix:** Add `.toLowerCase().trim()` to email before storage (register) and lookup (login). Update tests to verify case-insensitive email matching.

Re-run full test suite after fixes. All pass.

**Result:** 2 findings fixed (F1, F4), 1 deferred (F2), 1 undecided/skipped (F3), 1 noise/skipped (F5).

### Final Verification

**REQUIRED:** Run `meld:meld-verification` one final time. Full test suite, type check, lint. All pass. No regressions from finding fixes.

### Worktree Completion

No worktree was created, so this section is skipped.

Mark task 5 as `completed`. Mark task 6 as `in_progress`.

### Completion Summary

**Files created:**
- `src/lib/auth.ts` -- Password hashing and JWT token utilities
- `src/middleware/authenticate.ts` -- Bearer token verification middleware
- `src/routes/auth.ts` -- Login, register, and refresh endpoints
- `src/types/express.d.ts` -- Request type augmentation for user property
- `prisma/migrations/xxxx_add_user_model/migration.sql` -- User table migration
- `src/__tests__/lib/auth.test.ts` -- Auth utility tests
- `src/__tests__/middleware/authenticate.test.ts` -- Middleware tests
- `src/__tests__/routes/auth.test.ts` -- Route integration tests

**Files modified:**
- `prisma/schema.prisma` -- Added User model
- `src/app.ts` -- Mounted auth routes, applied middleware to protected routes
- `package.json` -- Added jsonwebtoken, bcryptjs dependencies

**Tests:** 12 new, 45 total passing, 0 failing
**Review:** 5 findings total -- 2 fixed, 1 deferred, 2 skipped
**Status:** Complete

Suggest: commit changes, add rate limiting as a follow-up task, consider adding logout endpoint if needed.

Mark task 6 as `completed`.

---

## Key Decisions Summary

| Decision Point | Choice | Reasoning |
|---------------|--------|-----------|
| Mode detection | Mode B (direct instructions) | No tech spec, no beads ticket |
| Complexity assessment | Moderate (2/5 signals) | Multi-component + Multi-layer |
| Recommended routing | [P] Plan first | Moderate complexity benefits from a spec |
| Simulated user choice | [E] Execute directly | User wants to move fast |
| Worktree | Declined | User preference |
| TDD | Applied | Jest is configured in the project |
| Parallel agents | Not used | Tasks have sequential dependencies |
| Adversarial review resolution | Fix automatically | User chose [F] |
| Beads sync | Skipped throughout | No ticket, beads not active |
