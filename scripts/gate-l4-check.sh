#!/usr/bin/env bash
# L4 Gate — PreToolUse(Bash) 검증
# PR 생성 명령 감지 시 gate-reviewer 에이전트 호출을 안내
# 코드 리뷰 에이전트 트리거, 1-5분

set -euo pipefail

COMMAND="${1:-}"

if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# gh pr create 또는 git push 감지
if echo "$COMMAND" | grep -qE "(gh\s+pr\s+create|git\s+push)"; then
  echo "[L4 Gate] PR/Push 감지:"
  echo "  - PR 생성 전 gate-reviewer 에이전트를 통한 코드 리뷰를 권장합니다."
  echo "  - 실행: Agent(subagent_type='personal-harness:gate-reviewer')"
  echo "  - 리뷰 없이 진행하려면 이 경고를 무시하세요."
fi

exit 0
