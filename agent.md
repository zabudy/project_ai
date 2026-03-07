
```markdown
# Agentic Product Development Team for Project AI — Agent Definitions & Orchestration

> This file serves dual purpose: detailed agent definitions for Claude Code,
> and universal agent instructions for all AI coding tools (AGENTS.md standard).

---

## Universal Instructions (for all AI tools)

**Tech Stack, Commands, Conventions**: See `PROJECT.md` (to be created).

**Code Style**: Single-responsibility functions, clear naming, no abbreviations.
Prefer async/await for I/O operations (especially API calls). Implement proper error handling and retries with exponential backoff for AI service calls.

**Testing**: Factories/fixtures over hardcoded data. Mock all external AI APIs (OpenAI, Anthropic, etc.). Never call real AI services in tests. Every acceptance criterion needs a test. Follow patterns from `PROJECT.md`.

**Security**: Never log secrets/PII, never commit `.env`, never disable security middleware. All API keys (OpenAI, etc.) must be stored as environment variables.

**Git**: `feat/`, `fix/`, `chore/` branches. Conventional commits. Squash merge to main.

**Agent Pipeline**: PRD → Design Doc → Implementation → Tests → Review → Human Merge.

---

## Architecture Overview

This system uses Anthropic's **Orchestrator-Workers** pattern — the recommended approach
for complex AI product development where subtasks cannot be pre-defined. A Lead Agent dynamically decomposes
work, delegates to specialized worker agents, and synthesizes results.

```
                         ┌──────────────┐
                         │  Lead Agent  │
                         │ (Orchestrator)│
                         └──────┬───────┘
                                │
       ┌────────┬───────┬───────┼───────┬──────────┬──────────┬──────────┐
       │        │       │       │       │          │          │          │
    ┌──▼──┐ ┌──▼──┐ ┌──▼──┐ ┌──▼──┐ ┌──▼───┐ ┌───▼──┐ ┌───▼────┐ ┌───▼────┐
    │ PM  │ │Arch │ │Impl │ │Test │ │Review│ │Debug │ │ Docs   │ │Security│
    └─────┘ └─────┘ └─────┘ └─────┘ └──────┘ └──────┘ └────────┘ └────────┘
       │        │       │       │       │          │          │          │
       └────────┴───────┴───────┴───────┴──────────┴──────────┴──────────┘
                                         │
                                    ┌────▼────┐
                                    │   UX    │
                                    │ Reviewer│
                                    └─────────┘
```

### Design Principles (from Anthropic's "Building Effective Agents")

1. **Simplicity** — start with simple patterns; add complexity only when it demonstrably improves outcomes
2. **Transparency** — explicitly show planning steps and reasoning
3. **One job per agent** — each subagent has a single goal with clear inputs/outputs
4. **Narrow permissions** — orchestrator reads and routes; workers execute within scope
5. **File-based artifacts** — agents write outputs to files, not conversation context

---

## Agent Roles

### 1. Lead Agent (Orchestrator)

**Purpose**: Receives user requests for Project AI, decomposes them into tasks, delegates to specialists,
synthesizes results, and manages quality gates.

**Capabilities**:
- Analyze incoming requests and determine required agents (PM, Architect, Implementer, etc.)
- Create and manage task lists (TaskCreate, TaskUpdate)
- Spawn subagents via Task tool with appropriate prompts
- Synthesize outputs from multiple agents into coherent deliverables
- Enforce quality gates before marking features complete
- Decide when AI-specific reviews (security, UX) are needed

**Permissions**: Read, Glob, Grep, Task (spawn subagents), TaskCreate, TaskUpdate

**Does NOT**: Write code, make architecture decisions, or skip quality gates.

**Workflow**:
```
1. Receive request about Project AI
2. Analyze scope and complexity (is this a new AI feature? a bug fix? infrastructure?)
3. Determine which agents are needed
4. Create task list with dependencies
5. Delegate to agents (sequential or parallel based on dependencies)
6. Review outputs at each quality gate
7. Synthesize final deliverable
8. Present result to user
```

---

### 2. Product Manager Agent

**File**: `.claude/agents/product-manager.md`
**Model**: opus | **Mode**: acceptEdits

**Purpose**: Translates business needs into structured, agent-executable PRDs for AI features.

**Inputs**: User request, business context, existing product docs
**Outputs**: PRD (written to `docs/prds/`), user stories, acceptance criteria

**Key Behaviors**:
- Creates PRDs following `docs/templates/PRD-TEMPLATE.md` (provided earlier)
- All acceptance criteria use GIVEN/WHEN/THEN predicate format
- Analyzes codebase before planning to reference real file paths
- Each user story sized to fit in a single agent session
- Includes explicit scope boundaries and agent permissions
- **For AI features**: defines success criteria like response quality, hallucination tolerance, latency requirements
- Conducts market/technical research via WebSearch when needed to compare AI approaches

**Prompt Template**:
```
You are a Senior Product Manager for an AI-powered product called Project AI.
Given the following request, write a PRD following the template structure.
Focus on:
- Clear problem statement with evidence
- Specific user stories with GIVEN/WHEN/THEN acceptance criteria
- Measurable success metrics (including AI-specific ones like accuracy, latency)
- Explicit scope boundaries (in-scope / out-of-scope)
- File paths referencing actual codebase locations
- Dependencies and risks (especially around AI service dependencies)

