---
name: code_review
description: Code review for Project AI PRs. Use when reviewing a pull request or asked to review code. Checks PRD coverage, security, AI integration quality, and test completeness.
---

## Blockers (must fix before merge)

- [ ] `.env`, API keys, or tokens present in the code
- [ ] Real AI API calls in tests (must be mocked)
- [ ] AI-generated content rendered without sanitization
- [ ] PII logged anywhere
- [ ] CI failing (lint, typecheck, tests)
- [ ] PRD acceptance conditions not covered by tests

## Required Checks

**PRD coverage**
- [ ] All acceptance conditions implemented and tested
- [ ] Failure paths covered (AI timeout, rate limit, invalid response)

**AI integration**
- [ ] Prompts in `prompts/` — not hardcoded inline
- [ ] All error types handled: `RateLimitError`, `APITimeoutError`, etc.
- [ ] Graceful degradation on AI failure

**Code quality**
- [ ] Functions: single responsibility, short
- [ ] No magic strings/numbers — use constants
- [ ] No bare `except:` — specify exception type
- [ ] TypeScript: no `any`

**Database**
- [ ] New Alembic migration created for schema changes
- [ ] No N+1 queries

## Comment Labels

- `[blocker]` — must fix before merge
- `[suggestion]` — improves quality, optional
- `[question]` — clarifying intent
