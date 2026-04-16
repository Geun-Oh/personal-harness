---
description: "Context Budget Monitor — Analyzes context window budget ratios (CLAUDE.md ≤5%, rules ≤3%, MEMORY.md ≤2%, actual work ≥80%) and warns about obesity symptoms. Triggers on 'context budget', 'token ratio'."
---

# Context Budget Monitor

Analyzes context window budget allocation to provide early warning of Context Rot.

## Budget Reference Table

| Source | Recommended Ratio | Description |
|------|----------|------|
| CLAUDE.md | ≤5% | Table-of-contents role, within 100 lines |
| .claude/rules/ | ≤3% | Active rules only |
| MEMORY.md | ≤2% | Within 200 lines |
| Tool definitions | ≤10% | Minimize number of tools |
| Actual work context | ≥80% | Code, tests, error logs |

## Measurement Method

Estimates approximate token counts for each file (1 token ≈ 4 characters for English, ≈ 1.5 characters for Korean):

1. Read CLAUDE.md → line count, character count, estimated token count
2. Read all .claude/rules/*.md → sum totals
3. Read MEMORY.md → line count, character count
4. Calculate overall ratios

## Obesity Symptom Detection

Warns when any of the following are detected:
- CLAUDE.md exceeds 100 lines
- MEMORY.md exceeds 200 lines
- Total rules files estimated to exceed 3% of context
- A single rules file exceeds 50 lines

## Output Format

```
## Context Budget Analysis

### Current Allocation
| Source | Lines | Est. Tokens | Ratio | Status |
|------|------|----------|------|------|
| CLAUDE.md | N | ~T | X% | OK/WARN |
| rules/ | N | ~T | X% | OK/WARN |
| MEMORY.md | N | ~T | X% | OK/WARN |

### Obesity Symptoms
- [WARN] CLAUDE.md 150 lines — reduce to 100 lines or fewer
- [OK] No repeated file-read patterns detected

### Recommended Actions
1. Move detailed content from CLAUDE.md to L1 documents
2. ...
```

## Notes
- Token counts are estimates (exact tokenization varies by model)
- This check is based on static files. Runtime context consumption is not measured
- Integrating with the Hook version (Gate Runner #6) enables real-time monitoring
