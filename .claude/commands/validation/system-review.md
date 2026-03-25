
---
description: Analyze AI feature implementation against plan for process improvements
---

# System Review for Project AI

Perform a meta-level analysis of how well the AI feature implementation followed the plan and identify process improvements for future AI development.

## Purpose

**System review is NOT code review.** You're not looking for bugs in the AI code - you're looking for bugs in the process of building AI features.

**Your job:**

- Analyze plan adherence and divergence patterns in AI feature development
- Identify which divergences were justified vs problematic for AI projects
- Surface process improvements that prevent future AI-specific issues
- Suggest updates to Layer 1 assets (`AGENTS.md`, `PROJECT.md`, PRD templates, commands)

**Philosophy for AI Projects:**

- **Good divergence** reveals plan limitations around AI behavior/costs → improve planning with better AI requirements
- **Bad divergence** reveals unclear requirements about AI expectations → improve communication about AI capabilities
- **Repeated issues** (prompt injection, cost overruns, hallucination handling) reveal missing automation → create commands/checks
- **AI-specific patterns** need to be codified - prompt management, cost tracking, fallback strategies

## Context & Inputs

You will analyze four key artifacts for this AI implementation:

| Artifact | Purpose |
|----------|---------|
| **Plan Command** | How planning instructions guide AI feature design |
| `.claude/commands/plan-feature.md` | |
| **Generated Plan** | What the agent was SUPPOSED to build for the AI feature |
| Plan file: $1 | |
| **Execute Command** | How execution instructions guide AI implementation |
| `.claude/commands/execute.md` | |
| **Execution Report** | What the agent ACTUALLY built and why (especially AI divergences) |
| Execution report: $2 | |
| **PRD Reference** | Original requirements for the AI feature (optional but helpful) |
| `docs/prds/project_ai_prd.md` | |

## Analysis Workflow for AI Projects

### Step 1: Understand the Planned AI Approach

Read the generated plan ($1) and extract:

- **AI Features**: What AI capabilities were planned? (summarization, chat, generation?)
- **AI Architecture**: What models, prompts, and integrations were specified?
- **Validation Steps**: How was AI quality/performance supposed to be validated?
- **Cost Considerations**: Were token budgets and cost limits defined?
- **Fallback Strategies**: What happens when AI is unavailable?
- **Patterns Referenced**: Which prompt patterns, error handling approaches were mentioned?

### Step 2: Understand the Actual AI Implementation

Read the execution report ($2) and extract:

- **What was implemented?** (core AI functionality, integrations)
- **What diverged from the plan?** (prompt changes, model choices, caching)
- **What AI-specific challenges?** (rate limits, token limits, quality issues)
- **What was skipped and why?** (features deferred, cost concerns)
- **AI metrics collected?** (token usage, latency, cost estimates)

### Step 3: Classify Each Divergence

For each divergence identified in the execution report, classify as:

**Good Divergence ✅** (Justified for AI projects):

- **Plan assumed simpler AI behavior** - reality required more sophisticated prompting
- **Better pattern discovered** - found more efficient prompt template or caching strategy
- **Cost optimization needed** - realized plan would be too expensive; switched model/approach
- **Security issue discovered** - prompt injection vulnerability required different approach
- **User experience insight** - streaming felt better than batch, even if not planned
- **Model limitation encountered** - token limits required chunking; adapted approach

**Bad Divergence ❌** (Problematic for AI projects):

- **Ignored explicit AI constraints** (budget limits, model restrictions)
- **Created ad-hoc prompts** instead of using planned prompt management system
- **Skipped cost tracking** - implemented without monitoring; risk of runaway costs
- **No fallback mechanism** - ignored plan requirement for graceful degradation
- **Misunderstood AI capabilities** - built feature expecting capabilities that don't exist
- **Prompt injection vulnerable** - didn't sanitize user input as planned

### Step 4: Trace Root Causes for AI Issues

