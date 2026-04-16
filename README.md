# personal-harness

Harness Engineering toolkit for Claude Code — AI-DLC 발표 자료 기반 7가지 도구.

## 설치

```bash
# 마켓플레이스 등록
/plugin marketplace add Geun-Oh/personal-harness

# 설치
/plugin install personal-harness@personal-harness
```

로컬 개발 시:
```bash
claude --plugin-dir ./personal-harness
```

## 도구 목록

### Skills (수동 호출)

| 스킬 | 명령어 | 대응 패턴 |
|------|--------|----------|
| Knowledge Pyramid Linter | `/personal-harness:pyramid-lint` | Knowledge Pyramid, Progressive Disclosure |
| Features.json Validator | `/personal-harness:features-validate` | AI-DLC Phase 1 (Requirements) |
| Context Budget Monitor | `/personal-harness:context-budget` | Context Rot, Context Budget |
| Harness Maturity Assessor | `/personal-harness:harness-assess` | 성숙도 모델 L0→L4 |
| Feedback Encoding Ladder | `/personal-harness:feedback-ladder` | Feedback Encoding Ladder |
| Gardener Agent | `/personal-harness:gardener` | Entropy Management |

### Hooks (자동 실행)

| Gate | 트리거 | 시간 | 검사 내용 |
|------|--------|------|----------|
| L1 | 매 파일 수정 (PostToolUse) | 0-3초 | syntax, 파일 크기, 시크릿, 금지 패턴 |
| L2 | 턴 종료 (Stop) | 5-30초 | CLAUDE.md/AGENTS.md 크기, 린터 |
| L3 | 턴 종료 (Stop, L2 이후) | 30초-5분 | 단위/통합 테스트 실행 |
| L4 | PR/Push 전 (PreToolUse) | 즉시 | gate-reviewer 에이전트 호출 안내 |
| Budget | 턴 종료 (Stop) | 즉시 | 컨텍스트 예산 비만 증상 |

### Agents (위임 호출)

| 에이전트 | 모델 | 역할 |
|---------|------|------|
| gardener | Sonnet | 엔트로피 스캔 (읽기 전용) |
| gate-reviewer | Opus | L4 코드 리뷰 (보안/아키텍처) |

## 계층적 피드백 루프 (L1-L5)

```
L1 매 파일 수정   →  syntax, 시크릿 (CRITICAL 시 차단)
L2 턴 종료        →  린터, 구조 검사
L3 L2 통과 후     →  테스트 실행 (실패 시 차단)
L4 PR 생성 전     →  리뷰 에이전트 권장
L5 PR 생성 후     →  인간 최종 승인 (플러그인 범위 밖)
```

## PDF 패턴 커버리지

### 구현 완료
- Context Engineering: Context Rot, Knowledge Pyramid, Context Budget
- Feedback Loops: Feedback Encoding Ladder, Hierarchical Verification (L1-L4), Agent-Friendly Errors
- Entropy Management: Gardener Agent
- AI-DLC: Phase 1 Requirements (features.json), 성숙도 모델 (L0-L4)

### 향후 구현 예정
- Architectural Constraints: Swiss Cheese Trust Model, Boundary-Based Security
- Agent Patterns: Two-Agent System (Generator/Evaluator), Reasoning Sandwich
- State Persistence: Triple Redundancy (Git + features.json + progress.txt)
- Cost Optimization: Model Routing, Prompt Caching, Tool Search
- Agent Patterns: Dark Factory, 10 Collaboration Patterns

## 참고

이 플러그인은 [Harness Engineering & AI-DLC](https://github.com/Geun-Oh/personal-harness) 발표 자료의 패턴을 Claude Code 도구로 구현한 것입니다.
