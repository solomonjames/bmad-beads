# Walkthrough: Implementing CSV Export Feature

## Initial Assessment

Upon receiving this tech spec, I would first orient myself in the codebase before writing any code. The spec references `src/utils/csv-export.ts` and `src/components/ReportsPage.tsx`, which tells me this is a TypeScript/React project. My first moves would be exploratory.

## Step 1: Understand the Existing Codebase

**Actions I would take:**

- Use `Glob` to scan `src/components/` for `ReportsPage.tsx` and any related report components to understand the existing structure.
- Use `Glob` to scan `src/utils/` to see what utilities already exist and follow their patterns.
- Use `Read` on `ReportsPage.tsx` to understand the component's current structure: what props it receives, how it renders report data, what state management it uses, and what the "columns" and "rows" data shapes look like.
- Use `Read` on `package.json` and `tsconfig.json` to understand dependencies, module resolution, and whether there are any existing CSV or file-download libraries already in the project.
- Use `Grep` to search for any existing export or download functionality in the codebase that I could follow as a pattern.
- Use `Grep` to search for test files (e.g., `*.test.ts`, `*.spec.ts`) to understand the project's testing conventions (test runner, assertion library, file naming, directory structure).

**Decisions at this stage:**

- If a library like `file-saver` or `papaparse` is already a dependency, I would use it rather than writing CSV generation from scratch.
- If no such library exists, I would implement CSV generation manually since it is straightforward and avoids adding a dependency for a simple feature.
- I would note the data shape of report rows and columns so the utility function signature matches reality.

## Step 2: Create the CSV Export Utility (`src/utils/csv-export.ts`)

**What I would build:**

An `exportToCsv` function that takes `data` (array of row objects) and `columns` (array of column definitions) and triggers a browser file download.

**Key decisions:**

- **Function signature:** I would look at how `ReportsPage.tsx` structures its data. Likely `columns` is an array of objects with at least `key` (accessor) and `header` (display name) fields. I would match whatever shape already exists rather than inventing a new one.
- **Date formatting:** The spec requires YYYY-MM-DD formatting. I would detect Date objects or ISO date strings and format them accordingly. I would write a helper like `formatCellValue(value, columnType?)` to handle this.
- **CSV escaping:** Values containing commas, double quotes, or newlines must be wrapped in double quotes, with internal double quotes escaped by doubling them. This is standard RFC 4180 behavior.
- **Empty report handling:** If `data` is an empty array, the function should still produce a CSV string with the header row derived from `columns`.
- **Download mechanism:** I would use `Blob` + `URL.createObjectURL` + a dynamically created `<a>` element with `download` attribute, then programmatically click it. This is the standard browser-side download pattern and avoids needing `file-saver`.
- **Separation of concerns:** I would likely split this into two functions: a pure `generateCsvString(data, columns)` function (easy to test) and a `downloadCsv(csvString, filename)` function that handles the browser download mechanics. The exported `exportToCsv` would compose both.

**Structure of the file:**

```
formatCellValue(value) - handles date formatting, escaping
generateCsvString(data, columns) - pure function, returns string
downloadCsv(content, filename) - browser download trigger
exportToCsv(data, columns, filename?) - public API composing the above
```

## Step 3: Add the Export Button to `ReportsPage.tsx`

**Actions I would take:**

- Read `ReportsPage.tsx` carefully to find the right insertion point for the button -- likely in a toolbar/header area above the report table.
- Look at existing buttons in the component (or elsewhere in the codebase) to match the styling pattern (CSS classes, component library like MUI/Chakra/custom, etc.).
- Use `Edit` to add the button, keeping changes minimal and focused.

**Key decisions:**

- **Button placement:** I would look for an existing toolbar, action bar, or header section. If the page has a pattern like `<div className="actions">`, I would place the button there.
- **Button component:** If the project uses a component library, I would use its Button component. If it uses custom components, I would follow that pattern.
- **Passing data to the export function:** The button's onClick handler needs access to the currently visible report data and column definitions. I would check whether these are in component state, props, or a store (Redux, Zustand, context). The handler would call `exportToCsv(visibleData, columns)`.
- **"Visible" data:** The spec says "all visible report rows." If the report has filtering or pagination, I need to pass the filtered/paginated data, not the raw data. I would check how the component manages this and use the appropriate data source.

