#!/usr/bin/env bash
# L2 Gate — Stop hook (턴 종료 시) 검증
# 린터, 구조 테스트 등 5-30초 내 실행

set -euo pipefail

ERRORS=()

# 1. CLAUDE.md 줄 수 검사
if [[ -f "CLAUDE.md" ]]; then
  CLAUDE_LINES=$(wc -l < "CLAUDE.md" | tr -d ' ')
  if [[ "$CLAUDE_LINES" -gt 100 ]]; then
    ERRORS+=("WARN: CLAUDE.md is ${CLAUDE_LINES} lines (recommended: ≤100)")
  fi
fi

# 2. AGENTS.md 모놀리식 안티패턴 검사
if [[ -f "AGENTS.md" ]]; then
  AGENTS_LINES=$(wc -l < "AGENTS.md" | tr -d ' ')
  if [[ "$AGENTS_LINES" -gt 300 ]]; then
    ERRORS+=("WARN: AGENTS.md is ${AGENTS_LINES} lines — monolithic anti-pattern (recommended: ≤300)")
  fi
fi

# 3. MEMORY.md 비대화 검사
if [[ -f ".claude/MEMORY.md" ]] || [[ -f "MEMORY.md" ]]; then
  MEMORY_FILE="MEMORY.md"
  [[ -f ".claude/MEMORY.md" ]] && MEMORY_FILE=".claude/MEMORY.md"
  MEMORY_LINES=$(wc -l < "$MEMORY_FILE" | tr -d ' ')
  if [[ "$MEMORY_LINES" -gt 200 ]]; then
    ERRORS+=("WARN: MEMORY.md is ${MEMORY_LINES} lines (recommended: ≤200)")
  fi
fi

# 4. 프로젝트별 린터 실행 (존재하는 경우만)
if [[ -f "package.json" ]] && grep -q '"lint"' "package.json" 2>/dev/null; then
  if ! npm run lint --silent 2>/dev/null; then
    ERRORS+=("FAIL: npm run lint failed")
  fi
elif [[ -f "pyproject.toml" ]] && command -v ruff &>/dev/null; then
  RUFF_OUTPUT=$(ruff check . 2>&1 || true)
  if [[ -n "$RUFF_OUTPUT" ]]; then
    RUFF_COUNT=$(echo "$RUFF_OUTPUT" | wc -l | tr -d ' ')
    ERRORS+=("WARN: ruff found ${RUFF_COUNT} issues")
  fi
fi

# 결과 출력
if [[ ${#ERRORS[@]} -gt 0 ]]; then
  echo "[L2 Gate] Session check:"
  for err in "${ERRORS[@]}"; do
    echo "  - $err"
  done
fi

exit 0