For each problematic divergence, identify the root cause specific to AI development:

- **Was the AI requirement unclear?** Where? Why? (e.g., "generate summary" vs "generate 3-bullet executive summary")
- **Was context about AI limitations missing?** (model context windows, pricing, latency)
- **Was validation missing for AI outputs?** (quality checks, hallucination detection)
- **Was manual prompt tuning repeated?** Where? Why wasn't it automated?
- **Were cost guardrails missing?** (no budget limits, no token tracking)
- **Was AI testing inadequate?** (mocked too early, didn't test edge cases)

### Step 5: Generate Process Improvements for AI Development

Based on patterns across divergences, suggest:

- **AGENTS.md updates:** Universal AI patterns or anti-patterns to document
- **PROJECT.md updates:** AI stack clarifications, cost guidelines
- **PRD template updates:** Better AI requirement specification format
- **Plan command updates:** Instructions that need clarification or missing steps
- **New commands:** Manual processes that should be automated (prompt validation, cost estimation)
- **Validation additions:** Checks that would catch AI issues earlier

## Output Format

Save your analysis to: `.agents/system-reviews/ai-[feature-name]-review-[YYYYMMDD].md`

### Report Structure:

#### Meta Information

| Field | Value |
|-------|-------|
| **Feature reviewed** | [e.g., AI Summarization MVP] |
| **Plan reviewed** | [path to $1] |
| **Execution report** | [path to $2] |
| **PRD reference** | [path to PRD section] |
| **Date** | YYYY-MM-DD |
| **Reviewer** | [agent name] |

#### Overall Alignment Score: \_\_/10

Scoring guide for AI projects:

- **10**: Perfect adherence, all AI divergences justified (cost, UX, security)
- **7-9**: Minor justified divergences (prompt improvements, caching additions)
- **4-6**: Mix of justified and problematic divergences (cost tracking missing, but good UX)
- **1-3**: Major problematic divergences (security issues, no fallbacks, cost runaway risk)

#### Divergence Analysis

For each divergence from the execution report:

```yaml
divergence: [what changed from AI plan]
planned: [what plan specified for AI behavior]
actual: [what was implemented]
reason: [agent's stated reason from report]
classification: good ✅ | bad ❌
justified: yes/no
ai_specific_category: [prompting | model_selection | cost | security | ux | fallback]
root_cause: [unclear requirement | missing context | tool limitation | etc]
```

**Example:**

```yaml
divergence: Added Redis caching for AI responses
planned: No caching for MVP
actual: Implemented Redis cache for identical prompts
reason: "Noticed repeated requests during testing; caching reduces cost and latency"
classification: good ✅
justified: yes
ai_specific_category: cost
root_cause: plan didn't account for real usage patterns; cost optimization discovered late
```

#### Pattern Compliance for AI Projects

Assess adherence to documented AI patterns from `AGENTS.md` and `PROJECT.md`:

- [ ] **Prompt management**: Prompts stored separately, versioned
- [ ] **Cost tracking**: Token counting and budget limits implemented
- [ ] **Error handling**: Graceful degradation for AI service failures
- [ ] **Security**: Input sanitization, output validation for prompt injection
- [ ] **Testing**: AI services mocked properly; edge cases tested
- [ ] **Monitoring**: Logging includes token counts and latency
- [ ] **Architecture**: Followed AI integration patterns from design doc

#### System Improvement Actions for AI Development

Based on analysis, recommend specific actions with exact text suggestions:

**Update AGENTS.md:**

- [ ] Add section on "Prompt Management Best Practices"
  ```markdown
  ## Prompt Management
  - Store all prompts in `backend/src/services/prompts/` as separate `.txt` or `.jinja2` files
  - Version prompts with git; never hardcode in services
  - Include expected input/output examples in comments
  - Document token budget for each prompt
  ```

- [ ] Clarify [cost tracking requirement]
  ```markdown
  ## Cost Tracking
  Every AI feature MUST:
  - Count input and output tokens for each request
  - Log token usage with request ID
  - Check against daily budget limits before processing
  ```

**Update PROJECT.md:**

- [ ] Add [model selection guidelines]
  ```markdown
  ## Model Selection Criteria
  - MVP: Start with GPT-3.5-turbo for cost/speed unless quality requires GPT-4
  - Document model choice and rationale in architecture docs
  - Make model configurable via environment variable
  ```

**Update PRD Template (`create_prd.md`):**

- [ ] Add [AI requirements section]
  ```markdown
  ### AI Requirements
  - **Expected output format**: [e.g., JSON, markdown, plain text]
  - **Quality bar**: [e.g., "must be coherent", "must cite sources"]
  - **Token budget per request**: [input max, output max]
  - **Latency target**: [e.g., < 3 seconds p95]
  - **Cost constraints**: [e.g., < $0.01 per request]
  - **Fallback behavior**: [e.g., show error message, use cache]
  ```

**Update Plan Command (`plan-feature.md`):**

- [ ] Add instruction for [token budget estimation]
- [ ] Clarify [prompt injection mitigation requirements]
- [ ] Add validation step for [AI cost modeling]

**Create New Commands:**

- [ ] `/estimate-ai-cost` - For estimating token usage and costs before implementation
  ```bash
  # New command that:
  # 1. Takes prompt template and expected usage patterns
  # 2. Estimates monthly cost for different models
  # 3. Flags if over budget
  ```

- [ ] `/validate-prompts` - For checking prompt quality and injection risks
  ```bash
  # New command that:
  # 1. Scans for hardcoded prompts
  # 2. Checks for input sanitization
  # 3. Validates prompt format
  ```

**Update Execute Command (`execute.md`):**

- [ ] Add [cost tracking verification] to implementation checklist
- [ ] Add [prompt injection test requirement]

#### Key Learnings for AI Development

**What worked well in this implementation:**

- **Prompt separation**: Moving prompts to files made iteration easier
- **Streaming implementation**: Better UX than planned; should be default for chat features
- **Error handling**: Good coverage of AI service failures
- **Testing approach**: Mocked AI responses enabled deterministic tests

**What needs improvement in our AI development process:**

- **Cost estimation**: No way to predict costs before implementation; led to surprises
- **Prompt injection awareness**: Team needs better training; almost shipped vulnerability
- **Model selection criteria**: Unclear when to use GPT-3.5 vs GPT-4
- **Token counting**: Added late; should be from day one

**For next AI feature implementation:**

- Add cost estimation to planning phase
- Include prompt injection tests in security checklist
- Make model configurable from start
- Add token counting template to boilerplate

#### Summary Assessment

**One-paragraph summary:**

"This implementation successfully delivered the core AI functionality with good attention to UX and error handling. The major divergence to add caching was justified and valuable for cost control. However, we identified critical gaps in our process: prompt injection nearly shipped, cost estimation wasn't part of planning, and token counting was retrofitted. The prompt management approach (separate files) worked well and should become standard. Primary recommendations are to add AI-specific sections to PRD templates, create cost estimation commands, and enhance security validation in the execution checklist."

#### Sign-off

```
System review completed by: [agent name]
Date: YYYY-MM-DD
Follow-up issues created: [#123, #124]
Assets updated: [AGENTS.md, PRD template]
```

## Important

- **Be specific about AI issues:** Don't say "security was unclear" - say "plan didn't specify prompt injection mitigation strategy"
- **Focus on AI patterns:** One-off issues aren't actionable. Look for repeated problems across AI features
- **Action-oriented with exact text:** Every finding should have a concrete asset update suggestion with the actual text to add
- **Cost-aware analysis:** Always consider cost implications of process gaps
- **Model-awareness:** Note when issues stem from misunderstanding model capabilities/limitations
- **Link to evidence:** Reference specific sections of execution report when possible