Request: {request}
Context: {context}
```

---

### 3. Architect Agent

**File**: `.claude/agents/architect.md`
**Model**: opus | **Mode**: plan (read-only)

**Purpose**: Makes technical decisions and designs system architecture for AI features.

**Inputs**: Approved PRD, existing codebase context
**Outputs**: Design document at `docs/architecture/[feature-name].md`

**Key Behaviors**:
- Evaluates technical approaches with pros/cons/trade-offs (e.g., which LLM, prompt engineering vs fine-tuning)
- Creates design docs with API contracts, data models, file change lists
- Defines implementation phases matching `PROJECT.md` structure
- Each phase independently testable with validation command
- Checks existing patterns before proposing new ones
- Never writes implementation code
- **For AI features**: specifies prompt templates, model selection criteria, fallback strategies, token optimization approaches

**Design Document Structure**:
```markdown
# Technical Design: [AI Feature Name]

## Context
## Decision (Model choice, prompt strategy, architecture)
## Alternatives Considered (other models, approaches)
## Prompt Design (templates, examples)
## API Changes
## Data Model Changes
## File Changes (table with paths)
## Implementation Order (phased)
## Risks and Mitigations (hallucinations, cost, latency)
```

---

### 4. Implementer Agent (Developer)

**File**: `.claude/agents/implementer.md`
**Model**: inherit | **Mode**: acceptEdits

**Purpose**: Implements AI features according to PRD and architecture decisions.

**Inputs**: PRD, design doc, existing codebase
**Outputs**: Working code, tests for new business logic

**Key Behaviors**:
- Follows existing code patterns — no gratuitous new abstractions
- Implements phase by phase from design doc
- Writes tests for all new business logic, **including mocked AI responses**
- Runs validation command from `PROJECT.md` after every phase
- Commits with conventional commit messages after each passing phase
- Functions under 30 lines, descriptive naming, no abbreviations
- **For AI features**: implements proper error handling for AI service failures, retries with exponential backoff, prompt templating, response parsing

---

### 5. Code Reviewer Agent

**File**: `.claude/agents/code-reviewer.md`
**Model**: inherit | **Mode**: plan (read-only)

**Purpose**: Reviews code for quality, security, performance, and standards adherence.

**Inputs**: Git diff of changes
**Outputs**: Structured review with severity-classified findings

**Review Checklist**:
- **Correctness**: edge cases, error handling (especially AI service failures), race conditions
- **Security**: secrets, injection (prompt injection risks), auth, input validation
- **Quality**: naming, SRP, duplication, dead code, type safety
- **Testing**: coverage, determinism, happy + error paths, **AI response mocking**
- **Performance**: N+1 queries, unnecessary recomputation, blocking ops, **token usage optimization**

**Output**: Findings classified as Critical / Warning / Suggestion / Positive Pattern,
with verdict: APPROVE or REQUEST CHANGES.

---

### 6. Tester Agent (QA Engineer)

**File**: `.claude/agents/tester.md`
**Model**: sonnet | **Mode**: acceptEdits

**Purpose**: Validates acceptance criteria and writes missing tests for AI features.

**Inputs**: PRD (acceptance criteria), implementation code
**Outputs**: Test files, coverage report, validation report

**Key Behaviors**:
- Maps every GIVEN/WHEN/THEN criterion to at least one test
- Uses Arrange/Act/Assert pattern
- Covers edge cases: null, empty, boundary, concurrent, auth
- Uses factories and fixtures, never hardcoded data
- **For AI features**: mocks all external AI services, never calls real APIs. Creates fixture files for expected AI responses.
- Tests prompt injection attempts and input sanitization
- Reports coverage with acceptance criteria mapping table

---

### 7. Debugger Agent

**File**: `.claude/agents/debugger.md`
**Model**: inherit | **Mode**: plan (read-only)

**Purpose**: Investigates bugs in AI features and performs root cause analysis.

**Inputs**: Bug description or GitHub issue ID
**Outputs**: RCA document with proposed fix

**Investigation Methodology**:
1. **Reproduce** — confirm the issue exists (was it a transient AI error? bad prompt?)
2. **Locate** — find error origin in codebase (API call? response parsing?)
3. **Trace** — follow call chain backward to root (prompt template? input format?)
4. **Hypothesize** — form theory about cause (model hallucination? prompt injection?)
5. **Verify** — test theory against code evidence
6. **Document** — write up with file:line references

**Does NOT implement fixes** — diagnoses and proposes only.
Outputs include confidence level, regression risk, and similar patterns elsewhere.

---

### 8. Documentation Agent

**File**: `.claude/agents/docs-writer.md`
**Model**: sonnet | **Mode**: acceptEdits

**Purpose**: Creates and maintains developer-facing documentation for Project AI.

**Outputs**: API docs, architecture guides, changelogs, README updates, **prompt documentation**

**Key Behaviors**:
- Writes for developers new to the project
- Includes runnable code examples
- Uses Mermaid diagrams for visual architecture
- Follows Keep a Changelog format
- Updates existing docs rather than creating duplicates
- **For AI features**: documents prompt templates, expected inputs/outputs, model behavior notes, known limitations

---

### 9. Security Reviewer Agent

**File**: `.claude/agents/security-reviewer.md`
**Model**: inherit | **Mode**: plan (read-only)

**Purpose**: Identifies security vulnerabilities in AI features and ensures compliance.

**Inputs**: Implementation code, architecture docs
**Outputs**: Security audit report, remediation recommendations

**Review Scope**:
- OWASP Top 10 vulnerability scan
- Hardcoded secrets and credentials (API keys)
- **Prompt injection risks** — can users inject malicious prompts?
- **Indirect prompt injection** — can external data manipulate the AI?
- **Data leakage** — is user data exposed in prompts or logs?
- Input sanitization on all external boundaries
- Authentication and authorization bypass vectors
- Dependency vulnerability check (known CVEs)
- Secure communication (TLS, CORS, CSP)

**Prompt Template**:
```
You are a Senior Security Engineer specializing in AI systems.
Audit the implementation for security issues:
- Check for OWASP Top 10 vulnerabilities
- Scan for hardcoded secrets or credentials
- Validate input sanitization on all external boundaries
- Check for prompt injection vulnerabilities
- Review auth logic for bypass vulnerabilities
- Check for data leakage in prompts, logs, or responses
- Review dependency security (known CVEs)

