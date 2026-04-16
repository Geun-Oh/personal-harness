---
description: "Feedback Encoding Ladder Tracker — 반복되는 피드백을 감지하고 더 강한 인코딩 레벨(Review Comment → Documentation → Tool Design → Linter/Test)로 승격을 제안합니다. 'feedback ladder', '피드백 추적', '반복 피드백' 시 트리거."
---

# Feedback Encoding Ladder Tracker

"같은 피드백을 2번 줘야 한다면, 그것은 시스템의 실패다." — OpenAI

동일한 교정 피드백이 반복될 때 자동으로 더 강한 레벨로 인코딩을 제안합니다.

## Encoding Ladder (약→강)

```
Level 1: Review Comment (가장 약함)
  → 에이전트가 읽을 수도, 무시할 수도 있음
  → 위치: 대화 중 피드백, PR 코멘트

Level 2: Documentation
  → docs/에 기록하여 지속성 확보
  → 위치: CLAUDE.md, CODING_STANDARDS.md, .claude/rules/*.md

Level 3: Tool Design
  → 도구 자체에 제약 내장
  → 위치: hooks.json의 PreToolUse/PostToolUse, 커스텀 도구 설명

Level 4: Linter/Test (가장 강함)
  → 위반 시 즉시 실패, 결정론적 강제
  → 위치: eslint rules, pytest fixtures, CI gates
```

## 영속 상태 관리

피드백 반복 횟수를 세션 간에 추적하기 위해 `.claude/feedback-ladder-state.json`을 사용합니다.

### State 파일 스키마

```json
{
  "version": 1,
  "feedbacks": [
    {
      "id": "no-merge-without-tests",
      "topic": "테스트 없이 머지하지 마세요",
      "keywords": ["test", "merge", "coverage"],
      "occurrences": 3,
      "first_seen": "2026-04-10",
      "last_seen": "2026-04-16",
      "current_level": 1,
      "current_location": "MEMORY.md feedback entry",
      "recommended_level": 4,
      "promoted": false
    }
  ]
}
```

### State 필드 설명
- `id`: 고유 식별자 (kebab-case)
- `topic`: 피드백 내용 요약
- `keywords`: 유사 피드백 매칭용 키워드
- `occurrences`: 누적 발생 횟수
- `current_level`: 현재 인코딩된 레벨 (1-4)
- `current_location`: 현재 인코딩된 위치
- `recommended_level`: 반복 횟수 기반 권장 레벨
- `promoted`: 승격 완료 여부

## 작동 방식

### 1. State 파일 로드
- `.claude/feedback-ladder-state.json`이 있으면 읽기
- 없으면 초기 스캔 수행 후 생성

### 2. 피드백 수집 및 매칭
- MEMORY.md의 feedback 타입 메모리 파일들을 스캔 → Level 1 항목
- .claude/rules/*.md 파일들을 분석 → Level 2-3 항목
- hooks.json의 검사 규칙 → Level 4 항목
- State 파일의 기존 항목과 키워드 매칭으로 동일 피드백 식별

### 3. 반복 감지 및 승격 규칙
- 1회: 기록만 (Level 1)
- 2회 반복: Documentation(Level 2)으로 승격 제안
- 3회 이상: Tool Design(Level 3) 또는 Linter/Test(Level 4)로 승격 제안

### 4. State 업데이트
- 새로 발견된 피드백을 state 파일에 추가
- occurrences, last_seen, recommended_level 업데이트
- state 파일을 Write로 저장

## 실행 방법

1. `.claude/feedback-ladder-state.json` 로드 (없으면 빈 상태로 시작)
2. MEMORY.md 디렉토리에서 feedback 타입 메모리 파일들을 Glob/Read
3. .claude/rules/*.md 파일들을 Read
4. hooks.json을 Read하여 기존 Level 4 인코딩 확인
5. 각 피드백의 현재 레벨과 반복 횟수를 State와 대조
6. 승격이 필요한 항목 리포트
7. State 파일 업데이트 (Write)

## 출력 형식

```
## Feedback Encoding Ladder 분석

### 상태 파일: .claude/feedback-ladder-state.json
- 추적 중인 피드백: N개
- 승격 필요: M개

### 승격 필요 항목

#### 1. "테스트 없이 머지하지 마세요" (id: no-merge-without-tests)
- 현재 레벨: Level 1 (Review Comment) — MEMORY.md에 기록됨
- 반복 횟수: 3회 (2026-04-10 ~ 2026-04-16)
- 권장 레벨: Level 4 (Linter/Test)
- 제안 액션: CI에 테스트 커버리지 게이트 추가
  ```yaml
  # .github/workflows/ci.yml
  - run: npm test -- --coverage --coverageThreshold='{"global":{"branches":80}}'
  ```

#### 2. "import 순서를 지켜주세요" (id: import-order)
- 현재 레벨: Level 2 (Documentation) — CODING_STANDARDS.md에 기록됨
- 반복 횟수: 2회
- 권장 레벨: Level 4 (Linter/Test)
- 제안 액션: eslint-plugin-import 규칙 추가

### 이미 적절하게 인코딩된 항목
- "하드코딩 시크릿 금지" → Level 4 (gate-l1-check.sh) ✅

### 요약
- 총 N개 피드백 클러스터
- M개가 현재 레벨보다 강한 인코딩 필요
- 가장 시급한 승격: ...
```

## 연동
- Claude Code의 memory 시스템과 연동 (feedback 타입 메모리 파일 스캔)
- .claude/rules/에 인코딩된 피드백은 Level 2-3으로 인식
- hooks.json에 인코딩된 검사는 Level 4로 인식
- State 파일로 세션 간 추적 영속화
