---
name: full-org
description: "Maps a company's team structure from FullEnrich search results into an org chart (Mermaid) and recommends who to contact for a sales, partnership, or hiring goal. Use when the user asks \"who works at X\" or \"org chart\"."
---

# Full Org Chart

See [references/fullenrich-reference.md](references/fullenrich-reference.md) for MCP tool names, response schema, statuses, and business rules.

## Rules

- Always ask the user's objective (selling, partnership, recruitment, research) before recommending who to contact — the same org chart serves different purposes.
- For companies with 50+ employees, strongly recommend scoping to a department or leadership layer rather than mapping the entire company.
- The hierarchy is inferred from titles and seniority, not actual reporting lines. Always include this disclaimer.
- Calibrate titles to company size: a CTO at a 10-person startup and a CTO at Google are completely different roles.

## Workflow

### 1. Identify the company

Accept: company name, domain, or LinkedIn company URL. Call `fullenrich:search_companies` with `include_descriptions: true` for context (industry, headcount, HQ).

If the name is ambiguous, ask for domain or LinkedIn URL.

### 2. Ask scope and objective

1. **Scope**: full company or specific department? For 50+ employees, recommend scoping.
2. **Objective**: selling, partnership, recruitment, or research? This shapes who to recommend.

### 3. Search for people

Call `fullenrich:search_people` with the company domain/name. Strategy by scope:

- **Full company / leadership**: up to 3 searches by seniority (C-level + VP, Directors + Heads, Managers).
- **Specific department**: 1–2 searches filtered by department title keywords.

Use `include_descriptions: true`. Deduplicate by name + company.

### 4. Infer hierarchy

Group by seniority level (Executive → C-Suite → VP → Director → Manager → IC) and by function (Engineering, Sales, Marketing, Product, etc.) based on title keywords.

### 5. Generate org chart

Produce a Mermaid `graph TD` diagram showing the hierarchy. Keep it readable: if > 20 people, show levels 1–4 in the diagram and list the rest as text.

Also provide a text summary below the diagram for clients that don't render Mermaid.

### 6. Recommend who to contact

Based on the objective:
- **Selling**: decision-maker (budget authority), champion (day-to-day user), potential blocker (security/procurement).
- **Partnership**: partnership lead, executive sponsor.
- **Recruitment**: hiring manager, team lead, HR/Talent.

For each recommended person: name, title, LinkedIn URL, why they're the right contact (1–2 sentences), and suggested approach order.

### 7. Optional enrichment

If the user wants email/phone for recommended contacts: call `fullenrich:get_credits` first. Show: "Enriching [N] contacts will cost ~[estimate] credits (email + phone). You have [balance]. Proceed?" — credits are the user's money and enrichment cannot be undone. Only after explicit "yes", call `fullenrich:enrich_search_contact` once. Poll `fullenrich:get_enrichment_results`, then `fullenrich:export_contacts` (csv).

## Org chart analysis

After presenting the chart, add 3–4 observations the data supports:
- Team size signals (e.g. "15 engineers vs. 3 in sales — product-led company").
- Gaps (e.g. "No Head of Security — could be a hiring signal").
- Recent changes (< 6 months in role → still building their stack/team).
- Flat vs. deep structure.

## Gotchas

- `fullenrich:search_people` returns max 20 results. Scoping by department or seniority is essential for large companies.
- Don't force structure: some companies are genuinely flat. If everyone is "Co-Founder" or "Engineer", present what the data shows.
- The Mermaid diagram must stay readable — more than 20 nodes makes it messy.