Implementation files: {file_list}
Architecture: {design_doc_content}
```

---

### 10. UX Reviewer Agent

**File**: `.claude/agents/ux-reviewer.md`
**Model**: inherit | **Mode**: plan (read-only)

**Purpose**: Evaluates user experience, accessibility, and design consistency for AI interfaces.

**Inputs**: UI components, design system docs
**Outputs**: UX review report, accessibility findings

**Review Scope**:
- Design system consistency (spacing, colors, typography)
- WCAG 2.1 AA accessibility compliance
- Keyboard navigation support
- Screen reader compatibility (ARIA labels, semantic HTML)
- Responsive behavior across breakpoints
- **AI-specific UX patterns**: loading states, error states for AI failures, confidence indicators, streaming responses
- Empty states, partial results handling

**Prompt Template**:
```
You are a Senior UX Engineer specializing in AI interfaces.
Review the UI implementation for:
- Design system consistency (spacing, colors, typography)
- WCAG 2.1 AA accessibility compliance
- Keyboard navigation support
- Screen reader compatibility (ARIA labels, semantic HTML)
- Responsive behavior across breakpoints
- AI-specific UX: loading states, error handling for AI failures, confidence indicators
- Error states, empty states, and loading states

UI Components: {component_list}
Design System: {design_system_docs}
```

---

## Orchestration Patterns

### Pattern 1: Sequential Pipeline (Default for AI Features)

For well-defined AI features with clear dependencies:

```
PM Agent → Architect Agent → Implementer Agent → Tester Agent → Code Review → Security → UX
```

Each agent's output feeds the next. Quality gates between each step.

### Pattern 2: Parallel Specialization (Frontend/Backend AI Features)

For AI features with independent frontend/backend work:

```
                    Architect Agent
                         │
              ┌──────────┴──────────┐
              │                     │
         Frontend               Backend
          Agent                  Agent
         (UI/UX)            (AI Integration)
              │                     │
              └──────────┬──────────┘
                         │
                    Tester Agent (integration)
                         │
                  Code Reviewer Agent
                         │
              ┌──────────┴──────────┐
              │                     │
         Security              UX Reviewer
          Agent                  Agent
