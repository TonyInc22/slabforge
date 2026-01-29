# SlabForge

SlabForge is the first **grading-first card intelligence platform** — helping collectors make smarter **buy, grade, and sell** decisions with real market data, not guesswork.

## What SlabForge Does (v1)
SlabForge v1 is optimized for **sports card investors / flippers** (not casual collection galleries).

Core questions it helps answer:
- Is this card worth grading?
- What grade should I realistically expect?
- What is the expected ROI after grading fees?
- How often does this card gem (PSA 10 %)?
- Are recent comps trending up or down?

## Tech Stack
- **Backend:** Node.js, Express, TypeScript, PostgreSQL, Prisma
- **Frontend:** React, TypeScript
- **Workspace:** pnpm workspaces
- **Infra:** Docker Compose for local development

## Repo Structure
```txt
apps/
  api/      # Backend API (Node/Express/TS)
  web/      # Frontend web app (React/TS)
docs/       # Product + architecture context
docker-compose.yml
pnpm-workspace.yaml