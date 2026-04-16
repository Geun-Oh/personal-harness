---
description: "Harness Maturity Assessor — Diagnoses a project's AI-DLC maturity level (L0-L4) and provides gap analysis and action items for the next level. Triggers on 'harness assess', 'maturity assessment', 'maturity'."
---

# Harness Maturity Assessor

Scans the project and diagnoses its current position (L0-L4) against the AI-DLC maturity model.

## Maturity Model

| Level | Name | Supervision Paradigm | Key Characteristics |
|-------|------|-------------|----------|
| L0 | Ad-hoc | Step-by-step approval | No harness, agent = code generator |
| L1 | Basic Harness | + Deterministic gates | AGENTS.md + basic linter/tests |
| L2 | Automated Feedback | Monitor-and-intervene | Self-review loops, hooks |
| L3 | Multi-Agent | Risk-Autonomy matrix | Role separation, automated entropy management |
| L4 | Self-Evolving | Exception-based intervention | Harness itself improved by agents |

## Diagnostic Checklist

### L1 Criteria (Basic Harness)
- [ ] CLAUDE.md or AGENTS.md exists
- [ ] Linter configuration exists (eslint, ruff, golangci-lint, etc.)
- [ ] Test framework configuration exists
- [ ] .gitignore properly configured
- [ ] Build/test commands documented

### L2 Criteria (Automated Feedback)
- [ ] .claude/settings.json exists (hooks configuration)
- [ ] hooks/ directory or hooks.json exists
- [ ] CI/CD pipeline exists (.github/workflows/, etc.)
- [ ] Code review automation (review bot, CODEOWNERS)
- [ ] Observability tooling integrated (LangFuse, logging, etc.)

### L3 Criteria (Multi-Agent)
- [ ] Agent role separation (coder, reviewer, gardener, etc.)
- [ ] Role-specific agent definitions in agents/ directory
- [ ] Automated entropy management (cleanup scripts, gardener)
- [ ] Permission hierarchy configured (Tier 1/2/3)
- [ ] Sandbox/isolation configured

### L4 Criteria (Self-Evolving)
- [ ] Eval pipeline exists
- [ ] Automated harness improvement mechanism
- [ ] Trace-based feedback loop
- [ ] Automated performance metric collection/reporting

## How to Run

1. Use Glob/Read from the project root to verify existence of files/directories for each criterion
2. Calculate fulfillment rate for each level
3. Determine current level (achieved when ≥80% of level criteria are met)
4. Gap analysis for the next level
5. Present concrete action items

## Output Format

```
## Harness Maturity Assessment Results

### Current Level: L1 (Basic Harness)

### Fulfillment Rate by Level
| Level | Met | Unmet | Rate |
|-------|------|--------|--------|
| L1 | 4/5 | 1 | 80% ✅ |
| L2 | 2/5 | 3 | 40% |
| L3 | 0/5 | 5 | 0% |
| L4 | 0/4 | 4 | 0% |

### Gap Analysis for L2
Unmet items:
1. ❌ No hooks configuration
   → Action: Add PostToolUse hook to .claude/settings.json
2. ❌ No CI/CD pipeline
   → Action: Create .github/workflows/ci.yml
3. ❌ No observability tooling
   → Action: Integrate LangFuse or configure logging

### Recommended Next Steps
1. [Lowest effort] Create hooks.json → activate L1 immediate verification
2. [Highest impact] Add CI pipeline → secure automated verification
3. ...
```

## Deployment Overhang Warning

The diagnostic results also include:
- Whether the harness is making sufficient use of the current model's capabilities
- Whether "the autonomy the model actually exercises < the autonomy it can handle"
