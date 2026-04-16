---
description: "Features.json Validator — features.json의 기능 정의가 AI-DLC Phase 1 기준(구체성, 독립성, 검증성, 테스트)을 만족하는지 검증합니다. 'features validate', 'feature 검증', '기능 정의 검사' 시 트리거."
---

# Features.json Validator

AI-DLC Phase 1(Requirements)의 핵심: features.json 항목이 "좋은 기능 정의" 기준을 만족하는지 검증합니다.

## 검증 기준

각 기능 항목에 대해 4가지 품질 기준을 검사합니다:

### 1. 구체성 (Specificity)
- 검증 가능한 구체적 단계(steps)가 포함되어 있는가?
- BAD: "로그인 구현"
- GOOD: "이메일/비밀번호 기반 로그인, JWT 발급, 세션 쿠키 설정"

### 2. 독립성 (Independence)
- 다른 기능에 의존하지 않고 단독 구현/테스트 가능한가?
- dependencies 필드가 있다면 순환 의존성이 없는지 확인

### 3. 검증성 (Verifiability)
- steps 필드에 구체적이고 검증 가능한 단계가 나열되어 있는가?
- "잘 동작해야 함" 같은 모호한 기준이 아닌 명확한 통과/실패 조건

### 4. 테스트 (Testability)
- tests 필드에 구체적인 테스트 파일 경로가 지정되어 있는가?
- 빈 tests 필드는 실패로 처리

## 예상 features.json 구조

```json
{
  "features": [
    {
      "id": "auth-login",
      "name": "이메일/비밀번호 로그인",
      "description": "이메일과 비밀번호로 로그인하여 JWT를 발급받는다",
      "steps": [
        "POST /api/auth/login에 이메일/비밀번호 전송",
        "유효한 자격증명이면 JWT 토큰 반환",
        "응답 쿠키에 세션 토큰 설정",
        "잘못된 자격증명이면 401 반환"
      ],
      "tests": [
        "tests/auth/login.test.ts"
      ],
      "dependencies": [],
      "passes": false
    }
  ]
}
```

## 실행 방법

1. 프로젝트 루트에서 features.json을 Read
2. 각 기능 항목에 대해 4가지 기준 검사
3. 결과를 항목별로 리포트

## 출력 형식

```
## Features.json 검증 결과

### auth-login: 이메일/비밀번호 로그인
- [PASS] 구체성: 4개 검증 단계 포함
- [PASS] 독립성: 외부 의존성 없음
- [PASS] 검증성: 모든 steps가 검증 가능
- [PASS] 테스트: tests/auth/login.test.ts 경로 지정

### 전체 요약
총 N개 기능 중 M개 통과, K개 개선 필요
개선 필요 항목: ...
```

## 주의사항
- features.json이 없으면 템플릿 생성을 제안합니다
- passes 필드는 에이전트가 수정할 수 있는 유일한 필드입니다
- JSON 구조의 무결성도 함께 검사합니다
