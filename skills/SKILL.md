
---

---

# PRD Creator Skill for Project AI

This skill helps create **Product Requirements Documents (PRDs)** for AI-powered features that follow the Project AI repository standards.

PRDs are the **source of truth for AI feature development**.  
All implementation work must trace back to a PRD requirement, especially when integrating with external AI services like OpenAI or Anthropic.

## Repository Structure

```
project_ai/
  docs/
    prds/           # Product Requirements Documents for AI features
    architecture/   # Technical design documents for AI architecture
    plans/          # Implementation plans
    templates/      # Document templates (including create_prd.md)
```

PRDs must be created inside:

```
docs/prds/
```

---

## Core Principle

The repository follows **PRD-Driven Development with AI-First Design**.

This means:

1. An AI feature must be described in a PRD before implementation.
2. Every user scenario must include **acceptance conditions** that account for AI-specific behaviors.
3. Acceptance conditions must be **testable**, including edge cases like AI service unavailability.
4. Implementation must map directly to those conditions.
5. AI interactions (prompts, responses, error handling) must be explicitly defined.

**Example for AI feature:**

```
GIVEN the user enters a valid text prompt
WHEN the user clicks "Generate AI Insight"
THEN the system calls the OpenAI API with the configured prompt template
AND the AI response is displayed to the user within 3 seconds
AND the original prompt and response are saved to the database
```

Each acceptance condition should correspond to at least one test, including tests for AI service failures.

---

## PRD Creation Workflow

Follow this workflow when creating a PRD for an AI feature.

### Step 1 — Understand the AI Feature

Clarify the AI feature before writing the PRD.

**Key questions specific to AI:**

- What problem does this AI feature solve that traditional software cannot?
- What AI model or service will be used? (OpenAI GPT-4, Claude, custom model?)
- What is the expected prompt structure?
- How will we handle AI errors (rate limits, timeouts, inappropriate content)?
- What are the cost implications per request?
- Should we cache similar requests to reduce costs?

If information is missing, ask the user for clarification.

### Step 2 — Define the Problem

Document the problem clearly.

**Include:**

- current situation without AI
- user pain points that AI will address
- supporting evidence (user feedback, analytics)
- consequences of not solving the problem with AI
- why AI is the right solution (vs. rule-based or manual)

Focus on **real user needs**, not the technical AI implementation details.

### Step 3 — Identify Target Users

Describe the primary users of the AI feature.

**Example attributes for AI features:**

- technical level (influences prompt complexity)
- domain expertise (influences response expectations)
- frequency of AI interactions
- tolerance for AI latency and errors
- privacy expectations (data sent to AI services)

Avoid vague definitions like "everyone".

**Example:**
```
Primary User: Content Creator
- Technical level: Intermediate
- Uses AI for: Generating blog post outlines
- Expects: Fast responses (< 2 seconds)
- Tolerance: Low for errors, needs fallback options
```

### Step 4 — Write User Scenarios with AI Interactions

User scenarios describe how the AI feature will be used.

Each scenario must include:

- user role
- goal
- AI interaction details
- acceptance conditions

**Example scenario structure for AI feature:**

```
Scenario — Generate Text Summary

User role: Analyst

Goal:
User wants to summarize a long document using AI.

AI Interaction:
- Model: OpenAI GPT-4
- Prompt template: "Summarize the following text in 3 bullet points: {text}"
- Max tokens: 150
- Temperature: 0.3 (for consistent output)

Acceptance Conditions:

GIVEN the user provides text between 100 and 5000 characters
WHEN the user requests a summary
THEN the system calls the AI service with the correct prompt template
AND the summary is displayed within 5 seconds
AND the response is saved to the user's history

GIVEN the AI service returns an error (timeout, rate limit)
WHEN the user requests a summary
THEN the system displays a user-friendly error message
AND the system logs the error without exposing API keys
AND the user can retry after 5 seconds
```

Include **example inputs and expected outputs** when possible to guide prompt engineering.

### Step 5 — Define Scope with AI Boundaries

Clearly define what is included and excluded, especially regarding AI capabilities.

**Included** — Features that must be implemented.

```
✅ Included for AI Summary Feature:
- Integration with OpenAI API
- Prompt templating system
- Error handling for API failures
- Cost tracking per request
- History storage of prompts and responses
```

**Excluded** — Features intentionally left out.

```
❌ Excluded (Future Phases):
- Support for Anthropic Claude
- Fine-tuned custom models
- Streaming responses
- Multi-language support
```

This prevents **scope creep** and manages AI costs.

### Step 6 — Technical Context for AI

Provide relevant technical context specific to AI integration.

**Examples:**

- AI service provider (OpenAI, Anthropic, etc.)
- API version and authentication method
- Rate limits and quotas
- Cost per 1K tokens (estimate)
- Data privacy considerations (PII, sensitive data)
- Affected modules (ai_service.py, prompt_service.py)
- Database changes for storing AI interactions

Do not over-specify implementation unless necessary.  
The architect or implementer agents will handle detailed design.

