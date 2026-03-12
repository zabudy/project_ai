---
description: Technical code review for AI project quality and bugs that runs pre-commit
---

# Code Review for Project AI

Perform technical code review on recently changed files for the AI-powered project.

## Core Principles

Review Philosophy for AI Projects:

- **Simplicity is key** - AI features can easily become complex; every line must justify its existence
- **Cost awareness** - inefficient code can lead to excessive token usage and API costs
- **Observability** - AI systems must be instrumented for monitoring costs, latency, and quality
- **Graceful degradation** - AI services can fail; code must handle failures gracefully
- **Security first** - Prompt injection, data leakage, and API key exposure are critical risks
- **The best AI code is often the code you don't write** - leverage existing libraries and patterns

## What to Review

Start by gathering codebase context to understand the AI project standards and patterns.

Start by examining:

- `AGENTS.md` - agent instructions and workflow
- `PROJECT.md` - project configuration and tech stack
- `README.md` - project overview
- Key files in the `/backend/src/core` and `/backend/src/services` directories
- Documented standards in the `/docs` directory, especially `docs/architecture/ai-architecture.md`

After you have a good understanding, run these commands:

bash
git status
git diff HEAD
git diff --stat HEAD
Then check the list of new files:

bash
git ls-files --others --exclude-standard
Read each new file in its entirety. Read each changed file in its entirety (not just the diff) to understand full context.

AI-Specific Review Areas
For each changed file or new file, analyze for standard issues plus these AI-specific concerns:

1. Logic Errors
Off-by-one errors in token counting

Incorrect prompt formatting

Missing error handling for AI service timeouts

Race conditions in async AI calls

Incorrect handling of streaming responses

2. Security Issues
CRITICAL: Exposed API keys (OpenAI, Anthropic) in code or logs

CRITICAL: Prompt injection vulnerabilities (user input not sanitized)

HIGH: PII (Personally Identifiable Information) sent to AI without anonymization

HIGH: Missing rate limiting on AI endpoints

MEDIUM: Insufficient output validation/sanitization

3. Performance & Cost Problems
HIGH: Inefficient token usage (redundant context, poor prompting)

MEDIUM: Missing caching for identical or similar requests

MEDIUM: N+1 queries to database after AI processing

LOW: Unnecessary AI calls that could be handled locally

CRITICAL: No cost tracking or budget limits implemented

4. AI-Specific Code Quality
Prompts hardcoded instead of stored in dedicated prompt files

Missing versioning for prompts

Poor error messages for AI service failures

Lack of telemetry/cost tracking

No fallback mechanisms when AI service is unavailable

5. Adherence to Codebase Standards
Adherence to standards documented in PROJECT.md

Python/TypeScript linting, typing, and formatting standards

Logging standards (especially for AI interactions)

Testing standards (mocking external AI services)

Verify Issues Are Real
Run specific tests for issues found

Confirm type errors are legitimate with mypy or TypeScript compiler

Validate security concerns by checking if user input reaches AI without sanitization

For cost concerns, estimate token usage impact

Test AI service failure scenarios

Output Format
Save a new file to .agents/code-reviews/review-[YYYYMMDD-HHMMSS].md

Stats:

Files Modified: 0

Files Added: 0

Files Deleted: 0

New lines: 0

Deleted lines: 0

For each issue found:

text
severity: critical|high|medium|low
category: logic|security|performance|quality|ai-specific
file: path/to/file.py or frontend/src/file.tsx
line: 42
issue: [one-line description]
detail: [explanation of why this is a problem]
impact: [what could go wrong - e.g., "could expose API key", "could increase costs by $X/month"]
suggestion: [how to fix it with code example if helpful]
Example AI-specific issue:

text
severity: critical
category: security
file: backend/src/api/routes/chat.py
line: 78
issue: User input directly concatenated into AI prompt without sanitization
detail: Line 78 takes `user_message` from request body and directly inserts it into the prompt template using f-string.
impact: Attacker could inject malicious instructions to manipulate AI behavior, ignore system prompts, or extract sensitive information.
suggestion: Use a structured prompt template with proper variable substitution and add input validation. Example:
   ```python
   # Instead of:
   prompt = f"System: Be helpful. User: {user_message}"
   
   # Use:
   validated_input = validate_and_sanitize(user_message, max_length=500)
   prompt_template = load_prompt("chat_template")
   prompt = prompt_template.format(user_input=validated_input)
text

If no issues found: 
✅ Code review passed. No technical issues detected.

Summary:

Code follows project patterns

AI integrations properly handled

Error cases covered

Cost/token usage appropriate for MVP

text

## Important

- **Be specific** (line numbers, not vague complaints)
- **Focus on real bugs, not style** (style is handled by linters)
- **Suggest fixes with examples**, don't just complain
- **Flag security issues as CRITICAL** - especially API keys and prompt injection
- **Flag cost issues appropriately** - estimate potential waste
- **Consider AI-specific failure modes** - what happens when OpenAI is down?
- **Check for proper mocking in tests** - tests should mock AI APIs, not call them

## Review Checklist for AI Projects

- [ ] No API keys or secrets exposed
- [ ] User input sanitized before reaching AI
- [ ] AI outputs validated before displaying to users
- [ ] Proper error handling for AI service failures
- [ ] Rate limiting implemented on AI endpoints
- [ ] Cost tracking/logging in place
- [ ] Token usage optimized (not sending unnecessary context)
- [ ] Prompts stored separately, not hardcoded
- [ ] Async/await properly used (no blocking calls)
- [ ] Tests mock AI services (no real API calls in tests)
- [ ] Graceful degradation when AI is unavailable
- [ ] Logging includes token counts and latency (without PII)
