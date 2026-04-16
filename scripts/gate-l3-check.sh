#!/usr/bin/env bash
# L3 Gate — Stop hook (after L2 passes) verification
# Runs unit/integration tests, 30 seconds to 5 minutes

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

ERRORS=()

# Detect and run test framework
TEST_RAN=false

# Node.js (only when package.json has a test script and real tests exist)
if [[ -f "package.json" ]] && grep -q '"test"' "package.json" 2>/dev/null; then
  # Exclude dummy scripts like "test": "echo..."
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
  if find . -maxdepth 3 \( -name "test_*.py" -o -name "*_test.py" \) 2>/dev/null | grep -q .; then
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

# Output results
if [[ ${#ERRORS[@]} -gt 0 ]]; then
  echo "[L3 Gate] Test verification:"
  for err in "${ERRORS[@]}"; do
    echo "  - $err"
  done
  # Show last 30 lines of test output (helps agent identify root cause)
  if [[ -n "${TEST_OUTPUT:-}" ]]; then
    echo "  --- Last 30 lines of test output ---"
    echo "$TEST_OUTPUT" | tail -30 | sed 's/^/  /'
  fi
  exit 1
fi

if [[ "$TEST_RAN" == true ]]; then
  echo "[L3 Gate] All tests passed."
fi

exit 0
