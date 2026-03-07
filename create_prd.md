---
description: Gather requirements from the user and generate a Product Requirements Document (PRD) for Project AI
argument-hint: [output-filename]
---

# Create PRD: Product Requirements Document Generator for Project AI

## Overview

This instruction guides the agent through a **two-phase process** to create a PRD for **Project AI**:
1.  **Discovery** — gather product requirements through structured dialogue with the user.
2.  **Generation** — produce a complete `PRD.md` file based on the collected information.

**Output file:** `$ARGUMENTS` (default: `project_ai_prd.md`)

---

## Phase 1: Discovery (Requirements Gathering)

Before writing anything, the agent must understand the product deeply.

### Step 1 — Initial Read
Review the full conversation history. Extract:
- Core product idea / concept for Project AI.
- Any mentioned features, constraints, or goals.
- Technical preferences or stack mentions (e.g., specific AI models, frameworks).
- Target audience hints.

### Step 2 — Clarifying Questions
Ask the user **only the questions that remain unanswered** after reading the conversation. Group them logically and ask no more than **5–7 questions at once** to avoid overwhelming the user.

Use this question bank as a guide (adapt, skip, or add as needed):

**Product Identity**
- What core problem does Project AI solve? Who experiences this problem most acutely?
- What makes this AI-powered solution different from or better than existing alternatives?
- What does success look like 3 months after launch?

