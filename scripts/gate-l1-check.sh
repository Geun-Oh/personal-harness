#!/usr/bin/env bash
# L1 Gate — PostToolUse(Edit/Write) 즉시 검증
# 매 파일 수정 후 0-3초 내 실행
# 검사: syntax 검증, 파일 크기, 금지 패턴, 시크릿

set -euo pipefail

FILE_PATH="${1:-}"

if [[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]]; then
  exit 0
fi

ERRORS=()
HAS_CRITICAL=false

# 1. Syntax 검증 (확장자별)
EXTENSION="${FILE_PATH##*.}"

case "$EXTENSION" in
  js|jsx|mjs|cjs)
    if command -v node &>/dev/null; then
      if ! node --check "$FILE_PATH" 2>/dev/null; then
        ERRORS+=("CRITICAL: ${FILE_PATH} has JavaScript syntax errors")
        HAS_CRITICAL=true
      fi
    fi
    ;;
  ts|tsx)
    if command -v npx &>/dev/null && [[ -f "tsconfig.json" ]]; then
      if ! npx --no-install tsc --noEmit --isolatedModules "$FILE_PATH" 2>/dev/null; then
        ERRORS+=("CRITICAL: ${FILE_PATH} has TypeScript errors. Run 'npx tsc --noEmit' for details.")
        HAS_CRITICAL=true
      fi
    fi
    ;;
  py)
    if command -v python3 &>/dev/null; then
      if ! python3 -c "import ast,sys; ast.parse(open(sys.argv[1]).read())" "$FILE_PATH" 2>/dev/null; then
        ERRORS+=("CRITICAL: ${FILE_PATH} has Python syntax errors")
        HAS_CRITICAL=true
      fi
    fi
    ;;
  json)
    if command -v python3 &>/dev/null; then
      if ! python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$FILE_PATH" 2>/dev/null; then
        ERRORS+=("CRITICAL: ${FILE_PATH} has JSON syntax errors")
        HAS_CRITICAL=true
      fi
    elif command -v node &>/dev/null; then
      if ! node -e "JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'))" "$FILE_PATH" 2>/dev/null; then
        ERRORS+=("CRITICAL: ${FILE_PATH} has JSON syntax errors")
        HAS_CRITICAL=true
      fi
    fi
    ;;
  rb)
    if command -v ruby &>/dev/null; then
      if ! ruby -c "$FILE_PATH" 2>/dev/null; then
        ERRORS+=("CRITICAL: ${FILE_PATH} has Ruby syntax errors")
        HAS_CRITICAL=true
      fi
    fi
    ;;
  sh|bash)
    if command -v bash &>/dev/null; then
      if ! bash -n "$FILE_PATH" 2>/dev/null; then
        ERRORS+=("CRITICAL: ${FILE_PATH} has shell syntax errors")
        HAS_CRITICAL=true
      fi
    fi
    ;;
esac

# 2. 파일 크기 검사 (500줄 초과 시 경고)
LINE_COUNT=$(wc -l < "$FILE_PATH" 2>/dev/null || echo "0")
LINE_COUNT=$(echo "$LINE_COUNT" | tr -d ' ')
if [[ "$LINE_COUNT" -gt 500 ]]; then
  ERRORS+=("WARN: ${FILE_PATH} is ${LINE_COUNT} lines (>500). Consider splitting.")
fi

# 3. 금지 패턴 검사
case "$EXTENSION" in
  ts|tsx|js|jsx)
    if [[ ! "$FILE_PATH" =~ (test|spec)\. ]]; then
      if grep -qn "console\.log" "$FILE_PATH" 2>/dev/null; then
        ERRORS+=("WARN: ${FILE_PATH} contains console.log statements")
      fi
    fi
    ;;
  py)
    if [[ ! "$FILE_PATH" =~ (test_|_test\.) ]]; then
      if grep -qn "^[^#]*\bprint(" "$FILE_PATH" 2>/dev/null; then
        ERRORS+=("WARN: ${FILE_PATH} contains print() statements")
      fi
    fi
    ;;
esac

# 4. 하드코딩된 시크릿 패턴 검사 (테스트/fixture 파일 제외)
if [[ ! "$FILE_PATH" =~ (test|spec|fixture|mock|fake)\. ]] && \
   grep -qiE "(password|secret|api_key|apikey|token)\s*=\s*['\"][^'\"]+['\"]" "$FILE_PATH" 2>/dev/null; then
  ERRORS+=("CRITICAL: ${FILE_PATH} may contain hardcoded secrets. Remove credentials and use environment variables.")
  HAS_CRITICAL=true
fi

# 5. TODO/FIXME 감지 (정보성)
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

# CRITICAL 발견 시 exit 1로 차단
if [[ "$HAS_CRITICAL" == true ]]; then
  exit 1
fi

exit 0
