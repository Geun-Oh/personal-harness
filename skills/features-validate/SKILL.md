---
description: "Features.json Validator — Validates that feature definitions in features.json satisfy AI-DLC Phase 1 criteria (specificity, independence, verifiability, testability). Triggers on 'features validate', 'feature validation', 'feature definition check'."
---

# Features.json Validator

The core of AI-DLC Phase 1 (Requirements): validates that features.json entries satisfy "good feature definition" criteria.

## Validation Criteria

Each feature entry is checked against 4 quality criteria:

### 1. Specificity
- Does it include concrete, verifiable steps?
- BAD: "Implement login"
- GOOD: "Email/password-based login, JWT issuance, session cookie setup"

### 2. Independence
- Can it be implemented and tested in isolation without depending on other features?
- If a dependencies field is present, verify there are no circular dependencies

### 3. Verifiability
- Does the steps field list concrete, verifiable steps?
- Clear pass/fail conditions rather than vague criteria like "should work correctly"

### 4. Testability
- Does the tests field specify concrete test file paths?
- An empty tests field is treated as a failure

## Expected features.json Structure

```json
{
  "features": [
    {
      "id": "auth-login",
      "name": "Email/Password Login",
      "description": "Login with email and password to receive a JWT",
      "steps": [
        "Send email/password to POST /api/auth/login",
        "Return JWT token for valid credentials",
        "Set session token in response cookie",
        "Return 401 for invalid credentials"
      ],
      "tests": [
        "tests/auth/login.test.ts"
      ],
      "dependencies": [],
      "passes": false
    }
  ]
}
```

## How to Run

1. Read features.json from the project root
2. Check each feature entry against the 4 criteria
3. Report results per entry

## Output Format

```
## Features.json Validation Results

### auth-login: Email/Password Login
- [PASS] Specificity: 4 verification steps included
- [PASS] Independence: no external dependencies
- [PASS] Verifiability: all steps are verifiable
- [PASS] Testability: tests/auth/login.test.ts path specified

### Overall Summary
N of M features passed, K need improvement
Items needing improvement: ...
```

## Notes
- If features.json is absent, template creation is suggested
- The passes field is the only field the agent is allowed to modify
- JSON structural integrity is also checked
