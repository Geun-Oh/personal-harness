---
description: "Knowledge Pyramid Linter — CLAUDE.md와 문서 계층 구조(L0-L3)가 올바르게 구성되었는지 검사합니다. 'pyramid lint', 'check claude.md', '문서 구조 검사' 시 트리거."
---

# Knowledge Pyramid Linter

프로젝트의 Knowledge Pyramid(L0-L3) 구조를 검사하여 Context Rot을 방지합니다.

## 검사 항목

### L0: CLAUDE.md (진입점)
1. **줄 수 검사**: 100줄 이하인지 확인
2. **인덱스 역할**: 다음 레벨(L1) 문서로의 포인터가 있는지 확인
3. **빌드/테스트 명령**: 핵심 명령어가 포함되어 있는지 확인
4. **안티패턴 감지**: 300줄 이상의 모놀리식 구조 경고

### L1: 아키텍처/표준 문서
- ARCHITECTURE.md, CODING_STANDARDS.md 등 존재 여부
- L2로의 포인터 존재 여부

### L2: 설계 문서
- docs/design-docs/, docs/exec-plans/ 디렉토리 존재 여부

### L3: 참조/생성 문서
- references/, generated/ 디렉토리 존재 여부

## 실행 방법

현재 프로젝트 디렉토리에서 다음을 검사합니다:

1. CLAUDE.md를 Read하여 줄 수와 내용을 분석
2. AGENTS.md가 있다면 300줄 이상인지 검사 (안티패턴)
3. L1-L3 디렉토리/파일 존재 여부를 Glob으로 확인
4. 각 레벨에서 다음 레벨로의 포인터(링크/참조)가 있는지 확인

## 출력 형식

```
## Knowledge Pyramid 검사 결과

### L0: CLAUDE.md
- [PASS/FAIL] 줄 수: N줄 (권장: ≤100)
- [PASS/FAIL] L1 포인터 존재
- [PASS/FAIL] 빌드/테스트 명령 포함

### L1: 아키텍처 문서
- [PASS/FAIL] ARCHITECTURE.md 존재
- [PASS/FAIL] L2 포인터 존재

### L2: 설계 문서
- [PASS/FAIL] docs/ 디렉토리 존재

### L3: 참조 문서
- [INFO] references/ 디렉토리 존재 여부

### 안티패턴
- [WARN/PASS] 모놀리식 AGENTS.md (300줄+)

### 요약
총 N개 항목 중 M개 통과, K개 실패, J개 경고
다음 개선 액션: ...
```

## 주의사항
- 이 검사는 프로젝트 루트에서 실행되어야 합니다
- 파일이 없는 것 자체가 반드시 실패는 아닙니다 (L2, L3는 INFO 레벨)
- CLAUDE.md가 없으면 전체 검사를 건너뛰고 생성을 권장합니다