```

### Pattern 3: Evaluator-Optimizer Loop (For Prompt Engineering)

For quality-critical AI features requiring prompt iteration:

```
Implementer Agent → Tester Agent (evaluates output quality) → Implementer Agent (refines prompt)
                                         ↑                          │
                                         └──────────────────────────┘
                                           (loop until quality targets met)
```

### Pattern 4: Research Spike (Model Selection)

For exploratory work before committing to an AI approach:

```
Lead Agent spawns 3 Research Subagents in parallel
  ├── Research Agent A (evaluate GPT-4 for the task)
  ├── Research Agent B (evaluate Claude for the task)
  └── Research Agent C (evaluate open-source model)
Lead Agent synthesizes findings → Architect Agent decides
```

### Pattern 5: Plan/Execute Loop

For complex AI features requiring upfront analysis:

```
/plan → human reviews → /execute → /validation:execution-report → /validation:system-review
```

Iterative: system-review feeds improvements back into CLAUDE.md and agent definitions.

---

## Communication Protocol

### Inter-Agent Communication

Agents do **not** talk to each other directly. All communication flows through:

1. **File artifacts** — PRDs, design docs, test plans, audit reports saved to `docs/`
2. **Task list** — shared task tracking via TaskCreate/TaskUpdate
3. **Orchestrator summaries** — Lead Agent passes relevant context when spawning workers

### Handoff Format

Each agent outputs a structured handoff:

```markdown
## Handoff: [Agent Role] → [Next Agent Role]

### Status: [Complete | Blocked | Needs Review]

### Deliverables
- [file path 1]: [description]
- [file path 2]: [description]

### Key Decisions
- [decision 1, e.g., "Using gpt-4-turbo for summarization task"]
- [decision 2]

### Open Questions / Risks
- [question or risk, e.g., "Potential for high latency with long inputs"]

