---
description: "Gardener Agent — Scans for doc-code mismatches, unused exports, and architecture violations, then suggests cleanup PRs. This skill invokes the gardener agent to perform the scan. Triggers on 'gardener', 'entropy scan', 'entropy', 'cleanup'."
---

# Gardener Agent

Agents accumulate entropy 5-10x faster than humans. The Gardener Agent manages this continuously.

## How It Runs

This skill delegates work to the `gardener` agent.

**Invoke the gardener agent using the Agent tool:**

```
Agent(
  subagent_type="personal-harness:gardener",
  prompt="Scan the current project for entropy: doc-code mismatches, unused exports, architecture violations, and code duplication."
)
```

This skill (this file) is the user entry point; the actual scan logic is performed by the agent defined in `agents/gardener.md`. The agent operates in read-only mode and does not modify code directly.

## Entropy Types and Responses

| Entropy Type | Agent Code Characteristic | Detection Method |
|-------------|-----------------|----------|
| Code duplication | Occurs in large volumes | Search for similar functions/blocks |
| Documentation drift | Fast | Compare doc ↔ code mismatches |
| Architecture drift | Unconscious violations | Search for dependency rule violations |
| Unused code | Accumulates quickly | Detect unused exports/imports |

## Scan Items (performed by agent)

### 1. Doc-Code Mismatches
- Whether installation/usage instructions in README.md match actual code
- Whether endpoints/parameters in API docs match actual implementation
- Whether build/test commands in CLAUDE.md actually work

### 2. Unused Export Detection
- Whether exported functions/classes are imported in other files
- Public APIs not used externally

### 3. Periodic Architecture Violation Checks
- Layer dependency rule violations (e.g., UI → Service is OK, Service → UI is a violation)
- Circular dependency detection

### 4. Code Duplication Search
- Patterns where similar logic is repeated across multiple files

## Output Format

The agent returns a report in the following format:

```
## Gardener Entropy Scan Results

### Doc-Code Mismatches (N items)
1. [HIGH] file:line — mismatch description. Fix: ...

### Unused Exports (N items)
1. [LOW] file:line: `exportName` — 0 references

### Architecture Violations (N items)
1. [HIGH] file → file — reverse dependency. Fix: ...

### Code Duplication (N items)
1. [MED] fileA:line-range ≈ fileB:line-range — suggest extracting common logic

### Summary
- Critical: 0 | High: N | Medium: N | Low: N
- Recommendation: ...
```

## Periodic Execution
- Can be integrated with `/schedule` for periodic runs
- Example: `claude /schedule "daily 09:00" /personal-harness:gardener`
- Can also be used as an automated pre-PR scan
