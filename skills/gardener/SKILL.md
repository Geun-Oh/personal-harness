---
description: "Gardener Agent — 문서-코드 불일치, 미사용 export, 아키텍처 위반을 스캔하고 정리 PR을 제안합니다. 'gardener', '엔트로피 스캔', 'entropy', '정리' 시 트리거."
---

# Gardener Agent

에이전트는 인간보다 5-10배 빠르게 엔트로피를 축적합니다. Gardener Agent는 이를 지속적으로 관리합니다.

## 엔트로피 유형과 대응

| 엔트로피 유형 | 에이전트 코드 특성 | 감지 방법 |
|-------------|-----------------|----------|
| 코드 중복 | 대량 발생 | 유사 함수/블록 탐색 |
| 문서 드리프트 | 빠름 | 문서 ↔ 코드 불일치 비교 |
| 아키텍처 드리프트 | 무의식적 위반 | 의존성 규칙 위반 탐색 |
| 미사용 코드 | 빠르게 축적 | 미사용 export/import 감지 |

## 스캔 항목

### 1. 문서-코드 불일치
- README.md의 설치/사용법이 실제 코드와 일치하는지
- API 문서의 엔드포인트/파라미터가 실제 구현과 일치하는지
- CLAUDE.md의 빌드/테스트 명령이 실제로 동작하는지

### 2. 미사용 export 감지
- export된 함수/클래스가 다른 파일에서 import되는지
- 외부에서 사용되지 않는 public API

### 3. 아키텍처 위반 정기 검사
- 레이어 의존성 규칙 위반 (예: UI → Service는 OK, Service → UI는 위반)
- 순환 의존성 감지

### 4. 코드 중복 탐색
- 유사한 로직이 여러 파일에 반복되는 패턴

## 실행 방법

1. 프로젝트 구조를 Glob으로 파악
2. 주요 문서 파일과 소스 코드를 비교 분석
3. 미사용 export를 Grep으로 탐색
4. 의존성 방향 위반을 검사
5. 발견된 이슈를 심각도별로 분류
6. 정리 액션을 제안

## 출력 형식

```
## Gardener 엔트로피 스캔 결과

### 문서-코드 불일치 (2건)
1. [HIGH] README.md 설치 명령 `npm install` → 실제는 `pnpm install`
2. [MED] API.md에 /api/v2/users 엔드포인트 → 코드에 없음

### 미사용 export (3건)
1. [LOW] src/utils/format.ts: `formatDate` — 0 references
2. [LOW] src/helpers/validate.ts: `validateEmail` — 0 references
3. [LOW] src/lib/cache.ts: `clearAllCache` — 0 references

### 아키텍처 위반 (1건)
1. [HIGH] src/services/auth.ts → src/components/LoginForm.tsx
   Service 레이어가 UI를 직접 import — 역방향 의존성

### 코드 중복 (1건)
1. [MED] src/api/users.ts:45-60 ≈ src/api/posts.ts:30-45
   에러 핸들링 로직 중복 → 공통 미들웨어 추출 제안

### 요약
- Critical: 0 | High: 2 | Medium: 2 | Low: 3
- 추천: High 이슈 2건을 먼저 정리하세요
```

## 주기적 실행
- `/schedule`과 연동하여 주기적으로 실행할 수 있습니다
- PR 생성 전 자동 스캔으로 활용할 수 있습니다
