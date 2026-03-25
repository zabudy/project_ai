---
description: "Create comprehensive feature plan for Project AI with deep codebase analysis and research"
---

# Plan a new task for Project AI

## Feature: $ARGUMENTS

## Mission

Transform a feature request into a **comprehensive implementation plan** through systematic codebase analysis, external research, and strategic planning.

**Core Principle**: We do NOT write code in this phase. Our goal is to create a context-rich implementation plan that enables one-pass implementation success for AI agents working on Project AI.

**Key Philosophy**: Context is King. The plan must contain ALL information needed for implementation - patterns, mandatory reading, documentation, validation commands - so the execution agent succeeds on the first attempt.

---

## Planning Process

### Phase 1: Feature Understanding

**Deep Feature Analysis:**

- Extract the core problem being solved with AI capabilities
- Identify user value and business impact (cost, speed, quality)
- Determine feature type: New Capability/Enhancement/Refactor/Bug Fix
- Assess complexity: Low/Medium/High (consider AI integration complexity)
- Map affected systems: Backend AI services, Frontend components, Database

**Create User Story Format Or Refine If Story Was Provided By The User:**

```
As a <type of user> (e.g., Data Analyst, Developer, End User)
I want to <action/goal> (e.g., generate insights from text, summarize documents)
So that <benefit/value> (e.g., save time, improve decision making)
```

### Phase 2: Codebase Intelligence Gathering for Project AI

**Use specialized agents and parallel analysis:**

**1. Project Structure Analysis**

- Detect primary language(s): Python 3.12 (backend), TypeScript/React 18 (frontend)
- Map directory structure (`backend/src/`, `frontend/src/`, `shared/`)
- Identify service/component boundaries:
  - `backend/src/services/ai_service.py` - Core AI integration
  - `backend/src/services/prompt_service.py` - Prompt management
  - `backend/src/services/cost_tracker.py` - Token/cost monitoring
- Locate configuration files:
  - `backend/pyproject.toml` - Python dependencies and tools
  - `frontend/package.json` - Node.js dependencies
  - `backend/.env.example` - Environment variables template
- Find environment setup and build processes (docker, Makefile)

**2. Pattern Recognition** (Use specialized subagents when beneficial)

- Search for similar AI feature implementations in codebase
- Identify coding conventions:
  - **Python**: `snake_case` functions/variables, `PascalCase` classes
  - **TypeScript**: `camelCase` functions, `PascalCase` components
  - **Imports**: External → Internal → Relative (see PROJECT.md)
  - **File organization**: Feature-based modular structure
- Extract common patterns:
  - AI service integration pattern (async/await, retry logic)
  - Error handling pattern (custom exceptions in `core/exceptions.py`)
  - Logging pattern (structured logging, never print)
  - Prompt management pattern (separate files/modules)
  - Testing pattern (mock all external AI calls)
- Document anti-patterns to avoid:
  - Hardcoded API keys
  - Missing timeout on AI calls
  - No fallback for AI service failures
  - Direct printing instead of logging
- Check `AGENTS.md` and `PROJECT.md` for project-specific rules

**3. Dependency Analysis**

- Catalog external libraries relevant to feature:
  - **AI/ML**: `openai`, `anthropic`, `langchain` (optional)
  - **Backend**: `fastapi`, `sqlalchemy`, `pydantic`
  - **Frontend**: `react`, `react-query`, `axios`
- Understand how libraries are integrated (check imports in existing files)
- Find relevant documentation in `docs/`, or external official docs
- Note library versions and compatibility requirements from `PROJECT.md`

**4. Testing Patterns**

- Identify test framework: `pytest` (backend), `Jest` (frontend), `Playwright` (E2E)
- Find similar test examples in `tests/unit/` and `tests/integration/`
- Understand test organization: unit vs integration vs E2E
- Note coverage requirements and testing standards (mock external services)

**5. Integration Points**

