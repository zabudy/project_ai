
---
skill: skill-authoring
version: 1.0
applies-to: all
activates-when: "task involves creating or modifying skills in the /skills directory"
---

# SKILL.md — How to Write Skills for Project AI

## What Is a Skill?

A skill is a **modular, self-contained knowledge package** that extends `AGENTS.md` by giving a specialist agent procedural expertise in a specific domain. Skills do not replace agents — they equip them.

Think of it this way for Project AI:
- `AGENTS.md` defines **who** the agents are and **how** they collaborate in the AI development team
- `commands/` defines **what actions** agents can take (like `create-prd.md`, `plan-feature.md`)
- `skills/` defines **how to do things well** within an AI-specific domain

A skill answers the question: *"What does an expert in AI engineering know that a general-purpose model might get wrong?"*

---

## Skill File Structure for Project AI

Every skill lives at `skills/[domain]/SKILL.md` and must follow this structure:

```
skills/
└── [domain]/           ← e.g., `ai-prompting`, `cost-optimization`, `model-selection`
    └── SKILL.md        ← the skill file
```

If the skill needs supplementary reference material (patterns, snippets, checklists), add them as sibling files:

```
skills/
└── [domain]/
    ├── SKILL.md
    ├── patterns.md     ← optional: reusable AI prompt patterns
    └── checklist.md    ← optional: AI implementation review checklist
```

---

## Required Sections in Every Skill

### 1. Header Block
```yaml
---
skill: [domain-name]
version: 1.0
applies-to: [which agent(s) use this skill: product-manager, architect, implementer, tester, reviewer, all]
activates-when: [condition that triggers loading this skill]
---
```

**`applies-to`** — which agent loads this skill. For Project AI:
- `product-manager` — for skills about requirement gathering, PRD writing
- `architect` — for skills about system design, AI architecture
- `implementer` — for skills about coding, AI integration
- `tester` — for skills about testing AI systems
- `reviewer` — for skills about code review
- `all` — for foundational skills

**`activates-when`** — the condition that tells the orchestrator to inject this skill into the agent's context. Examples for Project AI:
- `PRD mentions "OpenAI" or "LLM integration"`
- `task involves prompt engineering`
- `feature requires cost tracking for AI API calls`
- `implementing RAG (Retrieval-Augmented Generation) pattern`

---

### 2. Domain Overview (2–3 sentences)
What this AI-specific domain is, why it's distinct from traditional software engineering, and what an agent without this skill would likely get wrong.

**Example for `ai-prompting` skill:**
"Prompt engineering is the discipline of designing inputs to LLMs to get reliable, structured outputs. Unlike traditional programming where behavior is deterministic, prompts require understanding model biases, token limitations, and output formatting. Without this skill, agents would treat prompts as simple strings and miss critical optimization opportunities."

---

### 3. Core Principles
5–10 opinionated, specific rules that define quality in this AI domain.

**Good principle for Project AI:** "Always set `temperature=0` for deterministic tasks like data extraction — only increase temperature for creative generation when explicitly required."

**Bad principle:** "Write good prompts." (too vague, not actionable)

Each principle should include:
- **The rule** (one sentence)
- **Why it matters** (one sentence, specific to AI systems)
- **What the violation looks like** (one sentence)

Example:
```
Rule: Version control prompts like code, stored in dedicated files, not embedded in application logic.
Why: Prompts evolve rapidly; embedding them makes iteration impossible and breaks the ability to A/B test.
Violation: A prompt string hardcoded inside a Python function with no history of changes.
```

---

### 4. Procedural Knowledge (the main body)
The "how to" content that a general-purpose model lacks. This is domain-specific to AI engineering. Structure it as step-by-step workflows, decision trees, or annotated patterns — whatever best captures the knowledge.

Organize by task type. Example for an `ai-integration` skill for Project AI:

#### How to Choose an AI Model
1. **Define the task type:** Classification? Generation? Summarization? Reasoning?
2. **Evaluate latency requirements:** Real-time (< 2s) vs. batch processing?
3. **Calculate cost constraints:** Budget per 1K tokens, monthly volume
4. **Check context window needs:** Does the task need 4K, 16K, or 100K+ tokens?
5. **Test with representative samples:** Run 20-50 examples through candidate models
6. **Document the decision:** Why this model, what tradeoffs were accepted