## Step 4: Wire the Button Click

This is largely done as part of Step 3 -- the onClick handler calls `exportToCsv`. But I would verify:

- Import `exportToCsv` from `../utils/csv-export`.
- The handler passes the correct data shape.
- A reasonable default filename is provided (e.g., `report-export-2026-03-05.csv` using the current date).

## Step 5: Write Unit Tests for `csv-export.ts`

**Actions I would take:**

- Check the existing test setup: look at `jest.config.*`, `vitest.config.*`, or `package.json` test scripts to know which test runner is used.
- Look at an existing test file for naming and structure conventions.
- Create `src/utils/csv-export.test.ts` (or `.spec.ts`, matching project convention).

**Test cases I would write:**

1. **Basic export:** Given an array of data with simple string/number values, verify the CSV string has correct headers and rows.
2. **Date formatting:** Given data containing Date objects or ISO date strings, verify they appear as YYYY-MM-DD in the output.
3. **Empty data:** Given an empty array, verify the output contains only the header row.
4. **CSV escaping:** Given values with commas, double quotes, and newlines, verify proper escaping.
5. **Column ordering:** Verify the CSV columns appear in the order specified by the `columns` parameter, not arbitrary object key order.

**Decision:** I would test `generateCsvString` directly (the pure function) rather than `exportToCsv`, since the latter involves browser APIs (`Blob`, `URL.createObjectURL`) that would need mocking. This keeps tests focused and reliable.

## Step 6: Write Integration Test for the Export Button

**Actions I would take:**

- Determine the integration testing setup: look for React Testing Library, Cypress, or Playwright configurations.
- If React Testing Library is used, create a test in the component's test file (or a new one alongside `ReportsPage.tsx`).

**Test cases I would write:**

1. **Button renders:** Verify the "Export CSV" button appears on the reports page.
2. **Click triggers download:** Mock `URL.createObjectURL` and verify that clicking the button creates a Blob with the expected CSV content. Alternatively, spy on the `exportToCsv` function and verify it is called with the correct data.
3. **Empty state:** Render the page with no data, click export, verify the download still triggers with a headers-only CSV.

**Key decisions:**

- I would need to mock the data source for the reports page (API call, store, etc.). I would follow whatever mocking pattern exists in the codebase.
- For the download verification, I would likely mock `URL.createObjectURL` and `document.createElement('a')` to capture the download without actually triggering browser behavior. Or if there is an existing pattern for testing downloads in the project, I would follow that.

## Step 7: Verify and Clean Up

**Final verification steps:**

- Run the full test suite to make sure nothing is broken.
- Run the linter/formatter (check `package.json` scripts for `lint`, `format`, or `prettier` commands) and fix any issues.
- Run TypeScript compilation (`tsc --noEmit`) to verify no type errors.
- Re-read the acceptance criteria one more time against my implementation:
  - Clicking Export CSV downloads a CSV with all visible rows -- confirmed via integration test.
  - Date columns formatted as YYYY-MM-DD -- confirmed via unit test.
  - Empty report produces headers-only CSV -- confirmed via both unit and integration tests.

## Files I Would Create or Modify

| File | Action |
|------|--------|
| `src/utils/csv-export.ts` | **Create** -- new utility with `exportToCsv`, `generateCsvString`, `formatCellValue` |
| `src/components/ReportsPage.tsx` | **Edit** -- add import and Export CSV button with onClick handler |
| `src/utils/csv-export.test.ts` | **Create** -- unit tests for CSV generation logic |
| `src/components/ReportsPage.test.tsx` (or similar) | **Edit or Create** -- integration test for the export button |

## Risks and Considerations

- **Large datasets:** If reports can have thousands of rows, generating the CSV string synchronously could block the UI. For a first implementation I would keep it synchronous, but I would note this as a potential follow-up if performance is a concern.
- **Unicode/special characters:** CSV files should include a BOM (`\uFEFF`) prefix if users might open them in Excel with non-ASCII characters. I would check if the reports contain internationalized data and add the BOM if so.
- **Column types beyond dates:** The spec only mentions date formatting, but if there are currency or percentage columns, those might need formatting too. I would handle dates as specified and leave other types as-is unless the data exploration reveals a need.
- **Filename collisions:** If a user exports multiple times, the browser handles duplicate filenames. No special handling needed.
