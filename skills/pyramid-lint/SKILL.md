---
description: "Knowledge Pyramid Linter — Checks that CLAUDE.md and the document hierarchy (L0-L3) are properly structured. Triggers on 'pyramid lint', 'check claude.md', 'document structure check'."
---

# Knowledge Pyramid Linter

Inspects the project's Knowledge Pyramid (L0-L3) structure to prevent Context Rot.

## Checks

### L0: CLAUDE.md (entry point)
1. **Line count check**: Verify it is 100 lines or fewer
2. **Index role**: Verify pointers to next-level (L1) documents are present
3. **Build/test commands**: Verify core commands are included
4. **Anti-pattern detection**: Warn on monolithic structures of 300+ lines

### L1: Architecture/Standards documents
- Check for existence of ARCHITECTURE.md, CODING_STANDARDS.md, etc.
- Check for pointers to L2

### L2: Design documents
- Check for existence of docs/design-docs/, docs/exec-plans/ directories

### L3: Reference/generated documents
- Check for existence of references/, generated/ directories

## How to Run

Inspects the following from the current project directory:

1. Read CLAUDE.md and analyze line count and content
2. If AGENTS.md exists, check whether it exceeds 300 lines (anti-pattern)
3. Use Glob to verify existence of L1-L3 directories/files
4. Verify pointers (links/references) to the next level at each level

## Output Format

```
## Knowledge Pyramid Check Results

### L0: CLAUDE.md
- [PASS/FAIL] Line count: N lines (recommended: ≤100)
- [PASS/FAIL] L1 pointer present
- [PASS/FAIL] Build/test commands included

### L1: Architecture documents
- [PASS/FAIL] ARCHITECTURE.md exists
- [PASS/FAIL] L2 pointer present

### L2: Design documents
- [PASS/FAIL] docs/ directory exists

### L3: Reference documents
- [INFO] references/ directory exists

### Anti-patterns
- [WARN/PASS] Monolithic AGENTS.md (300+ lines)

### Summary
N of M items passed, K failed, J warnings
Next improvement actions: ...
```

## Notes
- This check must be run from the project root
- A missing file is not necessarily a failure (L2 and L3 are INFO-level)
- If CLAUDE.md is absent, the entire check is skipped and creation is recommended