#### How to Implement an AI Call with Error Handling
1. Create a dedicated service class in `backend/src/services/ai_service.py`
2. Implement retry logic with exponential backoff for 5xx errors
3. Handle rate limits (429) with circuit breaker pattern
4. Set reasonable timeouts (start with 30s, adjust based on model)
5. Log token usage for cost tracking
6. Return structured errors to the API layer

#### How to Design a Prompt Template
1. Start with a clear system message defining the AI's role
2. Use delimiters (```, ---, ###) to separate instruction from input
3. Include few-shot examples for complex tasks
4. Specify output format (JSON, markdown, bullet points)
5. Add constraints (length, tone, what to avoid)
6. Test with edge cases before deploying

---

### 5. Patterns & Anti-Patterns
Concrete code-level (or design-level) examples of what to do and what to avoid in AI systems.

Format:
```
PATTERN: [name]
Context: when to use this in Project AI
✅ DO: [example or description]
❌ DON'T: [example or description]
Reason: [why the DO is better for AI systems]
```

Aim for 4–8 patterns per skill.

Example for `ai-prompting` skill:
```
PATTERN: Structured Output with JSON Mode
Context: When you need the AI to return data that will be parsed programmatically
✅ DO: 
   prompt = """
   Extract the following from the text:
   - name (string)
   - date (ISO format)
   - amount (number)
   
   Return as valid JSON only, no other text.
   """
❌ DON'T: "Extract the name, date, and amount from this text and return them."
Reason: Without format enforcement, the model might add explanations, vary key names, or include markdown, making parsing brittle and error-prone.
```

---

### 6. Integration Points
How this skill interacts with other parts of the Project AI system:

- **Which files this skill's output feeds into:**
  - `backend/src/services/ai_service.py` — for AI integration code
  - `backend/src/services/prompt_service.py` — for prompt templates
  - `backend/src/core/cost_tracker.py` — for usage monitoring
  - `docs/architecture/ai-architecture.md` — for design decisions

- **Which other skills this skill depends on or conflicts with:**
  - Depends on: `python-backend` skill for implementation details
  - Depends on: `testing` skill for AI-specific test patterns
  - Conflicts with: `performance` skill (caching vs. freshness tradeoffs)

- **What the `reviewer` agent should check specifically for this domain:**
  - Prompt injection vulnerabilities
  - Token usage optimization
  - Error handling for AI service failures
  - PII leakage to external AI providers

---

### 7. Review Checklist
A concrete list of things the `reviewer` agent must verify for code produced under this skill. These become the domain-specific criteria inside `commands/validation/code-review.md`.

Format: yes/no checkable items, specific enough to be unambiguous.

Example for `ai-integration` skill:
```
Review Checklist for AI Integration:

- [ ] Are all AI API keys stored in environment variables, never hardcoded?
- [ ] Is there proper error handling for rate limits (429) with retry logic?
- [ ] Are timeouts implemented (requests don't hang indefinitely)?
- [ ] Is token usage logged for cost tracking?
- [ ] Are prompts stored in dedicated files/modules, not inline strings?
- [ ] Is there validation of AI outputs before using them in business logic?
- [ ] Are user inputs sanitized to prevent prompt injection?
- [ ] Is PII removed or anonymized before sending to external AI providers?
- [ ] Are there tests mocking AI responses (both success and failure cases)?
- [ ] Is the model choice documented with rationale?
```

---

## Skill Writing Principles for Project AI

**Be opinionated about AI choices.** A skill that says "you can use OpenAI, Anthropic, or open-source models" is not a skill — it's a list. Pick the recommended approach for Project AI (e.g., "Start with OpenAI GPT-4 for complex reasoning, GPT-3.5 for high-volume simple tasks") and justify why.

**Be specific to our AI stack.** Project AI uses Python/FastAPI backend with OpenAI integration. Skills should reference:
- Actual libraries: `openai` Python library v1.x, `langchain` (if used)
- Actual file paths: `src/services/ai_service.py`
- Actual patterns: Pydantic models for request/response validation

**Capture what models get wrong.** The most valuable content in an AI skill is the non-obvious stuff — common mistakes like:
- Not handling token limits gracefully
- Forgetting that models have knowledge cutoff dates
- Assuming outputs are always truthful (hallucinations)
- Ignoring cost implications of different models

**Stay procedural.** Skills are how-to guides, not reference docs. "First, define the system message. Then, add few-shot examples. Finally, specify output format." is better than "Prompts consist of system messages, examples, and output specifications."

**Keep it scannable.** Agents read skills at the start of a task. Dense walls of text will be skimmed or ignored. Use headers, short paragraphs, and code examples.

---

## Skill Loading Protocol for Project AI

The orchestrator is responsible for loading skills. It should:

1. Read the `activates-when` field of all available skills at session start
2. Match conditions against:
   - The current PRD (`docs/prds/project_ai_prd.md`)
   - The task description from the command being executed
   - The current phase of implementation
3. Inject matching skill content into the target agent's context before the agent begins work
4. Log which skills were loaded in the Prime Report (see `commands/core_piv_loop/prime.md`)

An agent must not load its own skill — the orchestrator always decides.

---

## Available Skills for Project AI

| Skill | Domain | Applies To | Location |
|-------|--------|-----------|----------|
| skill-authoring | Writing skills for AI development | `all` | `skills/skill-authoring/SKILL.md` |
| ai-prompting | Prompt design, optimization, versioning | `implementer`, `reviewer` | `skills/ai-prompting/SKILL.md` |
| ai-integration | LLM API integration, error handling, retries | `implementer`, `architect`, `reviewer` | `skills/ai-integration/SKILL.md` |
| cost-optimization | Token tracking, model selection, caching | `architect`, `implementer`, `reviewer` | `skills/cost-optimization/SKILL.md` |
| rag-patterns | Retrieval-Augmented Generation design | `architect`, `implementer` | `skills/rag-patterns/SKILL.md` |
| testing-ai | Testing strategies for AI components | `tester`, `reviewer` | `skills/testing-ai/SKILL.md` |
| frontend-react | React UI components for AI interfaces | `coder`, `reviewer` | `skills/frontend-react/SKILL.md` |
| python-backend | FastAPI backend development | `coder`, `architect`, `reviewer` | `skills/python-backend/SKILL.md` |
| database-postgres | PostgreSQL schema, migrations, queries | `architect`, `coder`, `reviewer` | `skills/database-postgres/SKILL.md` |

---

## Adding a New Skill for Project AI

1. Identify the AI-specific domain gap (what would an expert know that our agents miss?)
2. Create `skills/[domain]/SKILL.md` following this structure
3. Fill all required sections — no empty sections allowed
4. Add concrete examples that reference Project AI's actual codebase structure
5. Add the skill to the **Available Skills** table above
6. Define a precise `activates-when` condition — vague conditions cause skill over-loading
7. Add domain-specific checks to `commands/validation/code-review.md` under a new section

---

## What a Skill Is NOT for Project AI

- Not a tutorial on AI concepts for humans (agents are AI themselves)
- Not a list of OpenAI documentation links (agents can access those directly)
- Not a style guide (unless style directly affects AI output quality)
- Not a replacement for `PROJECT.md` or `AGENTS.md` — skills are reusable patterns, project config is specific

---

## Example: Minimal Valid Skill for Project AI

```markdown
---
skill: example-skill
version: 1.0
applies-to: implementer
activates-when: "task involves example pattern"
---

# Example Skill for Project AI

## Domain Overview
This is an example of the minimal valid skill structure.

## Core Principles
1. **Keep it simple** — start with the simplest working solution.
   Why: Complexity is the enemy of AI system reliability.
   Violation: Adding caching before proving the basic flow works.

## Procedural Knowledge
Step 1: Create the basic implementation
Step 2: Test with real AI calls
Step 3: Add error handling
Step 4: Optimize only if needed

## Patterns & Anti-Patterns
PATTERN: Start Simple
Context: First implementation of any AI feature
✅ DO: Make a single direct API call with minimal processing
❌ DON'T: Add retries, caching, and fallbacks from day one
Reason: You need a baseline to know what needs optimization.

## Integration Points
This skill feeds into `src/services/` implementations.

## Review Checklist
- [ ] Is there a basic working version before optimizations?
- [ ] Is the implementation testable with mocked AI responses?
