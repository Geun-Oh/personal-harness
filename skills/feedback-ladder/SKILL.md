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

Level 2: Documentation
  → docs/에 기록하여 지속성 확보

Level 3: Tool Design
  → 도구 자체에 제약 내장

Level 4: Linter/Test (가장 강함)
  → 위반 시 즉시 실패, 결정론적 강제
```

## 작동 방식

### 1. 피드백 수집
- MEMORY.md의 feedback 타입 메모리를 스캔
- .claude/rules/ 내의 규칙들을 분석
- 최근 대화에서 반복된 교정 패턴 식별

### 2. 반복 감지
- 유사한 주제의 피드백이 2회 이상 기록되어 있는지 확인
- 키워드 클러스터링으로 동일 피드백 그룹핑

### 3. 승격 제안
- 2회 반복: Documentation 레벨로 승격 제안
- 3회 이상: Tool Design 또는 Linter/Test 레벨로 승격 제안

## 실행 방법

1. MEMORY.md에서 feedback 타입 메모리 파일들을 읽기
2. .claude/rules/*.md 파일들을 읽기
3. 중복/유사 피드백 클러스터 식별
4. 각 클러스터의 현재 인코딩 레벨 판단
5. 승격이 필요한 항목 리포트

## 출력 형식

```
## Feedback Encoding Ladder 분석

### 반복 피드백 감지됨

#### 클러스터 1: "테스트 없이 머지하지 마세요"
- 현재 레벨: Level 1 (Review Comment) — MEMORY.md에 기록됨
- 반복 횟수: 3회
- 권장 레벨: Level 4 (Linter/Test)
- 제안 액션: CI에 테스트 커버리지 게이트 추가
  ```yaml
  # .github/workflows/ci.yml
  - run: npm test -- --coverage --coverageThreshold='{"global":{"branches":80}}'
  ```

#### 클러스터 2: "import 순서를 지켜주세요"
- 현재 레벨: Level 2 (Documentation) — CODING_STANDARDS.md에 기록됨
- 반복 횟수: 2회
- 권장 레벨: Level 4 (Linter/Test)
- 제안 액션: eslint-plugin-import 규칙 추가

### 요약
- 총 N개 피드백 클러스터 발견
- M개가 현재 레벨보다 강한 인코딩 필요
- 가장 시급한 승격: ...
```

## 연동
- Claude Code의 memory 시스템과 자연스럽게 연동됩니다
- .claude/rules/에 이미 인코딩된 피드백은 Level 2-3으로 인식합니다
- hooks.json에 인코딩된 검사는 Level 4로 인식합니다
