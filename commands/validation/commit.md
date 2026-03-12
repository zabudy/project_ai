---
description: Process to commit changes with proper validation for Project AI
---

# Commit: Validate and Commit Changes

## Changes to Commit

I have made the following changes:

[List or describe the changes made]

## Validation Process

### 1. Run Complete Validation Suite

Execute ALL validation commands to ensure code quality and functionality:

```bash
# Backend validation
cd backend && ruff check src/ tests/
cd backend && black --check src/ tests/
cd backend && mypy src/

# Frontend validation (if changes affect frontend)
cd frontend && npm run lint
cd frontend && npm run typecheck

# Run tests
cd backend && pytest tests/ -v
cd frontend && npm test -- --ci --passWithNoTests

# E2E tests (if applicable)
playwright test
```

### 2. AI-Specific Validation

For changes involving AI features:

- ✅ Verify no API keys are hardcoded
- ✅ Check that all AI calls have proper timeout handling
- ✅ Confirm error handling for AI service failures
- ✅ Verify token counting/cost tracking is updated
- ✅ Check that prompts are properly versioned
- ✅ Ensure AI responses are validated before use
- ✅ Confirm tests properly mock external AI services

### 3. Security Check

- ✅ No secrets committed (check `.env` files)
- ✅ No sensitive data in logs
- ✅ Input validation in place
- ✅ Output sanitized for AI responses

### 4. Manual Verification

- Test the feature manually (if applicable)
- Verify error messages are user-friendly
- Check logs for proper structured logging
- Verify cost tracking (if applicable)

## Commit Message

Once validation passes, commit with a conventional commit message:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types**: feat, fix, docs, style, refactor, test, chore
**Scope**: backend, frontend, ai-service, prompts, db, etc.

Examples:
- `feat(ai-service): add streaming support for chat completions`
- `fix(prompts): correct token counting for long inputs`
- `test(ai-service): add mocks for OpenAI API tests`

## Commit Command

```bash
git add .
git commit -m "<type>(<scope>): <description>"
```

## Post-Commit

- Push changes if ready: `git push`
- Create PR if applicable
- Update documentation if needed

## If Validation Fails

1. Fix the issues
2. Re-run validation
3. Repeat until all checks pass
4. Then commit

## Notes

- Never commit with failing tests
- Never commit with linting errors
- Never commit secrets or hardcoded keys
- For AI features: ensure cost implications are considered
