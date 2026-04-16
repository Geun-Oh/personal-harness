#!/usr/bin/env bash
# L4 Gate — PreToolUse(Bash) verification
# Detects PR creation commands and guides invocation of the gate-reviewer agent
# Code review agent trigger, 1-5 minutes

set -euo pipefail

COMMAND="${1:-}"

if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# Detect gh pr create or git push
if echo "$COMMAND" | grep -qE "(gh\s+pr\s+create|git\s+push)"; then
  echo "[L4 Gate] PR/Push detected:"
  echo "  - A code review via the gate-reviewer agent is recommended before creating a PR."
  echo "  - Run: Agent(subagent_type='personal-harness:gate-reviewer')"
  echo "  - To proceed without a review, ignore this warning."
fi

exit 0
