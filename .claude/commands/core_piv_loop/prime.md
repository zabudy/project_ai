---
description: Prime agent with codebase understanding for Project AI
---

# Prime: Load Project Context for Project AI

## Objective

Build comprehensive understanding of the Project AI codebase by analyzing structure, documentation, and key files.

## Process

### 1. Analyze Project Structure

List all tracked files:
!`git ls-files`

Show directory structure:
On Linux, run: `tree -L 3 -I 'node_modules|__pycache__|.git|dist|build|*.pyc|.pytest_cache|.mypy_cache|.ruff_cache'`

### 2. Read Core Documentation

- Read `AGENTS.md` - Universal agent instructions for Project AI
- Read `PROJECT.md` - Project-specific configuration and standards
- Read `README.md` at project root
- Read any architecture documentation in `docs/architecture/`
- Read existing PRDs in `docs/prds/` to understand feature history

### 3. Identify Key Files

Based on the structure, identify and read:

**Backend Core:**
- `backend/src/main.py` - Main application entry point
- `backend/src/core/config.py` - Configuration management (Pydantic settings)
- `backend/src/api/routes/` - API endpoint definitions
- `backend/src/services/ai_service.py` - Core AI integration
- `backend/src/services/prompt_service.py` - Prompt management
- `backend/src/models/` - Data models and schemas

**Frontend Core:**
- `frontend/src/App.tsx` - Main React component
- `frontend/src/hooks/useAI.ts` - AI interaction hooks
- `frontend/src/services/api.ts` - API client
- `frontend/src/types/` - TypeScript type definitions

**Configuration:**
- `backend/pyproject.toml` - Python dependencies and tool config
- `frontend/package.json` - Node.js dependencies
- `backend/.env.example` - Environment variables template

**Testing:**
- `tests/unit/test_ai_service.py` - AI service tests with mocks
- `tests/integration/` - Integration test examples

### 4. Understand Current State

Check recent activity:
!`git log -10 --oneline`

Check current branch and status:
!`git status`

Check for uncommitted AI-related changes:
!`git diff -- '*.py' '*.ts' '*.tsx'`

### 5. AI-Specific Context Gathering

- Check which AI providers are configured (OpenAI, Anthropic)
- Review existing prompt templates in `backend/src/services/prompts/`
- Understand current cost tracking implementation
- Review error handling patterns for AI services
- Check test mocking strategies for external AI APIs

## Output Report

Provide a concise summary covering:

### Project Overview
- **Purpose**: AI-powered application for [core functionality - text generation, summarization, etc.]
- **Type**: Full-stack web application with Python/FastAPI backend and React frontend
- **Primary Goal**: Provide intelligent AI assistance through natural language interactions
- **Current Version**: MVP phase (v0.1)

### Architecture
```
Frontend (React) → Backend API (FastAPI) → Service Layer → AI Provider (OpenAI)
                                         ↓
                                    Repository → Database (PostgreSQL)
                                         ↓
                                    Cost Tracker → Monitoring
```
- **Backend**: Modular FastAPI application with clear separation of concerns
- **Frontend**: React with custom hooks for AI interactions
- **AI Integration**: Abstracted service layer supporting multiple providers
- **Data Flow**: Request → Validation → AI Processing → Response → Storage (async)

### Tech Stack

**Backend:**
- Language: Python 3.12
- Framework: FastAPI
- AI Integration: OpenAI Python Library, optional LangChain
- Database: PostgreSQL 15 / SQLite (dev)
- Testing: pytest, pytest-asyncio, pytest-mock
- Code Quality: Ruff, Black, mypy (strict)

**Frontend:**
- Language: TypeScript, React 18
- State Management: React Query, Context API
- HTTP Client: Axios
- Testing: Jest, Playwright (E2E)
- Code Quality: ESLint, Prettier

### Core Principles

**AI Integration:**
- All external AI calls are async with timeouts (30s default)
- Retry logic for transient failures (3 attempts with exponential backoff)
- Comprehensive error handling with custom exceptions
- Token counting and cost tracking for all requests
- Prompts stored in dedicated modules, versioned

**Testing:**
- ALL external AI APIs are mocked in tests
- Factories and fixtures for test data
- Coverage for success and failure scenarios
- Unit tests for each component, integration tests for workflows

**Code Quality:**
- Strict type checking (mypy strict mode, TypeScript strict)
- Functions under 50 lines, single responsibility
- No hardcoded secrets (always from environment)
- Structured logging, never print statements
- Follow import ordering (external → internal → relative)

### Current State

- **Active Branch**: `main` (or feature branch if in development)
- **Recent Changes**: [From git log - initial setup, AI integration, etc.]
- **AI Configuration**: OpenAI API configured, optional Anthropic support
- **Key Files to Note**:
  - `backend/src/services/ai_service.py` - Core AI logic, retry patterns
  - `backend/src/services/cost_tracker.py` - Usage monitoring
  - `frontend/src/hooks/useAI.ts` - React hook pattern for AI
  - `tests/unit/test_ai_service.py` - Mocking examples

### Immediate Observations

- ✅ Environment variables properly externalized (`.env.example`)
- ✅ Comprehensive error handling for AI failures
- ✅ Strong test coverage with proper mocking
- ✅ Cost tracking implemented at service level
- ⚠️ Check if rate limiting is implemented
- ⚠️ Verify prompt injection protections
- ⚠️ Confirm caching strategy for repeated queries

### Key Contacts / Documentation

- **Main Documentation**: `PROJECT.md`, `AGENTS.md`
- **PRD Location**: `docs/prds/project_ai_prd.md`
- **Architecture Decisions**: `docs/architecture/`
- **Plan Directory**: `.agents/plans/` (if exists)

This summary provides complete context for working with Project AI - all subsequent tasks can reference this baseline understanding.
