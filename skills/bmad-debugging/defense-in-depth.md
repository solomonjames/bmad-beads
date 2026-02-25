# Defense in Depth

A 4-layer validation pattern that prevents bugs from propagating through the system.

## The 4 Layers

### Layer 1: Entry Point Validation

Validate at system boundaries — where external data enters your code.

```typescript
// API route handler
function createUser(req: Request) {
  // Validate here — before anything else touches this data
  if (!req.body.email || !isValidEmail(req.body.email)) {
    throw new ValidationError('Valid email required');
  }
  if (!req.body.name || req.body.name.trim().length === 0) {
    throw new ValidationError('Name required');
  }
  // Now pass validated data to business logic
  return userService.create(req.body);
}
```

Entry points include:
- API route handlers
- CLI argument parsing
- Form submission handlers
- File/stream readers
- Message queue consumers

### Layer 2: Business Logic Validation

Validate invariants within your domain logic.

```typescript
class UserService {
  create(data: CreateUserInput) {
    // Business rules that go beyond "is this a valid string"
    if (await this.emailExists(data.email)) {
      throw new ConflictError('Email already registered');
    }
    if (data.role === 'admin' && !data.approvedBy) {
      throw new AuthorizationError('Admin accounts require approval');
    }
    return this.repo.insert(data);
  }
}
```

Business logic validates:
- Domain rules and constraints
- Authorization checks
- State transitions
- Cross-field dependencies

### Layer 3: Environment Guards

Verify the execution environment is correct.

```typescript
function connectDatabase() {
  if (!process.env.DATABASE_URL) {
    throw new ConfigError('DATABASE_URL not set');
  }
  // Guard against wrong environment
  if (process.env.NODE_ENV === 'production' && process.env.DATABASE_URL.includes('localhost')) {
    throw new ConfigError('Production must not use localhost database');
  }
}
```

Environment guards check:
- Required config is present
- Services are reachable
- File system permissions
- Resource availability

### Layer 4: Debug Instrumentation

Temporary validation during development that catches unexpected states.

```typescript
function processOrder(order: Order) {
  // Assert invariants that "should never happen"
  console.assert(order.items.length > 0, 'Order has no items');
  console.assert(order.total >= 0, 'Negative order total');

  // ... process the order
}
```

Use during debugging to:
- Verify assumptions about data shape
- Catch impossible states early
- Validate function contracts
- Remove after the bug is fixed

## Applying to Debugging

When investigating a bug, check which layer is missing:

1. **No entry validation?** → External data flows in unchecked
2. **No business validation?** → Invalid state is created silently
3. **No environment guards?** → Config/service issues surface as data bugs
4. **No assertions?** → "Impossible" state goes undetected

Add the missing layer as part of your fix — not just the patch for the specific bug.
