#!/usr/bin/env bash
# L1 Gate — PostToolUse(Edit/Write) 즉시 검증
# 매 파일 수정 후 0-3초 내 실행
# 검사: syntax 오류, 파일 크기, 금지 패턴

set -euo pipefail

FILE_PATH="${1:-}"

if [[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]]; then
  exit 0
fi

ERRORS=()

# 1. 파일 크기 검사 (500줄 초과 시 경고)
LINE_COUNT=$(wc -l < "$FILE_PATH" 2>/dev/null || echo "0")
LINE_COUNT=$(echo "$LINE_COUNT" | tr -d ' ')
if [[ "$LINE_COUNT" -gt 500 ]]; then
  ERRORS+=("WARN: ${FILE_PATH} is ${LINE_COUNT} lines (>500). Consider splitting.")
fi

# 2. 금지 패턴 검사
EXTENSION="${FILE_PATH##*.}"

case "$EXTENSION" in
  ts|tsx|js|jsx)
    # console.log 남김 검사 (테스트 파일 제외)
    if [[ ! "$FILE_PATH" =~ (test|spec)\. ]]; then
      if grep -qn "console\.log" "$FILE_PATH" 2>/dev/null; then
        ERRORS+=("WARN: ${FILE_PATH} contains console.log statements")
      fi
    fi
    ;;
  py)
    # print() 남김 검사 (테스트 파일 제외)
    if [[ ! "$FILE_PATH" =~ (test_|_test\.) ]]; then
      if grep -qn "^[^#]*\bprint(" "$FILE_PATH" 2>/dev/null; then
        ERRORS+=("WARN: ${FILE_PATH} contains print() statements")
      fi
    fi
    ;;
esac

# 3. 하드코딩된 시크릿 패턴 검사
if grep -qiEn "(password|secret|api_key|apikey|token)\s*=\s*['\"][^'\"]+['\"]" "$FILE_PATH" 2>/dev/null; then
  ERRORS+=("CRITICAL: ${FILE_PATH} may contain hardcoded secrets")
fi

# 4. TODO/FIXME 신규 추가 감지 (정보성)
TODO_COUNT=0
if grep -q "TODO\|FIXME\|HACK\|XXX" "$FILE_PATH" 2>/dev/null; then
  TODO_COUNT=$(grep -c "TODO\|FIXME\|HACK\|XXX" "$FILE_PATH")
fi
if [[ "$TODO_COUNT" -gt 0 ]]; then
  ERRORS+=("INFO: ${FILE_PATH} has ${TODO_COUNT} TODO/FIXME markers")
fi

# 결과 출력
if [[ ${#ERRORS[@]} -gt 0 ]]; then
  echo "[L1 Gate] ${FILE_PATH}:"
  for err in "${ERRORS[@]}"; do
    echo "  - $err"
  done
fi

exit 0