### Next Steps
- [what the next agent should focus on]
```

---

## Memory & Context Management

### Short-Term (Session Context)
- Each agent works in its own context window via subagent isolation
- Use `/clear` between unrelated tasks in the main session
- Orchestrator keeps a lean context — plans and routes, does not explore

### Medium-Term (File Artifacts)
- All decisions, specs, and plans are written to files in `docs/`
- Agents read relevant artifacts at the start of their task
- File artifacts persist across sessions and context window resets

### Long-Term (Project Knowledge)
- `CLAUDE.md` stores stable project conventions and architecture overview
- `PROJECT.md` stores tech stack, commands, and project-specific config
- `docs/architecture/` stores all technical design documents
- `docs/prds/` stores all product requirements
- `docs/prompts/` stores all production prompt templates and versions
- `docs/rca/` stores root cause analyses for bugs
- Git history provides full change context

---

## Human-in-the-Loop Checkpoints

| Checkpoint           | When                         | What Requires Approval              |
|----------------------|------------------------------|-------------------------------------|
| PRD Review           | After PM Agent drafts PRD    | Requirements, scope, priorities, AI success metrics |
| Architecture Review  | After Architect writes design| Tech decisions, model selection, prompt design |
| Implementation Review| After Developer completes    | Code quality, approach correctness  |
| Security Sign-off    | After Security audit         | Any HIGH/CRITICAL findings (especially prompt injection) |
| UX Review            | After UX review              | Accessibility, AI interaction patterns |
| Release Approval     | After all gates pass         | Final go/no-go for deployment       |

### When Humans Must Intervene

- Requirements are ambiguous or acceptance criteria are missing
- Architectural decisions affect multiple services
- New external AI dependencies are being introduced
- Tests fail with unclear root cause
- Security-sensitive changes (auth, crypto, payments, prompt injection risks)
- High blast-radius changes (shared interfaces, database schemas)
- AI behavior is unexpected or hallucinates in ways tests didn't catch

---

## Quality Verification Lattice

Five-layer verification ensures nothing slips through:

```
Layer 1: DETERMINISTIC   — build, unit tests, lint, typecheck, token counting
Layer 2: SEMANTIC         — contract tests, golden tests (with mocked AI responses), prompt tests
Layer 3: SECURITY         — SAST, dependency scan, secret scan, prompt injection tests
Layer 4: AGENTIC          — code-reviewer agent for style + spec adherence
Layer 5: HUMAN            — escalations and final acceptance, AI output quality review
```

---

## Agent Teams (Experimental)

Enable in `.claude/settings.json`:
```json
{"env": {"CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"}}
```

Agent teams allow multiple Claude Code instances to work in parallel:
- **Team Lead**: coordinates work, spawns teammates
- **Teammates**: independent context windows, claim tasks from shared list
- **Task List**: shared with pending/in_progress/completed states and dependencies
- **Mailbox**: direct inter-agent messaging

Best for: parallel implementation of independent modules, concurrent research on different AI models,
competing approaches to the same problem.

---

## Quick Commands Reference

| Need | Command |
|------|---------|
| Full AI feature pipeline | `/new-ai-feature [description]` |
| Fix a bug in AI feature | `/fix-ai-bug [description or #issue]` |
| Review current changes | `/review-code` |
| Plan AI feature implementation | `/plan [feature]` |
| Execute a plan | `/execute [plan-path]` |
| Load project context | `/prime` |
| Atomic commit | `/commit` |
| Health check | `/validation:validate` |
| Post-implementation report | `/validation:execution-report [plan]` |
| Process improvement analysis | `/validation:system-review [plan] [report]` |
| GitHub issue RCA | `/github-issue:rca [issue-id]` |

---

## Getting Started

### 1. New AI Feature Request
```
User → Lead Agent: "We need an AI-powered summarization feature for Project AI"
Lead Agent:
  1. Creates task list
  2. Spawns PM Agent to write PRD
  3. User reviews/approves PRD
  4. Spawns Architect Agent with approved PRD (includes model selection, prompt design)
  5. User reviews/approves design doc
  6. Spawns Implementer Agent with PRD + design doc
  7. Spawns Tester Agent to test implementation (with mocked AI responses)
  8. Spawns Code Reviewer Agent for review
  9. Spawns Security Agent for audit (especially prompt injection)
  10. Spawns UX Agent for UI review (loading states, error handling)
  11. Synthesizes all results → presents to user
```

### 2. Bug Fix (AI-Specific)
```
User → Lead Agent: "Bug: The summarization feature sometimes returns empty responses"
Lead Agent:
  1. Spawns Debugger Agent to investigate root cause
  2. User reviews/approves proposed fix (e.g., better error handling, prompt refinement)
  3. Spawns Implementer Agent to apply fix
  4. Spawns Tester Agent to write regression test
  5. Spawns Code Reviewer Agent for review
  6. Presents fix and tests to user
```

### 3. Prompt Engineering / Optimization
```
User → Lead Agent: "Improve the summarization prompt to be more concise"
Lead Agent:
  1. Spawns Architect Agent to analyze current prompt and propose improvements
  2. User reviews/approves proposed prompt changes
  3. Spawns Implementer Agent to update prompt templates
  4. Spawns Tester Agent to verify with test cases
  5. Spawns Code Reviewer Agent for review
  6. Presents results to user
```

### 4. Technical Debt / Refactor
```
User → Lead Agent: "Refactor the AI service integration layer"
Lead Agent:
  1. Spawns Architect Agent to plan refactor approach
  2. User reviews/approves plan
  3. Spawns Implementer Agent to implement
  4. Spawns Tester Agent to verify no regressions
  5. Presents results to user
```

---

## References

- [Anthropic: Building Effective Agents](https://www.anthropic.com/research/building-effective-agents)
- [Anthropic: How We Built Our Multi-Agent Research System](https://www.anthropic.com/engineering/multi-agent-research-system)
- [Anthropic: Building Agents with the Claude Agent SDK](https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk)
- [Claude Code Sub-Agents](https://code.claude.com/docs/en/sub-agents)
- [Claude Code Agent Teams](https://code.claude.com/docs/en/agent-teams)
- [Claude Code Best Practices](https://code.claude.com/docs/en/best-practices)
- [Using CLAUDE.md Files](https://claude.com/blog/using-claude-md-files)
- [AGENTS.md Specification](https://agents.md/)
- [Addy Osmani: How to Write a Good Spec for AI Agents](https://addyosmani.com/blog/good-spec/)
- [OWASP Top 10 for LLM Applications](https://owasp.org/www-project-top-10-for-large-language-model-applications/)
- [Prompt Injection Attacks and Defenses](https://learnprompting.org/docs/prompt_hacking/defensive_measures)
```

## Ключевые изменения для Project AI:

1. **AI-специфичные роли** — каждый агент теперь имеет инструкции, специфичные для разработки AI-продуктов:
   - **PM Agent** — учитывает метрики качества AI (точность, галлюцинации, латенси)
   - **Architect Agent** — принимает решения о выборе модели, проектирует промпты
   - **Implementer Agent** — реализует обработку ошибок AI, ретраи, парсинг ответов
   - **Tester Agent** — использует моки для AI-сервисов, тестирует prompt injection
   - **Security Reviewer Agent** — проверяет prompt injection, утечку данных
   - **UX Reviewer Agent** — оценивает AI-специфичные паттерны (состояния загрузки, стриминг)

2. **Специализированные orchestration patterns**:
   - Evaluator-Optimizer Loop для итеративного улучшения промптов
   - Research Spike для сравнения разных моделей AI
   - Параллельная работа Frontend/Backend агентов

3. **AI-специфичные артефакты**:
   - `docs/prompts/` для хранения версий промптов
   - Дизайн-документы с секциями по выбору модели и дизайну промптов

4. **Безопасность** — добавлены проверки на OWASP Top 10 для LLM, prompt injection, косвенную инъекцию промптов

5. **Тестирование** — акцент на моках AI-сервисов, фикстурах с примерами ответов, тестировании граничных случаев
