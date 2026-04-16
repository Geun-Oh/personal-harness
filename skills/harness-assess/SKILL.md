---
description: "Harness Maturity Assessor — 프로젝트의 AI-DLC 성숙도(L0-L4)를 진단하고 다음 단계를 위한 갭 분석과 액션 아이템을 제공합니다. 'harness assess', '성숙도 진단', 'maturity' 시 트리거."
---

# Harness Maturity Assessor

프로젝트를 스캔하여 AI-DLC 성숙도 모델 기준 현재 위치(L0-L4)를 진단합니다.

## 성숙도 모델

| Level | 이름 | 감독 패러다임 | 핵심 특징 |
|-------|------|-------------|----------|
| L0 | Ad-hoc | Step-by-step approval | 하네스 없음, 에이전트 = 코드 생성기 |
| L1 | Basic Harness | + Deterministic gates | AGENTS.md + 기본 린터/테스트 |
| L2 | Automated Feedback | Monitor-and-intervene | 자가 리뷰 루프, hooks |
| L3 | Multi-Agent | Risk-Autonomy 매트릭스 | 역할 분리, 자동 엔트로피 관리 |
| L4 | Self-Evolving | 예외 기반 개입 | 하네스 자체가 에이전트에 의해 개선 |

## 진단 체크리스트

### L1 조건 (Basic Harness)
- [ ] CLAUDE.md 또는 AGENTS.md 존재
- [ ] 린터 설정 존재 (eslint, ruff, golangci-lint 등)
- [ ] 테스트 프레임워크 설정 존재
- [ ] .gitignore 적절히 구성
- [ ] 빌드/테스트 명령이 문서화됨

### L2 조건 (Automated Feedback)
- [ ] .claude/settings.json 존재 (hooks 설정)
- [ ] hooks/ 디렉토리 또는 hooks.json 존재
- [ ] CI/CD 파이프라인 존재 (.github/workflows/, etc.)
- [ ] 코드 리뷰 자동화 (리뷰 봇, CODEOWNERS)
- [ ] 관찰성 도구 연동 (LangFuse, 로깅 등)

### L3 조건 (Multi-Agent)
- [ ] 에이전트 역할 분리 (coder, reviewer, gardener 등)
- [ ] agents/ 디렉토리에 역할별 에이전트 정의
- [ ] 자동 엔트로피 관리 (정리 스크립트, gardener)
- [ ] 권한 계층 설정 (Tier 1/2/3)
- [ ] 샌드박스/격리 설정

### L4 조건 (Self-Evolving)
- [ ] Eval 파이프라인 존재
- [ ] 하네스 자동 개선 메커니즘
- [ ] 트레이스 기반 피드백 루프
- [ ] 성능 지표 자동 수집/보고

## 실행 방법

1. 프로젝트 루트에서 Glob/Read로 각 조건의 파일/디렉토리 존재 여부 확인
2. 각 레벨의 충족률 계산
3. 현재 레벨 판정 (해당 레벨 조건 80% 이상 충족 시 달성)
4. 다음 레벨을 위한 갭 분석
5. 구체적 액션 아이템 제시

## 출력 형식

```
## Harness 성숙도 진단 결과

### 현재 레벨: L1 (Basic Harness)

### 레벨별 충족률
| Level | 충족 | 미충족 | 충족률 |
|-------|------|--------|--------|
| L1 | 4/5 | 1 | 80% ✅ |
| L2 | 2/5 | 3 | 40% |
| L3 | 0/5 | 5 | 0% |
| L4 | 0/4 | 4 | 0% |

### L2 달성을 위한 갭 분석
미충족 항목:
1. ❌ hooks 설정 없음
   → 액션: .claude/settings.json에 PostToolUse hook 추가
2. ❌ CI/CD 파이프라인 없음
   → 액션: .github/workflows/ci.yml 생성
3. ❌ 관찰성 도구 없음
   → 액션: LangFuse 연동 또는 로깅 설정

### 추천 다음 단계
1. [가장 낮은 노력] hooks.json 생성 → L1 즉시 검증 활성화
2. [가장 높은 임팩트] CI 파이프라인 추가 → 자동 검증 확보
3. ...
```

## Deployment Overhang 경고

진단 결과에 다음도 포함합니다:
- 현재 모델의 능력 대비 하네스가 충분히 활용하고 있는지
- "모델이 실제로 행사하는 자율성 < 처리할 수 있는 자율성" 여부
