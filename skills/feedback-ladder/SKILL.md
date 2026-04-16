---
description: "Feedback Encoding Ladder Tracker — Detects repeated feedback and suggests promoting it to a stronger encoding level (Review Comment → Documentation → Tool Design → Linter/Test). Triggers on 'feedback ladder', 'feedback tracking', 'repeated feedback'."
---

# Feedback Encoding Ladder Tracker

"If you have to give the same feedback twice, it's a failure of the system." — OpenAI

Automatically suggests stronger encoding when the same corrective feedback recurs.

## Encoding Ladder (weak → strong)

```
Level 1: Review Comment (weakest)
  → The agent may read it or ignore it
  → Location: in-conversation feedback, PR comments

Level 2: Documentation
  → Recorded in docs/ for persistence
  → Location: CLAUDE.md, CODING_STANDARDS.md, .claude/rules/*.md

Level 3: Tool Design
  → Constraints embedded in the tool itself
  → Location: PreToolUse/PostToolUse in hooks.json, custom tool descriptions

Level 4: Linter/Test (strongest)
  → Immediate failure on violation, deterministic enforcement
  → Location: eslint rules, pytest fixtures, CI gates
```

## Persistent State Management

Uses `.claude/feedback-ladder-state.json` to track feedback recurrence counts across sessions.

### State File Schema

```json
{
  "version": 1,
  "feedbacks": [
    {
      "id": "no-merge-without-tests",
      "topic": "Do not merge without tests",
      "keywords": ["test", "merge", "coverage"],
      "occurrences": 3,
      "first_seen": "2026-04-10",
      "last_seen": "2026-04-16",
      "current_level": 1,
      "current_location": "MEMORY.md feedback entry",
      "recommended_level": 4,
      "promoted": false
    }
  ]
}
```

### State Field Descriptions
- `id`: unique identifier (kebab-case)
- `topic`: summary of the feedback content
- `keywords`: keywords for matching similar feedback
- `occurrences`: cumulative occurrence count
- `current_level`: currently encoded level (1-4)
- `current_location`: where the feedback is currently encoded
- `recommended_level`: recommended level based on recurrence count
- `promoted`: whether promotion has been completed

## How It Works

### 1. Load State File
- Read `.claude/feedback-ladder-state.json` if it exists
- If absent, perform an initial scan and create it

### 2. Collect and Match Feedback
- Scan feedback-type memory files in MEMORY.md → Level 1 entries
- Analyze .claude/rules/*.md files → Level 2-3 entries
- Check rules in hooks.json → Level 4 entries
- Identify identical feedback by keyword-matching against existing state entries

### 3. Recurrence Detection and Promotion Rules
- 1 occurrence: record only (Level 1)
- 2 occurrences: suggest promotion to Documentation (Level 2)
- 3+ occurrences: suggest promotion to Tool Design (Level 3) or Linter/Test (Level 4)

### 4. State Update
- Add newly discovered feedback to the state file
- Update occurrences, last_seen, recommended_level
- Save state file with Write

## How to Run

1. Load `.claude/feedback-ladder-state.json` (start with empty state if absent)
2. Glob/Read feedback-type memory files from the MEMORY.md directory
3. Read .claude/rules/*.md files
4. Read hooks.json to check existing Level 4 encodings
5. Compare each feedback's current level and recurrence count against state
6. Report items requiring promotion
7. Update state file (Write)

## Output Format

```
## Feedback Encoding Ladder Analysis

### State file: .claude/feedback-ladder-state.json
- Feedback items tracked: N
- Promotion required: M

### Items Requiring Promotion

#### 1. "Do not merge without tests" (id: no-merge-without-tests)
- Current level: Level 1 (Review Comment) — recorded in MEMORY.md
- Occurrences: 3 (2026-04-10 ~ 2026-04-16)
- Recommended level: Level 4 (Linter/Test)
- Suggested action: Add test coverage gate to CI
  ```yaml
  # .github/workflows/ci.yml
  - run: npm test -- --coverage --coverageThreshold='{"global":{"branches":80}}'
  ```

#### 2. "Please follow import ordering" (id: import-order)
- Current level: Level 2 (Documentation) — recorded in CODING_STANDARDS.md
- Occurrences: 2
- Recommended level: Level 4 (Linter/Test)
- Suggested action: Add eslint-plugin-import rule

### Already Appropriately Encoded
- "No hardcoded secrets" → Level 4 (gate-l1-check.sh) ✅

### Summary
- N total feedback clusters
- M need stronger encoding than current level
- Most urgent promotion: ...
```

## Integration
- Integrates with Claude Code's memory system (scans feedback-type memory files)
- Feedback encoded in .claude/rules/ is recognized as Level 2-3
- Checks encoded in hooks.json are recognized as Level 4
- State file persists tracking across sessions
