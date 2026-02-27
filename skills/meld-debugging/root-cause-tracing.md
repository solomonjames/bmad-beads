# Root Cause Tracing

A systematic technique for finding the source of a bug by tracing backward from the symptom.

## The Process

### 1. Start at the Symptom

The symptom is what you can observe:
- An error message
- Wrong output
- A crash
- Unexpected behavior

Write it down exactly. Don't interpret it yet.

### 2. Identify the Immediate Cause

Find the line of code that produces the wrong result:
- Which function throws the error?
- Which variable has the wrong value?
- Which condition evaluates incorrectly?

### 3. Trace Up

Ask: "Why does this line produce the wrong result?"

The answer leads you one level up:
- What called this function?
- What arguments were passed?
- Where did those arguments come from?
- What was the application state at that point?

### 4. Keep Tracing

Repeat step 3 until you find where correct data becomes incorrect:

```
Symptom: "Cannot read property 'name' of undefined"
  → user object is undefined
    → getUserById returned undefined
      → database query returned no rows
        → user ID passed was "null" (string)
          → form submitted before validation completed
            → ROOT CAUSE: submit handler doesn't await validation
```

### 5. Verify the Root Cause

Your root cause should satisfy:
- Explains ALL observed symptoms
- Changing it would prevent the symptom
- It's the earliest point where things go wrong

## Stack Trace Instrumentation

When tracing isn't enough, add targeted instrumentation:

```javascript
// Add at suspected boundary points
console.log('[TRACE] functionName called with:', JSON.stringify(args));
console.log('[TRACE] functionName returning:', JSON.stringify(result));
```

Rules:
- Add instrumentation at boundary points, not everywhere
- Log inputs AND outputs of suspected functions
- Include enough context to identify the call (function name, key args)
- Remove all instrumentation after debugging

## Common Tracing Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Starting at the wrong symptom | Chase the wrong chain | Verify the symptom is the actual failure point |
| Stopping too early | Fix symptom, not cause | Keep asking "why?" until you reach the source |
| Assuming instead of checking | Miss the actual cause | Read the actual values, don't assume |
| Tracing forward instead of backward | Combinatorial explosion | Always start at the symptom, trace backward |
