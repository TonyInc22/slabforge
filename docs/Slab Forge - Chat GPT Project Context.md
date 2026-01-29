# SlabForge – ChatGPT Project Context

> **Purpose of this document**
> This file exists to provide consistent, high‑signal context to AI tools (ChatGPT, VS Code extensions, internal scripts) so architectural decisions, product intent, and constraints remain aligned over time.

---

## 1. Strategic Positioning

**SlabForge is the first grading‑first card intelligence platform** — helping collectors make smarter **buy, grade, and sell** decisions using real market data, not guesswork.

Core differentiator:

* Most card tools focus on collections or marketplaces
* SlabForge starts with **grading outcomes** and works backward to purchasing decisions

---

## 2. Primary Use Case (v1)

SlabForge v1 is optimized for **sports card investors / flippers**, not casual collectors.

Primary user questions:

* Is this card worth grading?
* What grade should I realistically expect?
* What is the expected ROI after grading fees?
* How often does this card gem?
* Are recent comps trending up or down?

Collection management may exist later, but is **not** the core focus of v1.

---

## 3. Core Product Principles

1. **Grading‑First Mental Model**
   Every feature should answer a grading‑related decision, directly or indirectly.

2. **Explainability Over Black Boxes**
   Scores, projections, and recommendations must show *why*.

3. **Hybrid Data Strategy**
   Mix of cached historical data + live marketplace pulls.

4. **API‑First Architecture**
   Frontend consumes the same API as any external client would.

5. **Sleeper‑Level Polish**
   Clean, modern UI with strong information hierarchy.

---

## 4. Target Card Scope (Initial)

Initial scope is intentionally narrow:

* Sport: **NFL**
* Era: Modern (2017+)
* Grading Company: **PSA**
* Focus:

  * Rookies
  * Short prints
  * Numbered cards
  * Case‑hit inserts

Expansion to other sports, graders, or eras is explicitly **post‑v1**.

---

## 5. Data Domains

SlabForge operates across several distinct data domains:

### 5.1 Card Metadata

* Player
* Set
* Year
* Card number
* Parallel / variation
* Print run (when known)

### 5.2 Grading Data

* PSA population reports
* Grade distribution
* Gem rate (PSA 10 %)

### 5.3 Market Data

* Historical sale prices
* Recent comps
* Active listings
* Trend direction

### 5.4 Cost Modeling

* Grading fees
* Shipping / insurance assumptions
* Platform selling fees

---

## 6. Core Metrics & Concepts

Key concepts SlabForge will surface:

* **Gem Rate**: % of graded copies receiving PSA 10
* **Expected Grade**: Weighted expectation based on population data
* **Expected ROI**: Projected sale price minus all costs
* **Risk Profile**: Variance between grades and price outcomes
* **Liquidity Score**: How frequently the card sells

These are **decision‑support metrics**, not guarantees.

---

## 7. Technical Stack

### Backend

* Node.js + Express
* TypeScript
* PostgreSQL
* Prisma ORM
* Dockerized services

### Frontend

* React
* TypeScript
* Modern component‑driven architecture

### Infrastructure

* API‑first design
* Environment‑based config
* Local‑first development

---

## 8. Data Strategy Guidelines

General rules:

* **Static or slow‑changing data** → stored locally
* **Volatile market data** → cached with TTL
* **High‑cost API calls** → aggressively cached

SlabForge should never depend on *only* live API calls for core views.

---

## 9. Non‑Goals (v1)

Explicitly out of scope for v1:

* Marketplace hosting
* Card vaulting
* Social feeds
* Arbitrary collection galleries
* Prediction guarantees

---

## 10. Tone & UX Philosophy

* Confident, not hype‑driven
* Data‑forward but approachable
* Minimal clutter
* Metrics explained in plain language

Think: *"Smart friend who knows the card market inside and out."*

---

## 11. How AI Should Use This File

When assisting on SlabForge, AI should:

* Preserve grading‑first thinking
* Avoid feature creep beyond v1 goals
* Favor explainable metrics
* Flag assumptions clearly
* Ask clarifying questions **only** when decisions materially affect architecture

---

## 12. Open Questions (Living Section)

* Final caching strategy per data source
* PSA population update frequency
* Handling low‑pop or missing data
* Monetization approach (free vs paid tiers)

---

## AI Instructions (How to Assist on SlabForge)

When helping with SlabForge, follow these rules:

1. **Preserve the grading-first mental model**  
   Prefer solutions that improve buy/grade/sell decisions.

2. **Avoid v1 scope creep**  
   Do not introduce marketplace hosting, social feeds, or collection-gallery-first flows unless explicitly requested.

3. **Prefer explainability**  
   Any score or recommendation must include the “why” (inputs, weights, caveats).

4. **Engineering output format (default)**
   - Plan (short)
   - Proposed data model / API shape
   - Implementation steps
   - Risks & edge cases
   - Next steps

5. **Prisma & DB safety**
   - Suggest schema changes with migration-safe steps
   - Call out indexes where they matter
   - Avoid storing volatile market data without TTL/caching rationale

6. **Assumptions**
   - If a key assumption is unknown, make a best-judgment default and label it clearly.


This section is expected to evolve.