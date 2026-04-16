# personal-harness

Harness Engineering toolkit for Claude Code — 7 tools based on the AI-DLC presentation material.

## Installation

```bash
# Marketplace registration
/plugin marketplace add Geun-Oh/personal-harness

# Install
/plugin install personal-harness@personal-harness
```

For local development:
```bash
claude --plugin-dir ./personal-harness
```

## Tool List

### Skills (manual invocation)

| Skill | Command | Pattern |
|------|--------|----------|
| Knowledge Pyramid Linter | `/personal-harness:pyramid-lint` | Knowledge Pyramid, Progressive Disclosure |
| Features.json Validator | `/personal-harness:features-validate` | AI-DLC Phase 1 (Requirements) |
| Context Budget Monitor | `/personal-harness:context-budget` | Context Rot, Context Budget |
| Harness Maturity Assessor | `/personal-harness:harness-assess` | Maturity Model L0→L4 |
| Feedback Encoding Ladder | `/personal-harness:feedback-ladder` | Feedback Encoding Ladder |
| Gardener Agent | `/personal-harness:gardener` | Entropy Management |

### Hooks (automatic execution)

| Gate | Trigger | Timing | Checks |
|------|--------|------|----------|
| L1 | Per file edit (PostToolUse) | 0-3s | syntax, file size, secrets, forbidden patterns |
| L2 | Turn end (Stop) | 5-30s | CLAUDE.md/AGENTS.md size, linter |
| L3 | Turn end (Stop, after L2) | 30s-5min | unit/integration test execution |
| L4 | Before PR/Push (PreToolUse) | immediate | guidance to invoke gate-reviewer agent |
| Budget | Turn end (Stop) | immediate | context budget obesity symptoms |

### Agents (delegated invocation)

| Agent | Model | Role |
|---------|------|------|
| gardener | Sonnet | entropy scan (read-only) |
| gate-reviewer | Opus | L4 code review (security/architecture) |

## Hierarchical Feedback Loop (L1-L5)

```
L1 per file edit    →  syntax, secrets (CRITICAL blocks)
L2 turn end         →  linter, structure checks
L3 after L2 pass    →  test execution (blocks on failure)
L4 before PR        →  review agent recommended
L5 after PR         →  human final approval (outside plugin scope)
```

## PDF Pattern Coverage

### Implemented
- Context Engineering: Context Rot, Knowledge Pyramid, Context Budget
- Feedback Loops: Feedback Encoding Ladder, Hierarchical Verification (L1-L4), Agent-Friendly Errors
- Entropy Management: Gardener Agent
- AI-DLC: Phase 1 Requirements (features.json), Maturity Model (L0-L4)

### Planned
- Architectural Constraints: Swiss Cheese Trust Model, Boundary-Based Security
- Agent Patterns: Two-Agent System (Generator/Evaluator), Reasoning Sandwich
- State Persistence: Triple Redundancy (Git + features.json + progress.txt)
- Cost Optimization: Model Routing, Prompt Caching, Tool Search
- Agent Patterns: Dark Factory, 10 Collaboration Patterns

## Reference

This plugin implements patterns from the [Harness Engineering & AI-DLC](https://github.com/Geun-Oh/personal-harness) presentation as Claude Code tools.
