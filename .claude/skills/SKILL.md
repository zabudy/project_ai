---
name: project-ai
description: Entry point for all work in the Project AI repository (FastAPI + React 18 + OpenAI). Read before any task. Contains non-negotiable rules and routes to the correct skill.
---

Read `PROJECT.md` for commands. Read `AGENTS.md` for the agent pipeline.

## Skill Routing

| Task | Skill |
|---|---|
| Backend — FastAPI, SQLAlchemy, AI services | `backend_dev` |
| Frontend — React 18, TypeScript | `frontend_dev` |
| Write tests — pytest, Playwright | `testing` |
| Review a PR | `code_review` |

## Non-Negotiable Rules

- No implementation without a PRD in `docs/prds/`
- NEVER commit `.env`, API keys, or tokens
- NEVER call real AI APIs in tests — mock them
- NEVER log PII or secrets
- Sanitize AI-generated content before rendering to the user