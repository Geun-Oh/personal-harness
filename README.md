# personal-harness

Harness Engineering toolkit for Claude Code — 7 tools based on [AI-DLC patterns](https://github.com/Geun-Oh/personal-harness).

> "The bottleneck has moved from writing code to reviewing code, and now to architecture and harness design." — Harness Engineering & AI-DLC

## Installation

```bash
# Register marketplace (one-time)
/plugin marketplace add Geun-Oh/personal-harness

# Install
/plugin install personal-harness@personal-harness
```

For local development:
```bash
claude --plugin-dir ./personal-harness
```

## Quick Start: From Idea to Production

### Step 1 — Define Requirements

Turn your idea into a structured `features.json`. This replaces vague specs with a machine-verifiable checklist.

```bash
# Create project
mkdir my-project && cd my-project && git init

# Create features.json (write it yourself or ask the agent to draft it)
cat > features.json << 'EOF'
{
  "features": [
    {
      "id": "auth-login",
      "name": "Email/Password Login",
      "description": "Login with email and password to receive a JWT",
      "steps": [
        "POST /api/auth/login accepts email and password",
        "Returns JWT token for valid credentials",
        "Sets session token in response cookie",
        "Returns 401 for invalid credentials"
      ],
      "tests": ["tests/auth/login.test.ts"],
      "dependencies": [],
      "passes": false
    }
  ]
}
EOF

# Validate feature definitions against 4 quality criteria
/personal-harness:features-validate
```

Each feature must be **specific** (concrete steps), **independent** (no circular deps), **verifiable** (pass/fail conditions), and **testable** (test file paths). The agent can only modify the `passes` field — everything else is human-defined.

### Step 2 — Set Up the Harness

Build the environment so agents can work reliably.

```bash
# Create CLAUDE.md (~100 lines, acts as an index)
# Include: build/test commands, key rules, pointers to deeper docs

# Verify document hierarchy (L0-L3)
/personal-harness:pyramid-lint

# Diagnose current maturity level and get action items
/personal-harness:harness-assess
```

Minimum goal for **L1 (Basic Harness)**:
- `CLAUDE.md` exists with build/test commands
- Linter configured (eslint, ruff, golangci-lint, etc.)
- Test framework set up
- `.gitignore` properly configured

### Step 3 — Build Features

Implement features from `features.json` one by one. Hooks run automatically — no manual intervention needed.

```bash
# Ask the agent to implement a feature
"Implement the auth-login feature from features.json"

# What happens automatically during coding:
# L1 Hook → syntax/secrets check on every file edit (blocks on CRITICAL)
# L2 Hook → linter/structure check at turn end (blocks on lint failure)
# L3 Hook → test execution at turn end (blocks on test failure)
# Budget Hook → context window obesity warning at turn end

# When done, the agent sets passes: true in features.json
```

### Step 4 — Verify Before PR

```bash
# When you run `gh pr create`, L4 automatically suggests a review
# The gate-reviewer agent checks security and architecture

# Confirm all features pass
/personal-harness:features-validate
```

### Step 5 — Maintain Over Time

Agents generate entropy 5-10x faster than humans. Run these periodically.

```bash
# Scan for doc-code drift, unused exports, architecture violations
/personal-harness:gardener

# Check if repeated feedback should be promoted to stronger enforcement
/personal-harness:feedback-ladder

# Verify context budget isn't bloated
/personal-harness:context-budget

# Re-assess maturity — plan next level
/personal-harness:harness-assess
```

## Tool Reference

### Skills (manual invocation)

| Skill | Command | Purpose |
|------|--------|----------|
| Features Validator | `/personal-harness:features-validate` | Validate feature definitions (specificity, independence, verifiability, testability) |
| Knowledge Pyramid Linter | `/personal-harness:pyramid-lint` | Check CLAUDE.md and doc hierarchy (L0-L3) structure |
| Context Budget Monitor | `/personal-harness:context-budget` | Analyze token budget allocation (CLAUDE.md ≤5%, rules ≤3%, MEMORY ≤2%) |
| Harness Maturity Assessor | `/personal-harness:harness-assess` | Diagnose AI-DLC maturity level (L0-L4) with gap analysis |
| Feedback Encoding Ladder | `/personal-harness:feedback-ladder` | Track repeated feedback and suggest stronger encoding levels |
| Gardener Agent | `/personal-harness:gardener` | Scan for entropy (doc drift, unused code, architecture violations) |

### Hooks (automatic execution)

| Gate | Trigger | Timing | Checks | Blocks? |
|------|--------|------|----------|---------|
| L1 | Per file edit (PostToolUse) | 0-3s | syntax, file size, secrets, forbidden patterns | Yes (CRITICAL) |
| L2 | Turn end (Stop) | 5-30s | CLAUDE.md/AGENTS.md size, linter | Yes (lint failure) |
| L3 | Turn end (Stop, after L2) | 30s-5min | unit/integration test execution | Yes (test failure) |
| L4 | Before PR/Push (PreToolUse) | immediate | guidance to invoke gate-reviewer agent | No (advisory) |
| Budget | Turn end (Stop) | immediate | context budget obesity symptoms | No (advisory) |

### Agents (delegated invocation)

| Agent | Model | Role |
|---------|------|------|
| gardener | Sonnet | Entropy scan — read-only, reports findings |
| gate-reviewer | Opus | L4 code review — security, architecture, logic |

## Hierarchical Feedback Loop (L1-L5)

Catch problems at the cheapest level possible. Don't send to L5 what L1 can catch.

```
L1  per file edit    →  syntax, secrets           (0-3s,   $0,      blocks)
L2  turn end         →  linter, structure          (5-30s,  $0,      blocks)
L3  after L2 pass    →  unit/integration tests     (30s-5m, $0,      blocks)
L4  before PR        →  review agent               (1-5m,   $token,  advisory)
L5  after PR         →  human final approval       (10m+,   $labor,  outside plugin)
```

## AI-DLC Maturity Model

Run `/personal-harness:harness-assess` to diagnose where your project stands.

| Level | Name | What It Means |
|-------|------|---------------|
| L0 | Ad-hoc | No harness. Agent = autocomplete. Step-by-step approval. |
| L1 | Basic Harness | CLAUDE.md + linter + tests. Deterministic gates. |
| L2 | Automated Feedback | Hooks + CI/CD. Monitor-and-intervene. |
| L3 | Multi-Agent | Role separation (coder/reviewer/gardener). Auto entropy management. |
| L4 | Self-Evolving | Harness itself is improved by agents. Exception-based intervention. |

## PDF Pattern Coverage

### Implemented
- **Context Engineering**: Context Rot, Knowledge Pyramid, Context Budget
- **Feedback Loops**: Feedback Encoding Ladder, Hierarchical Verification (L1-L4), Agent-Friendly Errors
- **Entropy Management**: Gardener Agent
- **AI-DLC**: Phase 1 Requirements (features.json), Maturity Model (L0-L4)

### Planned
- Architectural Constraints: Swiss Cheese Trust Model, Boundary-Based Security
- Agent Patterns: Two-Agent System (Generator/Evaluator), Reasoning Sandwich
- State Persistence: Triple Redundancy (Git + features.json + progress.txt)
- Cost Optimization: Model Routing, Prompt Caching, Tool Search
- Agent Patterns: Dark Factory, 10 Collaboration Patterns

## License

MIT
