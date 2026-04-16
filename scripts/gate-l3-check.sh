#!/usr/bin/env bash
# L3 Gate — Stop hook (L2 통과 후) 검증
# 단위/통합 테스트 실행, 30초-5분

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

ERRORS=()

# 테스트 프레임워크 감지 및 실행
TEST_RAN=false

# Node.js (package.json에 test 스크립트가 있고, 실제 테스트가 존재할 때만)
if [[ -f "package.json" ]] && grep -q '"test"' "package.json" 2>/dev/null; then
  # "test": "echo..." 같은 더미 스크립트 제외
  if ! grep -q '"test".*echo' "package.json" 2>/dev/null; then
    TEST_OUTPUT=$(npm test 2>&1) || {
      FAIL_COUNT=$(echo "$TEST_OUTPUT" | grep -c "fail\|FAIL\|Error" || echo "?")
      ERRORS+=("FAIL: npm test failed (${FAIL_COUNT} failures detected). Fix failing tests before PR.")
    }
    TEST_RAN=true
  fi
fi

# Python (pytest)
if [[ "$TEST_RAN" == false ]] && command -v pytest &>/dev/null; then
  if find . -maxdepth 3 -name "test_*.py" -o -name "*_test.py" 2>/dev/null | grep -q .; then
    TEST_OUTPUT=$(pytest --tb=short -q 2>&1) || {
      ERRORS+=("FAIL: pytest failed. Fix failing tests before PR.")
    }
    TEST_RAN=true
  fi
fi

# Go
if [[ "$TEST_RAN" == false ]] && [[ -f "go.mod" ]] && command -v go &>/dev/null; then
  TEST_OUTPUT=$(go test ./... 2>&1) || {
    ERRORS+=("FAIL: go test failed. Fix failing tests before PR.")
  }
  TEST_RAN=true
fi

# Ruby (rspec/minitest)
if [[ "$TEST_RAN" == false ]] && [[ -f "Gemfile" ]]; then
  if [[ -d "spec" ]] && command -v rspec &>/dev/null; then
    TEST_OUTPUT=$(bundle exec rspec 2>&1) || {
      ERRORS+=("FAIL: rspec failed. Fix failing tests before PR.")
    }
    TEST_RAN=true
  elif [[ -d "test" ]] && command -v rails &>/dev/null; then
    TEST_OUTPUT=$(bundle exec rails test 2>&1) || {
      ERRORS+=("FAIL: rails test failed. Fix failing tests before PR.")
    }
    TEST_RAN=true
  fi
fi

# 결과 출력
if [[ ${#ERRORS[@]} -gt 0 ]]; then
  echo "[L3 Gate] Test verification:"
  for err in "${ERRORS[@]}"; do
    echo "  - $err"
  done
  exit 1
fi

if [[ "$TEST_RAN" == true ]]; then
  echo "[L3 Gate] All tests passed."
fi

exit 0
