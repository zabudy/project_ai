---
name: frontend_dev
description: Frontend development for Project AI — React 18 components, TypeScript, and FastAPI integration. Use when creating or modifying frontend code: components, pages, custom hooks, or API service calls.
---

## Project Layout

```
frontend/src/
├── components/   # Reusable UI components
├── pages/        # Route-level pages
├── hooks/        # Custom React hooks
├── services/     # API calls — all fetch/axios logic lives here
├── types/        # TypeScript interfaces
└── utils/
```

## Key Patterns

**Component with AI request** — always handle all three states:
```tsx
const SummaryWidget: React.FC<{ text: string }> = ({ text }) => {
  const { summary, isLoading, error } = useSummary(text);
  if (isLoading) return <LoadingSpinner />;
  if (error) return <ErrorMessage message={error} />;
  return <SummaryDisplay summary={summary} />;
};
```

**AI content rules:**
- Show a loading indicator on every AI request
- Never render raw AI responses without sanitization
- Never expose technical error details to the user — show friendly messages only

**TypeScript:** strict mode, no `any`, define interfaces in `types/`.

## Commands
```bash
cd frontend && npm run lint && npm run typecheck
```
