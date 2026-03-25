---
description: Process to fix bugs found in manual/AI code review for Project AI
---

# Code Review Fix for Project AI

I ran/performed a code review and found these issues:

**Code-review** (file or description of issues): $1

Please fix these issues one by one. If the Code-review is a file, read the entire file first to understand all of the issue(s) presented there.

**Scope**: $2

---

## Before Starting

1. **Read ALL issues** from the code review first
2. **Understand the context** - which part of Project AI is affected? (backend AI services, frontend components, prompts, tests)
3. **Check for AI-specific concerns**:
   - Are there issues with AI API error handling?
   - Are API keys exposed or hardcoded?
   - Is token counting/cost tracking missing?
   - Are prompts properly versioned?
   - Are tests mocking external AI calls correctly?

---

## Fix Process

For each fix:

### 1. Analyze the Issue
- **What was wrong?** (explain the problem)
- **Why is it a problem?** (impact on functionality, security, performance, cost)
- **Which component is affected?** (backend service, frontend hook, prompt, test)
- **Is this an AI-specific issue?** (error handling, cost, prompt injection, etc.)

### 2. Implement the Fix
- Show the code changes
- Follow Project AI conventions:
  - Python: snake_case, type hints, docstrings
  - TypeScript: camelCase, interfaces
  - AI services: proper async/await, timeout, retry logic
  - No hardcoded secrets
  - Structured logging instead of print

### 3. Add/Update Tests
- Create or modify tests to cover the fix
- For AI features: MOCK all external API calls
- Test both success and failure scenarios
- Verify error handling works
- Check token counting if applicable

### 4. Validate the Fix
- Run specific test for the fixed component
- Ensure no regressions
- Check linting and type checking

---

## After All Fixes

### 1. Run Full Validation

Execute the validation command from `commands/validation/commit.md`:

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
```

### 2. AI-Specific Final Checks

- ✅ No API keys or secrets in code (check for any hardcoded keys)
- ✅ All AI calls have proper timeout (30s default)
- ✅ Retry logic implemented for transient failures
- ✅ Error handling covers rate limits, timeouts, invalid responses
- ✅ Token counting/cost tracking included where relevant
- ✅ Prompts are in dedicated files/modules, not hardcoded
- ✅ Tests properly mock external AI services
- ✅ Input sanitized before sending to AI
- ✅ Output validated before returning to user

### 3. Document the Fixes

Provide summary:

| # | Issue | File | Fix | Test Added |
|---|-------|------|-----|------------|
| 1 | [Issue description] | `path/to/file.py` | [Brief fix description] | `test_file.py::test_name` |
| 2 | ... | ... | ... | ... |

---

## Example Fix Format

```markdown
### Fix #1: Missing timeout on OpenAI API call

**What was wrong:**
The `ai_service.py` was calling OpenAI API without setting a timeout. This could cause the request to hang indefinitely if the API is slow or unresponsive.

**Why it's a problem:**
- Users would experience infinite loading
- Server resources would be tied up waiting
- No fallback mechanism for slow responses

**Files affected:**
- `backend/src/services/ai_service.py`
- `tests/unit/test_ai_service.py`

**Fix implemented:**

```python
# BEFORE
async def generate_response(prompt: str):
    response = await openai.ChatCompletion.acreate(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": prompt}]
    )
    return response.choices[0].message.content

# AFTER
async def generate_response(prompt: str):
    try:
        response = await asyncio.wait_for(
            openai.ChatCompletion.acreate(
                model="gpt-3.5-turbo",
                messages=[{"role": "user", "content": prompt}]
            ),
            timeout=30.0  # 30 second timeout
        )
        return response.choices[0].message.content
    except asyncio.TimeoutError:
        logger.error("OpenAI API timeout")
        raise AITimeoutException("Request timed out after 30 seconds")
```

**Test added:**

```python
def test_generate_response_timeout(mocker):
    """Test that timeout is properly handled"""
    # Mock the OpenAI call to simulate timeout
    mocker.patch('openai.ChatCompletion.acreate', 
                 side_effect=asyncio.TimeoutError())
    
    with pytest.raises(AITimeoutException) as exc:
        asyncio.run(ai_service.generate_response("test"))
    
    assert "timed out" in str(exc.value).lower()
```

**Validation:**
```bash
cd backend && pytest tests/unit/test_ai_service.py::test_generate_response_timeout -v
✓ PASSED
```
```

---

## Common Project AI Issues to Watch For

### Backend Issues
- Missing timeout on AI API calls
- No retry logic for transient failures
- Hardcoded API keys
- Missing token counting
- Improper error handling (swallowing exceptions)
- No logging for AI failures
- Missing input validation/sanitization

### Frontend Issues
- No loading states during AI requests
- Poor error messages for users
- Missing retry UI for failed requests
- Not handling streaming responses correctly
- Exposing API keys in client-side code

### Prompt Issues
- Prompts hardcoded in services
- No versioning for prompts
- Missing prompt validation
- No testing for prompt effectiveness
- Prompt injection vulnerabilities

### Test Issues
- Tests calling real AI APIs (should be mocked)
- Missing error scenario tests
- No timeout/retry tests
- Low coverage for AI-specific code
- Not testing token counting logic

---

## Ready for Commit

After all fixes are complete and validated:

- [ ] All code review issues addressed
- [ ] All tests passing
- [ ] Linting and type checking passing
- [ ] No secrets exposed
- [ ] AI-specific checks passed
- [ ] Documentation updated if needed

Ready for `/commit` command.
