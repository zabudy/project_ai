---
name: backend_dev
description: Backend development for Project AI — FastAPI endpoints, SQLAlchemy models, Alembic migrations, and OpenAI service integration. Use when creating or modifying backend code: API routes, database models, AI services, or migrations.
---

## Project Layout

```
backend/
├── routers/        # FastAPI routers, one per domain
├── services/       # Business logic; all AI code lives here
├── models/         # SQLAlchemy models
├── schemas/        # Pydantic request/response schemas
├── prompts/        # Prompt templates — never inline in code
└── tests/
```

## Key Patterns

**Endpoint** — validate with Pydantic, inject deps, delegate to service:
```python
@router.post("/summarize", response_model=SummaryResponse)
async def summarize(req: SummaryRequest, db: AsyncSession = Depends(get_db),
                    ai: AIService = Depends(get_ai_service)):
    return await ai.summarize(req.text, db)
```

**AI errors** — always handle explicitly:
```python
except openai.RateLimitError:
    raise HTTPException(429, "AI service is busy, please try again later")
except openai.APITimeoutError:
    raise HTTPException(504, "AI service did not respond in time")
```

**DB** — async sessions, no N+1 (use `joinedload`/`selectinload`), migration for every schema change.

## Validation Command
```bash
cd backend && ruff check . && black --check . && mypy src && pytest tests/ --maxfail=1
```