- Identify existing files that need updates:
  - `backend/src/api/routes/` - New API endpoints
  - `backend/src/services/` - New or modified services
  - `frontend/src/components/` - New UI components
  - `frontend/src/hooks/` - New custom hooks for AI features
- Determine new files that need creation and their locations
- Map router/API registration patterns (FastAPI routers)
- Understand database/model patterns if applicable (SQLAlchemy)
- Identify authentication/authorization patterns if relevant

**Clarify Ambiguities:**

- If requirements are unclear at this point, ask the user to clarify before you continue
- Get specific implementation preferences (which AI model? streaming vs non-streaming?)
- Resolve architectural decisions before proceeding
- Clarify cost/budget constraints for AI API usage

### Phase 3: External Research & Documentation for AI Features

**Use specialized subagents when beneficial for external research:**

**Documentation Gathering:**

- Research latest library versions and best practices for AI APIs
- Find official documentation with specific section anchors:
  - OpenAI API reference (chat completions, streaming, function calling)
  - Anthropic Claude API documentation
  - LangChain integration guides (if applicable)
- Locate implementation examples and tutorials
- Identify common gotchas and known issues:
  - Rate limiting handling
  - Token counting accuracy
  - Streaming vs non-streaming tradeoffs
  - Cost optimization strategies
- Check for breaking changes and migration guides

**Technology Trends:**

- Research current best practices for AI-powered applications
- Find relevant blog posts, guides, or case studies on prompt engineering
- Identify performance optimization patterns (caching, batching)
- Document security considerations (prompt injection, data privacy)

**Compile Research References:**

```markdown
## Relevant Documentation

- [OpenAI API Reference](https://platform.openai.com/docs/api-reference/chat)
  - Chat Completions section
  - Why: Core API for text generation feature
- [Anthropic Claude Documentation](https://docs.anthropic.com/claude/reference/)
  - Messages API section
  - Why: Alternative AI provider integration
- [FastAPI Background Tasks](https://fastapi.tiangolo.com/tutorial/background-tasks/)
  - Why: For async AI processing without blocking
- [React Query Documentation](https://tanstack.com/query/latest/docs/react/overview)
  - Mutations and caching section
  - Why: Managing AI request state on frontend
```

### Phase 4: Deep Strategic Thinking for AI Features

**Think Harder About:**

- How does this AI feature fit into the existing architecture?
- What are the critical dependencies and order of operations?
- What could go wrong? (AI timeouts, rate limits, invalid responses, high costs)
- How will this be tested comprehensively? (mocking AI APIs)
- What performance implications exist? (latency, streaming vs waiting)
- Are there security considerations? (prompt injection, data leakage)
- How maintainable is this approach? (prompt versioning, model updates)
- Cost implications: token usage estimation and monitoring
- Fallback strategies: what happens when AI is unavailable?

**Design Decisions:**

- Choose between alternative approaches with clear rationale:
  - Streaming vs non-streaming responses
  - Synchronous vs background processing
  - Single model vs model selection based on task
  - Caching strategy for repeated queries
- Design for extensibility and future modifications (easy to add new models)
- Plan for backward compatibility if needed (API versioning)
- Consider scalability implications (concurrent requests, queueing)

### Phase 5: Plan Structure Generation for Project AI

**Create comprehensive plan with the following structure:**