**Users**
- Who is the primary user? (e.g., a developer, a data analyst, a general consumer? What's their technical skill level?)
- Are there secondary user types (e.g., admins, API consumers, content moderators)?

**Scope**
- What is the single most important "killer" feature for the MVP?
- What features are explicitly out of scope for this first version?
- Are there hard deadlines or resource constraints (budget, team size)?

**Technical**
- Is there a preferred tech stack (e.g., Python, Node.js) or existing infrastructure to integrate with?
- What are the expected scale requirements (e.g., number of users, API requests per day)?
- Any compliance, security, or data residency requirements? (e.g., user data privacy, GDPR, HIPAA)

**Integrations**
- Does the product need to connect to external services? (e.g., specific LLM APIs like OpenAI, Anthropic; vector databases; auth providers)
- Will there be a public API for other services to interact with Project AI?

### Step 3 — Confirm Understanding
After gathering answers, provide a **1-paragraph summary** of your understanding and ask the user to confirm or correct before generating the PRD.

> **Example:** "Based on our conversation, I understand we are building an AI-powered tool called Project AI for [user type] to help them [core task]. The MVP will focus on [core feature] using [tech stack]. The main constraints are [deadline/budget]. Is this correct?"

---

## Phase 2: PRD Generation

Once requirements are confirmed, generate the PRD using the structure below.

### Writing Principles
- **Be specific** — avoid vague statements; prefer quantifiable metrics where possible (e.g., "AI response generation < 2 seconds").
- **Be honest about unknowns** — mark assumptions explicitly with `[ASSUMED]`.
- **Be scannable** — use headings, bullets, tables, checkboxes.
- **Be consistent** — use the same terminology throughout (e.g., consistently call the feature "AI Insight" not "Smart Suggestion").

---

## PRD Structure for `project_ai`

### 1. Header Block
Product: Project AI
Version: 0.1 (MVP Draft)
Status: Draft
Last Updated: [Current Date]
Author: [Agent/User]

---

### 2. Executive Summary
- What Project AI is (1 sentence).
- What core problem it solves and for whom (1–2 sentences).
- Core value proposition (the unique AI-powered benefit).
- MVP goal: a concise statement of what "done" looks like for version 1.

---

### 3. Problem Statement
- **Current pain:** What users struggle with today that Project AI will address.
- **Root cause:** Why existing (non-AI or other AI) solutions fall short.
- **Impact:** The consequences of the problem remaining unsolved (e.g., wasted time, missed insights, poor decisions).

---

### 4. Goals & Non-Goals

| Category | Item |
|----------|------|
| ✅ Goal | (e.g., Reduce time to analyze customer feedback by 50%) |
| ✅ Goal | (e.g., Provide accurate answers from internal documentation) |
| ❌ Non-Goal | (e.g., Build a fine-tuned model from scratch for the MVP) |
| ❌ Non-Goal | (e.g., Support real-time video analysis) |

Keep this table tight — 5–8 items max per column.

---

### 5. Target Users

For each persona:
- **Name / Role:** (e.g., "Data Analyst Dana", "Product Manager Priya")
- **Context:** When and how they use Project AI.
- **Key needs:** Top 3 things they need from the product.
- **Pain points:** What frustrates them in their current workflow.
- **Technical comfort:** Beginner / Intermediate / Advanced.

---

### 6. MVP Scope

#### In Scope ✅
Group by category (Core AI Features, Technical Foundation, Integrations, User Interface):
- ✅ (e.g., Core feature: Text summarization using an LLM)
- ✅ (e.g., Technical: User authentication via API key)
- ✅ (e.g., Integration: Connect to OpenAI API)

#### Out of Scope ❌
- ❌ (e.g., Feature: Multi-modal input (images) — deferred to v2)
- ❌ (e.g., Deployment: On-premise solution — cloud-only for MVP)

---

### 7. User Stories

Format: `As a [persona], I want to [action], so that [outcome].`

Include:
- 5–8 primary stories covering the core AI interaction loop.
- 2–3 edge case or error state stories (e.g., "As a user, I want to see a friendly error message if the AI service is unavailable, so that I know it's not my fault.").
- Acceptance criteria for each (bullet list).

---

### 8. Functional Requirements

Numbered list, grouped by feature area:
FR-01 [AI Processing]: The system shall accept user input as plain text via a web form.
FR-02 [AI Processing]: The system shall send this text to the configured LLM API (e.g., OpenAI) with a predefined prompt.
FR-03 [Output Handling]: The system shall display the AI's response to the user in the UI within [X] seconds.

Each requirement should be testable.

---

### 9. Non-Functional Requirements

| Requirement | Target / Description | Priority (High/Med/Low) |
|-------------|----------------------|--------------------------|
| **Performance** | AI response time < 3 seconds for 95% of requests. | High |
| **Availability** | Core functionality available 99.5% uptime during business hours. | Medium |
| **Security** | API keys (OpenAI, etc.) stored securely as environment variables, never exposed client-side. | High |
| **Scalability** | Handle initial pilot of [Number] users without degradation. | Low (MVP) |

---

### 10. Architecture Overview

- **High-level description:** A simple web application with a frontend, a backend API, and calls to external AI services.
- **Key components:**
    1.  **Frontend:** React/Vanilla JS application for user interaction.
    2.  **Backend API:** Python (Flask/FastAPI) or Node.js server handling requests, prompt engineering, and AI service calls.
    3.  **AI Service:** External provider like OpenAI API.
- **Data flow summary:** User input -> Frontend -> Backend API -> [Prompt Engineering] -> AI Provider -> Backend API -> Frontend -> User.
- **Directory / module structure:** (Optional, if relevant for the user)

---

### 11. Technology Stack

| Layer | Technology | Version | Rationale |
|-------|-----------|---------|-----------|
| Frontend | React | 18.x | Component-based, widely used. |
| Backend | Python / FastAPI | 0.104.x | Excellent for AI/ML integrations, high performance. |
| AI Integration | OpenAI Python Library | 1.x | Standard library for primary AI provider. |
| Infrastructure | Render / Vercel | - | Simple deployment for MVP. |

Include optional/future dependencies separately.

---

### 12. API Specification (if applicable)

For each internal endpoint:
POST /api/v1/generate-insight
Description: Sends user prompt to backend and returns AI-generated insight.
Auth: Required (API Key in header)
Request Body: { "prompt": "Summarize this text...", "user_context": "..." }
Response: { "insight": "The generated text...", "processing_time_ms": 1234 }
Errors: 400 (Bad Request), 401 (Unauthorized), 500 (AI Service Error)

---

### 13. Security & Configuration

- **Auth approach:** API keys for backend-to-frontend communication; user management might be out of scope for initial MVP.
- **Secrets management:** All API keys (OpenAI, database) stored in environment variables.
- **Environment variables list:** `OPENAI_API_KEY`, `DATABASE_URL` (if needed), `API_KEY`.
- **What's explicitly out of scope for security in MVP:** Role-based access control, advanced rate limiting.

---

### 14. Success Criteria

MVP is considered successful when:
- ✅ **Functional criteria:** User can input a prompt and receive a coherent AI-generated response.
- ✅ **Quality criteria:** 95% of successful requests return a response in under 5 seconds.
- ✅ **User criteria:** 3 pilot users can successfully complete the core task without direct developer assistance.

---

### 15. Implementation Phases

#### Phase 1 — Foundation (Week 1)
**Goal:** Establish backend API connection to AI provider.
- ✅ Set up project repository and basic structure.
- ✅ Implement a simple backend endpoint that calls OpenAI API and returns a hardcoded response.
- ✅ Configure environment variables for API key.
**Validation:** A `curl` command can successfully hit the endpoint and get a response from the AI.

#### Phase 2 — Core Features (Week 2)
**Goal:** Build the user interface and connect it to the backend.
- ✅ Create a basic React frontend with a text input and a submit button.
- ✅ Connect frontend to the backend API endpoint.
- ✅ Display the AI's response on the page.
**Validation:** An end-to-end test where a user types a prompt and sees the result.

#### Phase 3 — Polish & Launch (Week 3)
**Goal:** Refine, deploy, and prepare for pilot users.
- ✅ Add error handling for API failures.
- ✅ Implement basic loading state.
- ✅ Deploy application to a cloud platform (e.g., Render).
- ✅ Write basic documentation for pilot users.
**Validation:** The application is publicly accessible (with auth if required) and ready for testing.

---

### 16. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| **AI API Downtime / Latency** | Medium | High | Implement robust error handling and user-friendly messages. Consider a simple fallback or cache. |
| **High API Costs** | Medium | Medium | Set hard usage limits, monitor costs daily from day one, and optimize prompts for token efficiency. |
| **Scope Creep (adding more AI features)** | High | High | Strictly adhere to MVP scope defined in this document. Defer all new feature requests to "Future Considerations". |
| **Vague User Requirements** | Medium | High | Maintain close contact with pilot users during Phase 3 to validate assumptions early. |

---

### 17. Open Questions

List unresolved decisions that need input:
- [ ] **Data Retention:** How long, if at all, should we store user prompts and AI responses?
- [ ] **Pricing Model:** Is this a free internal tool, or will it be monetized later?
- [ ] **LLM Model Choice:** Should we start with `gpt-3.5-turbo` for speed/cost, or `gpt-4` for quality?

---

### 18. Future Considerations

Features and ideas intentionally deferred:
- **Post-MVP Enhancements:** Fine-tuning a model on specific data, adding memory/conversation history, supporting file uploads (PDF, DOCX).
- **Scaling Strategies:** Implementing a queue for processing, using a vector database for long-term memory.
- **Integration Opportunities:** Connecting to Slack, Discord, or other productivity tools.
- **Advanced Features:** Allowing users to select different AI models or provide custom prompts.

---

### 19. Appendix (optional)

- Links to related documents, designs, or repos.
- Glossary of terms (e.g., LLM, Prompt, Token, API).
- Reference architecture examples from similar AI tools.

---

## Output Confirmation

After generating the `project_ai_prd.md` file:
1.  State the file path where it was written (e.g., `./project_ai_prd.md`).
2.  List any `[ASSUMED]` items that need user validation.
3.  List any Open Questions that block progress.
4.  Suggest the immediate next step (e.g., "Now that the PRD is drafted, we can review the Open Questions and begin work on Phase 1: Foundation.")

---

## Agent Behavior Notes

- Do **not** skip Phase 1 if requirements are vague — always clarify first.
- Do **not** invent features not discussed or implied by the user.
- Do **not** ask all questions at once if only 2–3 are truly unknown.
- **Do** flag contradictions in user requirements and ask for resolution.
- **Do** mark every assumption with `[ASSUMED]` so the user can spot them quickly.
- Sections with insufficient information should say: `⚠️ Needs clarification — see Open Questions.`
