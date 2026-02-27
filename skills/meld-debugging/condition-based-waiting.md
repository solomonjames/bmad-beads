# Condition-Based Waiting

Replace arbitrary timeouts and delays with condition polling. Sleeps mask bugs — condition-based waiting reveals them.

## The Problem with Sleeps

```typescript
// BAD: arbitrary delay
await sleep(2000);
const result = await getResult();
```

Why this fails:
- Too short on slow machines → flaky test
- Too long on fast machines → slow test suite
- Masks the real issue: why isn't the result ready?

## The Pattern

```typescript
// GOOD: wait for the actual condition
async function waitFor(
  condition: () => Promise<boolean>,
  options: { timeout?: number; interval?: number; message?: string } = {}
) {
  const { timeout = 10000, interval = 100, message = 'Condition not met' } = options;
  const start = Date.now();

  while (Date.now() - start < timeout) {
    if (await condition()) return;
    await new Promise(r => setTimeout(r, interval));
  }

  throw new Error(`Timeout after ${timeout}ms: ${message}`);
}
```

## Usage Examples

### Waiting for a DOM element

```typescript
// BAD
await sleep(1000);
const button = document.querySelector('#submit');

// GOOD
await waitFor(
  () => document.querySelector('#submit') !== null,
  { message: 'Submit button to appear' }
);
const button = document.querySelector('#submit');
```

### Waiting for an API response

```typescript
// BAD
await triggerJob();
await sleep(5000);
const status = await getJobStatus();

// GOOD
await triggerJob();
await waitFor(
  async () => (await getJobStatus()).state === 'complete',
  { timeout: 30000, message: 'Job to complete' }
);
```

### Waiting for a file

```typescript
// BAD
await generateReport();
await sleep(3000);
const report = await readFile('report.pdf');

// GOOD
await generateReport();
await waitFor(
  async () => existsSync('report.pdf'),
  { message: 'Report file to be generated' }
);
const report = await readFile('report.pdf');
```

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| `sleep(N)` instead of polling | Flaky, slow, masks bugs | Use `waitFor` with condition |
| No timeout on polling | Hangs forever on failure | Always set a timeout |
| Polling too fast | CPU spin, resource waste | Use reasonable interval (100-500ms) |
| Polling too slow | Adds unnecessary latency | Match interval to expected response time |
| Catching timeout silently | Hides the real failure | Let timeout errors propagate |

## When Sleeps Are Acceptable

Rare cases where a fixed delay is correct:
- Rate limiting (intentional throttle between API calls)
- Animation timing (CSS transitions with known duration)
- Hardware debounce (physical device response time)

Even in these cases, prefer condition-based waiting if a completion signal exists.