### Step 7 — Define Quality Requirements for AI

Each AI feature must specify quality constraints.

**Typical examples for AI features:**

| Requirement | Target | Priority |
|-------------|--------|----------|
| Response time (p95) | < 3 seconds | High |
| Error rate (API failures) | < 2% | High |
| Cost per request | < $0.01 | Medium |
| Cache hit rate | > 30% | Medium |
| User satisfaction score | > 4/5 | High |
| Test coverage for AI error paths | > 80% | High |

### Step 8 — Define Development Plan for AI Features

Break the implementation into stages.

**Typical phases for AI features:**

1. **Foundation Phase** — API integration, error handling, configuration
2. **Prompt Engineering Phase** — Template design, testing different models
3. **Core Feature Phase** — User interface, history storage
4. **Optimization Phase** — Caching, cost optimization, performance tuning
5. **Validation Phase** — User testing, monitoring, analytics

Follow the architecture guidelines from `PROJECT.md`.

---

## Writing Guidelines for AI PRDs

When writing PRDs for AI features:

**Use clear language that distinguishes AI behavior from system behavior.**

**Prefer:**

- concise sentences
- structured sections
- concrete examples of prompts and responses
- explicit error handling scenarios

**Avoid:**

- vague descriptions like "AI should understand"
- unnecessary technical API details
- speculative AI capabilities
- assuming AI will always work perfectly

PRDs should describe **what must happen** during AI interactions, not **how to prompt engineer**.

---

## Acceptance Condition Rules for AI Features

Acceptance conditions must follow the format:

```
GIVEN [initial state]
WHEN [user action that triggers AI]
THEN [expected system behavior including AI interaction]
```

**For error conditions:**

```
GIVEN [initial state]
WHEN [user action triggers AI and AI service fails]
THEN [expected fallback behavior]
```

**Guidelines for AI acceptance conditions:**

- each condition must be testable (including mocking AI services)
- avoid ambiguous AI expectations
- define clear outcomes for both success and failure
- include performance expectations (response time)
- specify data persistence requirements

**Bad example:**
```
THEN the AI provides a helpful response
```

**Good example:**
```
THEN the AI returns a response with 3-5 bullet points
AND the response is saved to the database with prompt_id and timestamp
AND the total response time is under 3 seconds
AND if the AI service fails, a cached response is used if available
```

---

## PRD Validation Checklist for AI Features

Before finalizing the PRD ensure:

- [ ] the problem is clearly defined and AI is the right solution
- [ ] user scenarios exist with specific AI interactions
- [ ] acceptance conditions cover success and failure paths
- [ ] AI service details are specified (provider, model, cost estimates)
- [ ] error handling is explicitly defined
- [ ] scope boundaries are explicit (what AI will/won't do)
- [ ] technical context includes AI integration points
- [ ] quality requirements include performance and cost targets
- [ ] development phases account for AI-specific challenges
- [ ] data privacy considerations are addressed

---

## Relationship to AGENTS.md

PRDs drive the AI development workflow described in **AGENTS.md**.

AI agents must:

- read the PRD before implementing AI features
- map implementation to acceptance conditions for both success and error paths
- write tests that validate those conditions (including mocking AI services)
- implement proper error handling for AI service failures
- track and log AI costs as specified

PRDs therefore act as the **contract between product requirements and AI engineering implementation**.

---

## Output Location

Generated PRDs must be saved to:

```
docs/prds/[ai-feature-name].md
```

Use a clear feature name that indicates the AI capability.

**Examples:**

```
docs/prds/ai-text-summarization.md
docs/prds/ai-code-generation.md
docs/prds/ai-sentiment-analysis.md
docs/prds/ai-content-moderation.md
```

---

## Best Practices for AI PRDs

**Strong AI PRDs:**

- describe real user workflows enhanced by AI
- define measurable outcomes for AI interactions
- separate AI requirements from implementation details
- minimize ambiguity about AI capabilities
- explicitly address error scenarios
- consider cost and performance implications
- include examples of prompts and expected responses

**Weak AI PRDs:**

- describe vague AI "magic" without specifics
- mix product requirements with prompt engineering details
- omit acceptance conditions for error cases
- assume AI will work perfectly 100% of the time
- ignore cost implications
- lack testable criteria

---

## AI-Specific Considerations

### Cost Management
- Estimate cost per request based on token usage
- Define budget alerts and limits
- Consider caching strategies for repeated queries

### Privacy & Security
- Specify what data can be sent to external AI services
- Define PII handling and anonymization requirements
- Ensure API keys are never exposed to clients

### Prompt Engineering
- Store prompts in version-controlled templates
- Document expected input/output formats
- Plan for prompt iteration and A/B testing

### Monitoring
- Define metrics to track: token usage, cost, latency, error rates
- Set up alerts for anomalies
- Plan for user feedback collection on AI responses

---

This PRD template ensures that AI features in Project AI are well-defined, testable, and aligned with the project's architecture and development workflow.
