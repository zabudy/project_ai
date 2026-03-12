---
description: Execute an implementation plan for Project AI
argument-hint: [path-to-plan]
---

# Execute: Implement from Plan for Project AI

## Plan to Execute

Read plan file: `$ARGUMENTS`

## Execution Instructions

### 1. Read and Understand

- Read the ENTIRE plan carefully
- Understand all tasks and their dependencies
- Note the validation commands to run (especially AI-specific validations)
- Review the testing strategy (including mocking external AI services)

### 2. Execute Tasks in Order

For EACH task in "Step by Step Tasks":

#### a. Navigate to the task
- Identify the file and action required (`backend/src/`, `frontend/src/`, or `shared/`)
- Read existing related files if modifying
- Check for existing AI service integrations or prompts

#### b. Implement the task
- Follow the detailed specifications exactly
- Maintain consistency with existing code patterns
- Include proper type hints (Python/TypeScript) and docstrings
- Add structured logging (never print statements)
- For AI features:
  - Store prompts in dedicated files/modules
  - Implement proper error handling for AI service failures
  - Add timeout and retry logic for AI calls
  - Include token counting/cost tracking where relevant

#### c. Verify as you go
- After each file change, check syntax (`ruff` for Python, `eslint` for TS)
- Ensure imports are correct (follow import ordering from PROJECT.md)
- Verify types are properly defined (`mypy` for Python, `tsc` for TS)
- For AI integrations: verify API keys are not hardcoded

### 3. Implement Testing Strategy

After completing implementation tasks:

- Create all test files specified in the plan (`tests/unit/`, `tests/integration/`)
- Implement all test cases mentioned
- Follow the testing approach outlined
- Ensure tests cover edge cases (AI timeouts, rate limits, invalid responses)
- **Critical**: Mock ALL external AI services (never call real APIs in tests)
- Test both success and failure scenarios for AI calls

### 4. Run Validation Commands

Execute ALL validation commands from the plan in order:

```bash
# Backend validation
cd backend && ruff check src/ tests/
cd backend && black --check src/ tests/
cd backend && mypy src/
cd backend && pytest tests/unit --maxfail=1

# Frontend validation (if applicable)
cd frontend && npm run lint
cd frontend && npm run typecheck
cd frontend && npm test -- --ci --passWithNoTests

# E2E tests (if applicable)
playwright test
```

If any command fails:
- Fix the issue
- Re-run the command
- Continue only when it passes

### 5. AI-Specific Verification

For features involving AI integration:

- ✅ API keys are loaded from environment variables, never hardcoded
- ✅ Error handling for AI service unavailability
- ✅ Rate limiting implemented (if required by plan)
- ✅ Token counting/cost tracking added
- ✅ Prompts are versioned and documented
- ✅ Response validation (ensure AI returns expected format)
- ✅ Security: user input sanitized before sending to AI

### 6. Final Verification

Before completing:

- ✅ All tasks from plan completed
- ✅ All tests created and passing
- ✅ All validation commands pass
- ✅ Code follows project conventions (from PROJECT.md)
- ✅ AI integrations properly mocked in tests
- ✅ No API keys or secrets in code
- ✅ Documentation added/updated as needed
- ✅ Cost tracking considerations addressed

## Output Report

Provide summary:

### Completed Tasks
- List of all tasks completed
- Files created (with paths: `backend/src/services/ai_service.py`, etc.)
- Files modified (with paths)

### Tests Added
- Test files created (with paths)
- Test cases implemented (including AI mock tests)
- Test results (summary of passed/failed)

### AI-Specific Notes
- Prompts added/modified (location: `backend/src/services/prompts/`)
- Token usage estimates (if applicable)
- Error handling scenarios covered

### Validation Results
```bash
# Output from each validation command
# Example:
$ cd backend && pytest tests/unit -v
========================= test session starts =========================
collected 15 items
tests/unit/test_ai_service.py::test_generate_response PASSED
tests/unit/test_ai_service.py::test_handle_timeout PASSED
...
```

### Ready for Commit
- Confirm all changes are complete
- Confirm all validations pass
- Confirm no secrets exposed
- Ready for `/commit` command

## Notes

- If you encounter issues not addressed in the plan, document them in Open Questions
- If you need to deviate from the plan, explain why with justification
- If tests fail, fix implementation until they pass (especially AI mock tests)
- Don't skip validation steps
- For AI features: always consider cost, latency, and fallback options
- Remember to update `.env.example` if new environment variables are needed
