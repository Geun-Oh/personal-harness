#!/usr/bin/env bash
# Context Budget Monitor — Stop hook
# Measures line counts and estimated tokens for CLAUDE.md, rules, and MEMORY.md, and warns about obesity symptoms

set -euo pipefail

# Determine project root
if [[ -n "${CLAUDE_PROJECT_DIR:-}" ]]; then
  PROJECT_ROOT="$CLAUDE_PROJECT_DIR"
elif git rev-parse --show-toplevel &>/dev/null; then
  PROJECT_ROOT=$(git rev-parse --show-toplevel)
else
  PROJECT_ROOT="$(pwd)"
fi

cd "$PROJECT_ROOT"

WARNINGS=()

# Token estimation function (1 token ≈ 4 bytes for English, ≈ 1.5 bytes for Korean)
estimate_tokens() {
  local file="$1"
  if [[ -f "$file" ]]; then
    local bytes
    bytes=$(wc -c < "$file" | tr -d ' ')
    # Mixed-language estimate: average 3 bytes/token
    echo $(( bytes / 3 ))
  else
    echo 0
  fi
}

get_lines() {
  local file="$1"
  if [[ -f "$file" ]]; then
    wc -l < "$file" | tr -d ' '
  else
    echo 0
  fi
}

# 1. CLAUDE.md check (recommended: ≤100 lines, ≤5%)
CLAUDE_LINES=0
CLAUDE_TOKENS=0
if [[ -f "CLAUDE.md" ]]; then
  CLAUDE_LINES=$(get_lines "CLAUDE.md")
  CLAUDE_TOKENS=$(estimate_tokens "CLAUDE.md")
  if [[ "$CLAUDE_LINES" -gt 100 ]]; then
    WARNINGS+=("CLAUDE.md: ${CLAUDE_LINES} lines, ~${CLAUDE_TOKENS} tokens (recommended: ≤100 lines). Move details to ARCHITECTURE.md or docs/.")
  fi
fi

# 2. .claude/rules/ check (recommended: ≤3%)
RULES_LINES=0
RULES_TOKENS=0
RULES_COUNT=0
if [[ -d ".claude/rules" ]]; then
  while IFS= read -r -d '' rule_file; do
    lines=$(get_lines "$rule_file")
    tokens=$(estimate_tokens "$rule_file")
    RULES_LINES=$((RULES_LINES + lines))
    RULES_TOKENS=$((RULES_TOKENS + tokens))
    RULES_COUNT=$((RULES_COUNT + 1))
    if [[ "$lines" -gt 50 ]]; then
      WARNINGS+=("Rule $(basename "$rule_file"): ${lines} lines (recommended: ≤50 per rule). Split into smaller rules.")
    fi
  done < <(find .claude/rules -name "*.md" -print0 2>/dev/null)
fi

# 3. MEMORY.md check (recommended: ≤200 lines, ≤2%)
MEMORY_LINES=0
MEMORY_TOKENS=0
MEMORY_FILE=""
[[ -f "MEMORY.md" ]] && MEMORY_FILE="MEMORY.md"
[[ -f ".claude/MEMORY.md" ]] && MEMORY_FILE=".claude/MEMORY.md"
if [[ -n "$MEMORY_FILE" ]]; then
  MEMORY_LINES=$(get_lines "$MEMORY_FILE")
  MEMORY_TOKENS=$(estimate_tokens "$MEMORY_FILE")
  if [[ "$MEMORY_LINES" -gt 200 ]]; then
    WARNINGS+=("MEMORY.md: ${MEMORY_LINES} lines, ~${MEMORY_TOKENS} tokens (recommended: ≤200 lines). Prune stale entries.")
  fi
fi

# 4. Per-category ratio check (PDF baseline: CLAUDE.md ≤5%, rules ≤3%, MEMORY ≤2%)
# Based on 200K context window = 200,000 tokens
CONTEXT_WINDOW=200000
TOTAL_HARNESS_TOKENS=$((CLAUDE_TOKENS + RULES_TOKENS + MEMORY_TOKENS))

if [[ "$CLAUDE_TOKENS" -gt 0 ]]; then
  CLAUDE_PCT=$(( CLAUDE_TOKENS * 100 / CONTEXT_WINDOW ))
  if [[ "$CLAUDE_PCT" -ge 5 ]]; then
    WARNINGS+=("CLAUDE.md: ~${CLAUDE_TOKENS} tokens (${CLAUDE_PCT}% of context, limit: ≤5%). Trim to index/pointer role.")
  fi
fi

if [[ "$RULES_TOKENS" -gt 0 ]]; then
  RULES_PCT=$(( RULES_TOKENS * 100 / CONTEXT_WINDOW ))
  if [[ "$RULES_PCT" -ge 3 ]]; then
    WARNINGS+=("rules/: ~${RULES_TOKENS} tokens (${RULES_PCT}% of context, limit: ≤3%). Reduce active rules.")
  fi
fi

if [[ "$MEMORY_TOKENS" -gt 0 ]]; then
  MEMORY_PCT=$(( MEMORY_TOKENS * 100 / CONTEXT_WINDOW ))
  if [[ "$MEMORY_PCT" -ge 2 ]]; then
    WARNINGS+=("MEMORY.md: ~${MEMORY_TOKENS} tokens (${MEMORY_PCT}% of context, limit: ≤2%). Prune stale entries.")
  fi
fi

# Total harness overhead (≤20% = actual work ≥80%)
if [[ "$TOTAL_HARNESS_TOKENS" -gt 40000 ]]; then
  TOTAL_PCT=$(( TOTAL_HARNESS_TOKENS * 100 / CONTEXT_WINDOW ))
  WARNINGS+=("Total harness overhead: ~${TOTAL_HARNESS_TOKENS} tokens (${TOTAL_PCT}%, limit: ≤20%). Reduce to keep ≥80% for actual work.")
fi

# Output results (only when warnings exist)
if [[ ${#WARNINGS[@]} -gt 0 ]]; then
  echo "[Context Budget] Obesity symptoms detected:"
  for warn in "${WARNINGS[@]}"; do
    echo "  - WARN: $warn"
  done
  echo "  - Summary: CLAUDE.md=${CLAUDE_LINES}L rules=${RULES_COUNT}files/${RULES_LINES}L MEMORY=${MEMORY_LINES}L total=~${TOTAL_HARNESS_TOKENS}tok"
fi

exit 0
