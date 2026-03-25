---
name: testing
description: Writing tests for Project AI — pytest for backend, Playwright for E2E. Use when writing any tests: unit, integration, or E2E. Critical rule: AI services must always be mocked, never called for real in tests.
---

## Rules

- Every PRD acceptance condition → at least one test
- NEVER call real AI APIs — mock every time
- Test all AI failure paths: `RateLimitError`, `APITimeoutError`, invalid response
- Use fixtures and factories, not hardcoded data

## pytest — Mocking AI

```python
@pytest.fixture
def mock_openai(mocker):
    return mocker.patch(
        "services.ai_service.openai_client.chat.completions.create",
        return_value=MockOpenAIResponse(content="test response"),
    )

def test_summarize_rate_limit(client, mocker):
    mocker.patch(
        "services.ai_service.openai_client.chat.completions.create",
        side_effect=openai.RateLimitError("rate limit"),
    )
    assert client.post("/summarize", json={"text": "x"}).status_code == 429
```

## Playwright — Mocking API responses

```typescript
test("shows error when AI is unavailable", async ({ page }) => {
  await page.route("**/api/summarize", route => route.fulfill({ status: 504 }));
  await page.goto("/");
  await page.fill("#text-input", "test text");
  await page.click("#summarize-btn");
  await expect(page.locator(".error-message")).toBeVisible();
});
```

## Commands
```bash
pytest tests/ --maxfail=1
pytest --cov=src --cov-report=html
playwright test
```

## Checklist
- [ ] All PRD acceptance conditions covered
- [ ] No real AI API calls anywhere in tests
- [ ] RateLimitError, APITimeoutError, invalid response all tested
- [ ] Error path coverage > 80%
