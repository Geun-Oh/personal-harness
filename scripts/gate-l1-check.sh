#!/usr/bin/env bash
# L1 Gate — PostToolUse(Edit/Write) immediate verification
# Runs within 0-3 seconds after each file edit
# Checks: syntax validation, file size, forbidden patterns, secrets

set -euo pipefail

FILE_PATH="${1:-}"

if [[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]]; then
  exit 0
fi

ERRORS=()
HAS_CRITICAL=false

# 1. Syntax validation (by file extension)
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

# 2. File size check (warn if over 500 lines)
LINE_COUNT=$(wc -l < "$FILE_PATH" 2>/dev/null || echo "0")
LINE_COUNT=$(echo "$LINE_COUNT" | tr -d ' ')
if [[ "$LINE_COUNT" -gt 500 ]]; then
  ERRORS+=("WARN: ${FILE_PATH} is ${LINE_COUNT} lines (>500). Consider splitting.")
fi

# 3. Forbidden pattern checks
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

# 4. Hardcoded secret pattern check (excluding test/fixture files)
if [[ ! "$FILE_PATH" =~ (test|spec|fixture|mock|fake)\. ]] && \
   grep -qiE "(password|secret|api_key|apikey|token)\s*=\s*['\"][^'\"]+['\"]" "$FILE_PATH" 2>/dev/null; then
  ERRORS+=("CRITICAL: ${FILE_PATH} may contain hardcoded secrets. Remove credentials and use environment variables.")
  HAS_CRITICAL=true
fi

# 5. TODO/FIXME detection (informational)
TODO_COUNT=0
if grep -q "TODO\|FIXME\|HACK\|XXX" "$FILE_PATH" 2>/dev/null; then
  TODO_COUNT=$(grep -c "TODO\|FIXME\|HACK\|XXX" "$FILE_PATH")
fi
if [[ "$TODO_COUNT" -gt 0 ]]; then
  ERRORS+=("INFO: ${FILE_PATH} has ${TODO_COUNT} TODO/FIXME markers")
fi

# Output results
if [[ ${#ERRORS[@]} -gt 0 ]]; then
  echo "[L1 Gate] ${FILE_PATH}:"
  for err in "${ERRORS[@]}"; do
    echo "  - $err"
  done
fi

# Block with exit 1 if CRITICAL found
if [[ "$HAS_CRITICAL" == true ]]; then
  exit 1
fi

exit 0