```markdown
# Feature: <feature-name> for Project AI

The following plan should be complete, but its important that you validate documentation and codebase patterns and task sanity before you start implementing.

Pay special attention to naming of existing utils, types, and models. Import from the right files etc. Remember to check `backend/src/services/` for existing AI patterns.

## Feature Description

<Detailed description of the AI feature, its purpose, and value to users>

## User Story

As a <type of user> (e.g., Content Creator, Developer, Analyst)
I want to <action/goal> (e.g., generate summaries, analyze sentiment)
So that <benefit/value> (e.g., save time, gain insights)

## Problem Statement

<Clearly define the specific problem or opportunity this AI feature addresses>

## Solution Statement

<Describe the proposed AI-powered solution approach and how it solves the problem>

## Feature Metadata

**Feature Type**: [New Capability/Enhancement/Refactor/Bug Fix]
**Estimated Complexity**: [Low/Medium/High]
**Primary Systems Affected**: [List of main components: AI Service, API Layer, Frontend, DB]
**Dependencies**: [External libraries or services: OpenAI, Anthropic, etc.]
**Estimated Cost Impact**: [Low/Medium/High] token usage estimation

---

## CONTEXT REFERENCES

### Relevant Codebase Files IMPORTANT: YOU MUST READ THESE FILES BEFORE IMPLEMENTING!

<List files with line numbers and relevance>

- `backend/src/services/ai_service.py` (lines 15-45) - Why: Contains base AI integration pattern with retry logic
- `backend/src/services/prompt_service.py` - Why: Prompt management pattern to follow
- `backend/src/api/routes/chat.py` - Why: API endpoint structure for AI features
- `backend/src/core/exceptions.py` (lines 50-70) - Why: Custom exceptions for AI errors
- `frontend/src/hooks/useAI.ts` - Why: React hook pattern for AI interactions
- `tests/unit/test_ai_service.py` - Why: Mocking pattern for AI API tests

### New Files to Create

- `backend/src/services/feature_name_service.py` - Service implementation for new AI capability
- `backend/src/services/prompts/feature_name_prompts.py` - Prompts for the feature
- `backend/src/api/routes/feature_name.py` - API endpoints
- `frontend/src/components/FeatureName/` - UI components
- `frontend/src/hooks/useFeatureName.ts` - React hook for feature
- `tests/unit/test_feature_name_service.py` - Unit tests
- `tests/integration/test_feature_name_workflow.py` - Integration tests

### Relevant Documentation YOU SHOULD READ THESE BEFORE IMPLEMENTING!

- [Documentation Link 1](https://platform.openai.com/docs/guides/text-generation) 
  - Specific section: Chat Completions API
  - Why: Core API for text generation feature
- [Documentation Link 2](https://fastapi.tiangolo.com/advanced/background-tasks/)
  - Specific section: Background Tasks
  - Why: For async AI processing without blocking
- [PROJECT.md](PROJECT.md) - Project configuration and standards
- [AGENTS.md](AGENTS.md) - Agent instructions and workflow

### Patterns to Follow

<Specific patterns extracted from codebase - include actual code examples from the project>

**AI Service Pattern:**
```python
# From backend/src/services/ai_service.py
async def generate_response(prompt: str, model: str = "gpt-3.5-turbo") -> str:
    try:
        response = await openai.ChatCompletion.acreate(
            model=model,
            messages=[{"role": "user", "content": prompt}],
            timeout=30.0  # Always set timeout
        )
        return response.choices[0].message.content
    except openai.error.Timeout as e:
        logger.error(f"AI timeout: {e}")
        raise AITimeoutException("Request timed out")
    except Exception as e:
        logger.error(f"AI error: {e}")
        raise AIException("Failed to generate response")
```

**Error Handling Pattern:**
```python
# From backend/src/core/exceptions.py
class AIException(Exception):
    """Base exception for AI-related errors"""
    pass

class AITimeoutException(AIException):
    """Raised when AI service times out"""
    pass
```

**Testing Pattern with Mocks:**
```python
# From tests/unit/test_ai_service.py
@pytest.mark.asyncio
async def test_generate_response_success(mocker):
    mock_response = mocker.Mock()
    mock_response.choices[0].message.content = "Generated text"
    mocker.patch('openai.ChatCompletion.acreate', 
                 return_value=mock_response)
    
    result = await ai_service.generate_response("Test prompt")
    assert result == "Generated text"
