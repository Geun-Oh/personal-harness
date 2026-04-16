---
description: "Context Budget Monitor — 컨텍스트 윈도우 예산 비율(CLAUDE.md ≤5%, rules ≤3%, MEMORY.md ≤2%, 실제 작업 ≥80%)을 분석하고 비만 증상을 경고합니다. 'context budget', '컨텍스트 예산', '토큰 비율' 시 트리거."
---

# Context Budget Monitor

컨텍스트 윈도우의 예산 배분을 분석하여 Context Rot을 조기 경고합니다.

## 예산 기준표

| 소스 | 권장 비율 | 설명 |
|------|----------|------|
| CLAUDE.md | ≤5% | 목차 역할, 100줄 이내 |
| .claude/rules/ | ≤3% | 활성화된 규칙만 |
| MEMORY.md | ≤2% | 200줄 이내 |
| Tool definitions | ≤10% | 도구 수 최소화 |
| 실제 작업 컨텍스트 | ≥80% | 코드, 테스트, 에러 로그 |

## 측정 방법

각 파일의 대략적인 토큰 수를 추정합니다 (1 토큰 ≈ 4 characters / 한국어 1 토큰 ≈ 1.5 characters):

1. CLAUDE.md 읽기 → 줄 수, 문자 수, 추정 토큰 수
2. .claude/rules/*.md 전체 읽기 → 합산
3. MEMORY.md 읽기 → 줄 수, 문자 수
4. 전체 비율 계산

## 비만 증상 감지

다음 증상이 있으면 경고합니다:
- CLAUDE.md가 100줄 초과
- MEMORY.md가 200줄 초과
- rules 파일 총합이 컨텍스트의 3% 초과 추정
- 단일 규칙 파일이 50줄 초과

## 출력 형식

```
## Context Budget 분석

### 현재 배분
| 소스 | 줄 수 | 추정 토큰 | 비율 | 상태 |
|------|------|----------|------|------|
| CLAUDE.md | N | ~T | X% | OK/WARN |
| rules/ | N | ~T | X% | OK/WARN |
| MEMORY.md | N | ~T | X% | OK/WARN |

### 비만 증상
- [WARN] CLAUDE.md 150줄 — 100줄 이하로 줄이세요
- [OK] 반복 파일 읽기 패턴 없음

### 권장 조치
1. CLAUDE.md에서 세부 내용을 L1 문서로 이동
2. ...
```

## 주의사항
- 토큰 수는 추정치입니다 (정확한 토큰화는 모델마다 다름)
- 이 검사는 정적 파일 기준입니다. 런타임 컨텍스트 소비는 측정하지 않습니다
- Hook 버전(#6 Gate Runner)과 연동하면 실시간 모니터링이 가능합니다
