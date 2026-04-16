#!/usr/bin/env bash
# Context Budget Monitor — Stop hook
# CLAUDE.md, rules, MEMORY.md의 줄 수/추정 토큰을 측정하여 비만 증상 경고

set -euo pipefail

# 프로젝트 루트 결정
if [[ -n "${CLAUDE_PROJECT_DIR:-}" ]]; then
  PROJECT_ROOT="$CLAUDE_PROJECT_DIR"
elif git rev-parse --show-toplevel &>/dev/null; then
  PROJECT_ROOT=$(git rev-parse --show-toplevel)
else
  PROJECT_ROOT="$(pwd)"
fi

cd "$PROJECT_ROOT"

WARNINGS=()

# 토큰 추정 함수 (1 토큰 ≈ 4 bytes for English, ≈ 1.5 bytes for Korean)
estimate_tokens() {
  local file="$1"
  if [[ -f "$file" ]]; then
    local bytes
    bytes=$(wc -c < "$file" | tr -d ' ')
    # 혼합 언어 추정: 평균 3 bytes/token
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

# 1. CLAUDE.md 검사 (권장: ≤100줄, ≤5%)
CLAUDE_LINES=0
CLAUDE_TOKENS=0
if [[ -f "CLAUDE.md" ]]; then
  CLAUDE_LINES=$(get_lines "CLAUDE.md")
  CLAUDE_TOKENS=$(estimate_tokens "CLAUDE.md")
  if [[ "$CLAUDE_LINES" -gt 100 ]]; then
    WARNINGS+=("CLAUDE.md: ${CLAUDE_LINES} lines, ~${CLAUDE_TOKENS} tokens (recommended: ≤100 lines). Move details to ARCHITECTURE.md or docs/.")
  fi
fi

# 2. .claude/rules/ 검사 (권장: ≤3%)
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

# 3. MEMORY.md 검사 (권장: ≤200줄, ≤2%)
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

# 4. 전체 하네스 오버헤드 계산
TOTAL_HARNESS_TOKENS=$((CLAUDE_TOKENS + RULES_TOKENS + MEMORY_TOKENS))
# 200K context window 기준 20% 이상이면 경고
if [[ "$TOTAL_HARNESS_TOKENS" -gt 40000 ]]; then
  WARNINGS+=("Total harness overhead: ~${TOTAL_HARNESS_TOKENS} tokens (>20% of 200K context). Reduce to keep ≥80% for actual work.")
fi

# 결과 출력 (경고가 있을 때만)
if [[ ${#WARNINGS[@]} -gt 0 ]]; then
  echo "[Context Budget] Obesity symptoms detected:"
  for warn in "${WARNINGS[@]}"; do
    echo "  - WARN: $warn"
  done
  echo "  - Summary: CLAUDE.md=${CLAUDE_LINES}L rules=${RULES_COUNT}files/${RULES_LINES}L MEMORY=${MEMORY_LINES}L total=~${TOTAL_HARNESS_TOKENS}tok"
fi

exit 0