```

---

## IMPLEMENTATION PLAN

### Phase 1: Foundation

<Describe foundational work needed before main implementation>

**Tasks:**

- Set up base structures (Pydantic schemas, TypeScript types)
- Configure necessary dependencies (update requirements.txt/package.json)
- Create foundational utilities or helpers (prompt templates, token counters)
- Add configuration variables to `.env.example`

### Phase 2: Core Implementation

<Describe the main implementation work>

**Tasks:**

- Implement core AI business logic in service layer
- Create prompt templates and management
- Add API endpoints with proper validation
- Implement frontend components and hooks
- Add cost tracking and monitoring

### Phase 3: Integration

<Describe how feature integrates with existing functionality>

**Tasks:**

- Connect to existing routers in `backend/src/api/main.py`
- Register new components in frontend router
- Update configuration files
- Add error handling middleware if needed
- Integrate with existing logging and monitoring

### Phase 4: Testing & Validation

<Describe testing approach>

**Tasks:**

- Implement unit tests for each component (with mocked AI)
- Create integration tests for feature workflow
- Add edge case tests (timeouts, rate limits, invalid responses)
- Validate against acceptance criteria
- Test cost tracking and token counting

---

## STEP-BY-STEP TASKS

IMPORTANT: Execute every task in order, top to bottom. Each task is atomic and independently testable.

### Task Format Guidelines

Use information-dense keywords for clarity:

- **CREATE**: New files or components
- **UPDATE**: Modify existing files
- **ADD**: Insert new functionality into existing code
- **REMOVE**: Delete deprecated code
- **REFACTOR**: Restructure without changing behavior
- **MIRROR**: Copy pattern from elsewhere in codebase

### {ACTION} {target_file}

- **IMPLEMENT**: {Specific implementation detail}
- **PATTERN**: {Reference to existing pattern - file:line}
- **IMPORTS**: {Required imports and dependencies}
- **GOTCHA**: {Known issues or constraints to avoid (e.g., "AI timeout must be set")}
- **COST**: {Estimated token usage / cost impact}
- **VALIDATE**: `{executable validation command}`

<Continue with all tasks in dependency order...>

---

## TESTING STRATEGY

<Define testing approach based on project's test framework and patterns discovered during research>

### Unit Tests

- Mock ALL external AI API calls (OpenAI, Anthropic)
- Test success scenarios with mock responses
- Test error scenarios (timeouts, rate limits, invalid JSON)
- Test token counting and cost tracking
- Test prompt formatting and validation

### Integration Tests

- Test API endpoints with mocked AI service
- Test database persistence (if storing results)
- Test frontend-backend integration
- Test error propagation from backend to frontend

### Edge Cases

- AI service unavailable (timeout)
- Rate limit exceeded (429 response)
- Invalid API key
- Response too large (token limit exceeded)
- Malformed AI response (invalid JSON)
- Concurrent requests handling

---

## VALIDATION COMMANDS

<Define validation commands based on project's tools discovered in Phase 2>

Execute every command to ensure zero regressions and 100% feature correctness.

### Level 1: Syntax & Style

```bash
cd backend && ruff check src/ tests/
cd backend && black --check src/ tests/
cd frontend && npm run lint
cd frontend && npm run format:check
```

### Level 2: Type Checking

```bash
cd backend && mypy src/
cd frontend && npm run typecheck
```

### Level 3: Unit Tests

```bash
cd backend && pytest tests/unit -v
cd frontend && npm test -- --ci --coverage
```

### Level 4: Integration Tests

```bash
cd backend && pytest tests/integration -v
playwright test tests/e2e/feature_name.spec.ts
```

### Level 5: Cost Validation (if applicable)

```bash
cd backend && python scripts/estimate_tokens.py --feature feature_name
cd backend && python scripts/cost_report.py --days 1
```

### Level 6: Manual Validation

<Feature-specific manual testing steps - API calls, UI testing, etc.>

- Test with curl: `curl -X POST http://localhost:8000/api/v1/feature -H "Content-Type: application/json" -d '{"prompt":"test"}'`
- Test in browser UI with different inputs
- Verify error messages are user-friendly
- Check logs for proper structured logging

---

## ACCEPTANCE CRITERIA

<List specific, measurable criteria that must be met for completion>

