# Adversarial Reviewer Raw Findings

Reviewer operated with NO context about the feature, spec, or conversation history. Only the diff was provided.

---

F1 [Critical] -- SQL Injection via string interpolation in all queries
All four SQL queries use template literal string interpolation (`'${email}'`, `'${name}'`, `${id}`, `'%${q}%'`) to embed user-supplied values directly into SQL strings. This is textbook SQL injection. An attacker can inject arbitrary SQL via the email, name, id, role, or search query parameters. Parameterized queries ($1, $2, etc.) must be used instead.
Location: src/api/users.ts lines ~21-22 (SELECT), ~30-31 (INSERT), ~39 (DELETE), ~50 (search SELECT)

F2 [Critical] -- Mass assignment / privilege escalation via role parameter
The POST /users endpoint destructures `role` from `req.body` and inserts it directly into the database. Any user can set their own role (e.g., "admin") by including it in the request body. There is no validation or authorization check on the role value.
Location: src/api/users.ts line ~18, ~31

F3 [High] -- No input validation on any endpoint
None of the endpoints validate that required fields are present or well-formed. POST /users does not check that name, email, or password exist before using them. The search endpoint does not check that `q` exists (could be undefined, producing the string "undefined" in the SQL). The DELETE endpoint does not validate that id is numeric.
Location: src/api/users.ts lines ~18, ~38, ~49

F4 [High] -- No error handling / missing try-catch
All async route handlers lack try-catch blocks. If any `db.query` call throws, the error propagates to Express's default error handler, likely returning a 500 with a stack trace. This leaks internal information and provides no structured error response.
Location: src/api/users.ts all route handlers

F5 [High] -- Unhandled promise rejection from sendWelcomeEmail
`sendWelcomeEmail(email, name)` is called without await and without `.catch()`. If this function returns a promise that rejects, it will cause an unhandled promise rejection, potentially crashing the Node.js process.
Location: src/api/users.ts line ~35

F6 [High] -- DELETE endpoint missing authorization
The DELETE /users/:id endpoint has no authentication or authorization check. Any unauthenticated caller can delete any user by ID.
Location: src/api/users.ts lines ~37-45

F7 [High] -- Search endpoint route ordering issue
`/users/search` is defined AFTER `/users/:id`. Express will match `/users/search` against the `/users/:id` route first (treating "search" as an id parameter). The search route will never be reached.
Location: src/api/users.ts line ~48 (defined after :id route at line ~14)

F8 [Medium] -- Tests lack coverage for critical paths
DELETE tests are empty (just a TODO comment). There are no tests for the search endpoint. There are no tests for error cases (missing fields, SQL injection attempts, invalid input). The two existing tests only cover the happy path and duplicate email case.
Location: src/api/__tests__/users.test.ts lines ~25-27

F9 [Medium] -- No rate limiting on user creation
The POST /users endpoint has no rate limiting. An attacker could create unlimited accounts.
Location: src/api/users.ts POST route

F10 [Low] -- Weak test password
Test uses "pass123" as the password value, which is fine for testing but there is no indication that password strength validation exists in the actual code path either.
Location: src/api/__tests__/users.test.ts line ~10
