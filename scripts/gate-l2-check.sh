#!/usr/bin/env bash
# L2 Gate — Stop hook (end of turn) verification
# Runs linter, structure tests, etc. within 5-30 seconds

set -euo pipefail

# Determine project root (env var takes priority, then git root, finally CWD)
if [[ -n "${CLAUDE_PROJECT_DIR:-}" ]]; then
  PROJECT_ROOT="$CLAUDE_PROJECT_DIR"
elif git rev-parse --show-toplevel &>/dev/null; then
  PROJECT_ROOT=$(git rev-parse --show-toplevel)
else
  PROJECT_ROOT="$(pwd)"
fi

cd "$PROJECT_ROOT"

ERRORS=()

# 1. CLAUDE.md line count check
if [[ -f "CLAUDE.md" ]]; then
  CLAUDE_LINES=$(wc -l < "CLAUDE.md" | tr -d ' ')
  if [[ "$CLAUDE_LINES" -gt 100 ]]; then
    ERRORS+=("WARN: CLAUDE.md is ${CLAUDE_LINES} lines (recommended: ≤100). Move details to L1 docs (ARCHITECTURE.md, CODING_STANDARDS.md).")
  fi
fi

# 2. AGENTS.md monolithic anti-pattern check
if [[ -f "AGENTS.md" ]]; then
  AGENTS_LINES=$(wc -l < "AGENTS.md" | tr -d ' ')
  if [[ "$AGENTS_LINES" -gt 300 ]]; then
    ERRORS+=("WARN: AGENTS.md is ${AGENTS_LINES} lines — monolithic anti-pattern. Split into agents/ directory with role-specific files.")
  fi
fi

# 3. MEMORY.md bloat check
MEMORY_FILE=""
[[ -f "MEMORY.md" ]] && MEMORY_FILE="MEMORY.md"
[[ -f ".claude/MEMORY.md" ]] && MEMORY_FILE=".claude/MEMORY.md"
if [[ -n "$MEMORY_FILE" ]]; then
  MEMORY_LINES=$(wc -l < "$MEMORY_FILE" | tr -d ' ')
  if [[ "$MEMORY_LINES" -gt 200 ]]; then
    ERRORS+=("WARN: ${MEMORY_FILE} is ${MEMORY_LINES} lines (recommended: ≤200). Prune stale entries.")
  fi
fi

# 4. Run project-specific linter (only if present)
if [[ -f "package.json" ]] && grep -q '"lint"' "package.json" 2>/dev/null; then
  if ! npm run lint --silent 2>/dev/null; then
    ERRORS+=("FAIL: npm run lint failed. Fix lint errors before proceeding.")
  fi
elif [[ -f "pyproject.toml" ]] && command -v ruff &>/dev/null; then
  RUFF_OUTPUT=$(ruff check . 2>&1 || true)
  if [[ -n "$RUFF_OUTPUT" ]]; then
    RUFF_COUNT=$(echo "$RUFF_OUTPUT" | wc -l | tr -d ' ')
    ERRORS+=("WARN: ruff found ${RUFF_COUNT} issues. Run 'ruff check --fix .' to auto-fix.")
  fi
elif [[ -f "Gemfile" ]] && command -v rubocop &>/dev/null; then
  if ! rubocop --format quiet 2>/dev/null; then
    ERRORS+=("WARN: rubocop found issues.")
  fi
fi

# Output results
HAS_FAIL=false
if [[ ${#ERRORS[@]} -gt 0 ]]; then
  echo "[L2 Gate] Session check:"
  for err in "${ERRORS[@]}"; do
    echo "  - $err"
    if [[ "$err" == FAIL:* ]]; then
      HAS_FAIL=true
    fi
  done
fi

# Block on FAIL-level errors (WARN passes through)
if [[ "$HAS_FAIL" == true ]]; then
  exit 1
fi

exit 0
