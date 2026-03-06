# Walkthrough: Adding a `slugify` Utility Function

## Step 1: Understand the Request

The user wants a `slugify` utility function added to `src/utils/`. They have specified:
- Language: TypeScript
- Test framework: Jest
- An existing file `src/utils/string-helpers.ts` with similar utilities

Key decision point: Should I add `slugify` to the existing `string-helpers.ts` file or create a new file? The user said "similar utilities" already live in `string-helpers.ts`, so the most natural choice is to add `slugify` there rather than creating a separate file. This avoids unnecessary file proliferation and keeps related string utilities co-located. However, if the user explicitly said `src/utils/slugify.ts`, I would respect that. The request says "Add a slugify utility function to `src/utils/`" which is ambiguous -- it could mean the directory or a new file. I would start by reading the existing file to make a judgment call.

## Step 2: Read the Existing File

I would use the `Read` tool to open `src/utils/string-helpers.ts` and examine:

- What other functions exist (e.g., `capitalize`, `camelCase`, `truncate`)
- The coding style and conventions (named exports vs default, arrow functions vs function declarations, JSDoc comments or not)
- Whether there are any shared internal helpers I could reuse
- How the module exports are structured

This tells me how to write `slugify` so it fits in seamlessly.

## Step 3: Check for Existing Tests

I would use `Glob` to search for test files related to string helpers:

- `src/utils/string-helpers.test.ts`
- `src/utils/__tests__/string-helpers.test.ts`
- `tests/utils/string-helpers.test.ts`

Whichever pattern exists tells me where to put the new tests and what test style the project uses. I would then `Read` the test file to understand:

- Whether they use `describe`/`it` or `describe`/`test`
- Import style
- How edge cases are structured
- Any shared test utilities or fixtures

## Step 4: Check for an Index/Barrel File

I would look for `src/utils/index.ts` to see if utilities are re-exported from a barrel file. If so, I need to make sure `slugify` is exported from there too (or confirm it is already re-exported via wildcard from `string-helpers`).

## Step 5: Design the `slugify` Function

A standard `slugify` function converts a string to a URL-safe slug. The logic I would implement:

1. Convert to lowercase
2. Replace accented/diacritical characters with ASCII equivalents (e.g., using `normalize('NFD')` and stripping combining marks)
3. Replace non-alphanumeric characters (spaces, punctuation, etc.) with hyphens
4. Collapse consecutive hyphens into a single hyphen
5. Trim leading/trailing hyphens

The function signature would be something like:

```typescript
export function slugify(input: string): string
```

I would match the style of the existing functions in the file -- if they use arrow functions with `export const`, I would do the same. If they use JSDoc, I would add JSDoc.

## Step 6: Write the Implementation

I would use the `Edit` tool to add the `slugify` function to `src/utils/string-helpers.ts`, placing it in a logical position (alphabetically or grouped with related functions). The implementation would look roughly like:

```typescript
export function slugify(input: string): string {
  return input
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/[\s_]+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-+|-+$/g, '');
}
```

## Step 7: Write the Tests

I would use the `Edit` tool to add test cases to the existing test file. The test suite would cover:

- **Basic conversion:** `"Hello World"` becomes `"hello-world"`
- **Special characters:** `"Hello, World!"` becomes `"hello-world"`
- **Accented characters:** `"Cafe Resume"` with accents becomes `"cafe-resume"`
- **Multiple spaces/hyphens:** `"hello   world"` becomes `"hello-world"`, `"hello---world"` becomes `"hello-world"`
- **Leading/trailing whitespace and hyphens:** `"  hello world  "` becomes `"hello-world"`
- **Already slugified input:** `"hello-world"` remains `"hello-world"`
- **Empty string:** `""` returns `""`
- **Numbers:** `"Article 42 Part 3"` becomes `"article-42-part-3"`
- **Underscores:** `"hello_world"` becomes `"hello-world"`
- **All-special-character input:** `"!!!"` returns `""`

I would group these under a `describe('slugify', () => { ... })` block.

## Step 8: Update Barrel Export (If Needed)

If `src/utils/index.ts` exists and manually lists exports, I would add `slugify` to it. If it uses a wildcard re-export like `export * from './string-helpers'`, no change is needed.

## Step 9: Run the Tests

I would run `npx jest src/utils/string-helpers` (or whatever the appropriate test command is based on the project's `package.json` scripts) to verify:

- All new tests pass
- No existing tests broke

If any tests fail, I would read the output, diagnose the issue, fix the implementation or test, and re-run.

## Step 10: Final Verification

I would do a quick review:
- Re-read the modified `string-helpers.ts` to confirm the function is correct and stylistically consistent
- Re-read the test file to confirm coverage is adequate
- Run the full test suite if it is fast, to check for any regressions

## Decisions and Trade-offs

1. **Add to existing file vs. new file:** I would add to `string-helpers.ts` because the user said it contains "similar utilities." Creating a separate `slugify.ts` for a single function would be over-modularization. If the existing file were already very large (500+ lines), I might reconsider.

2. **Third-party library vs. hand-rolled:** For a simple `slugify`, a hand-rolled implementation is fine. A library like `slugify` or `url-slug` adds a dependency for a straightforward operation. I would only suggest a library if the user needed advanced transliteration (e.g., Chinese characters to pinyin). I would note this trade-off if the implementation seemed insufficient.

3. **Unicode handling depth:** The `normalize('NFD')` plus stripping combining marks approach handles common Latin accented characters well. It does not handle CJK, Cyrillic transliteration, or other complex scripts. This is the standard pragmatic choice for a utility named `slugify` unless the user specifies broader requirements.

4. **Options parameter:** A more advanced `slugify` might accept options like a custom separator or max length. I would keep it simple for the initial implementation and mention that it could be extended if needed, but would not over-engineer it.

## Summary

The total changes would touch 2-3 files:
- `src/utils/string-helpers.ts` -- add the `slugify` function
- The corresponding test file -- add a `describe('slugify')` block with ~10 test cases
- Possibly `src/utils/index.ts` -- add the export if needed