- [ ] Feature implements all specified AI functionality
- [ ] All validation commands pass with zero errors
- [ ] Unit test coverage >80% for new code
- [ ] Integration tests verify end-to-end workflows
- [ ] Code follows project conventions and patterns (from PROJECT.md)
- [ ] No regressions in existing functionality
- [ ] Documentation is updated (README, API docs)
- [ ] Performance: AI response time < 3 seconds (p95)
- [ ] Cost tracking implemented and tested
- [ ] All AI API calls have proper timeout and retry logic
- [ ] No API keys or secrets in code (only in .env)
- [ ] Error handling covers all AI failure scenarios
- [ ] Security: input sanitized, output validated

---

## COMPLETION CHECKLIST

- [ ] All tasks completed in order
- [ ] Each task validation passed immediately
- [ ] All validation commands executed successfully
- [ ] Full test suite passes (unit + integration)
- [ ] No linting or type checking errors
- [ ] Manual testing confirms feature works
- [ ] Cost impact assessed and within budget
- [ ] Acceptance criteria all met
- [ ] Code reviewed for quality and maintainability

---

## COST & PERFORMANCE CONSIDERATIONS

<Specific to AI features>

- **Estimated tokens per request**: ~X input, ~Y output
- **Estimated cost per request**: $0.00X
- **Monthly projection at scale**: $X for Y requests
- **Caching strategy**: Identical prompts cached for Z hours
- **Optimization opportunities**: Model selection, prompt compression
- **Monitoring**: Track actual vs estimated costs

---

## NOTES

<Additional context, design decisions, trade-offs>

- Why we chose this AI model over alternatives
- Prompt engineering decisions and rationale
- Fallback strategies if primary AI is unavailable
- Future extensibility considerations
- Known limitations in this version
```

## Output Format

**Filename**: `.agents/plans/{kebab-case-descriptive-name}.md`

- Replace `{kebab-case-descriptive-name}` with short, descriptive feature name
- Examples: `add-text-summarization.md`, `implement-sentiment-analysis.md`, `add-streaming-responses.md`

**Directory**: Create `.agents/plans/` if it doesn't exist

---

## Quality Criteria

### Context Completeness ✓

- [ ] All necessary AI patterns identified and documented
- [ ] External AI library usage documented with links
- [ ] Integration points clearly mapped (backend/frontend)
- [ ] Gotchas and anti-patterns captured (timeouts, costs)
- [ ] Every task has executable validation command
- [ ] Cost implications considered and documented

### Implementation Ready ✓

- [ ] Another developer could execute without additional context
- [ ] Tasks ordered by dependency (can execute top-to-bottom)
- [ ] Each task is atomic and independently testable
- [ ] Pattern references include specific file:line numbers
- [ ] Mocking strategy for AI APIs is clear

### Pattern Consistency ✓

- [ ] Tasks follow existing codebase conventions (from PROJECT.md)
- [ ] New patterns justified with clear rationale
- [ ] No reinvention of existing patterns or utils
- [ ] Testing approach matches project standards (mock external services)

### Information Density ✓

- [ ] No generic references (all specific and actionable)
- [ ] URLs include section anchors when applicable
- [ ] Task descriptions use codebase keywords
- [ ] Validation commands are non-interactive executable

---

## Success Metrics

**One-Pass Implementation**: Execution agent can complete feature without additional research or clarification

**Validation Complete**: Every task has at least one working validation command

**Context Rich**: The Plan passes "No Prior Knowledge Test" - someone unfamiliar with codebase can implement using only Plan content

**Cost-Aware**: Plan includes token estimation and cost monitoring strategy

**Confidence Score**: #/10 that execution will succeed on first attempt

---

## Report

After creating the Plan, provide:

- Summary of feature and approach
- Full path to created Plan file (`.agents/plans/feature-name.md`)
- Complexity assessment
- Key implementation risks or considerations (especially around AI)
- Estimated confidence score for one-pass success
- Estimated cost impact (if applicable)
