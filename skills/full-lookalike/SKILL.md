---
name: full-lookalike
description: "Finds people similar to a given LinkedIn profile (same role, seniority, industry, company size) with FullEnrich search. Use when the user shares a profile and says \"find more like this\", \"lookalikes\", or wants to expand an ICP from a won customer."
---

# Full Lookalike

See [references/fullenrich-reference.md](references/fullenrich-reference.md) for MCP tool names, response schema, statuses, and business rules.

## Rules

- Confirm matching criteria (title, seniority, industry, company size, geography) with the user before searching — result quality depends on which attributes are matched.
- Use `exact_match: false` for job titles by default because title wording varies across companies and regions.
- Explain *why* each lookalike matches, not just that they do — cite the specific attributes.
- Prefer fewer strong matches over padding with weak ones.
- If the source profile is not found in FullEnrich, ask the user for key attributes and build the search from those.

## Workflow

### 1. Analyze the source profile

Call `fullenrich:search_people` with the LinkedIn URL and `include_descriptions: true`. Extract: name, title, seniority, company (industry, headcount, location), career path, skills.

If not found, ask the user for title, company, industry, and seniority.

### 2. Confirm matching criteria

Present the extracted attributes and ask the user to validate:
- Title (suggest 2–3 variations)
- Seniority level
- Industry (call `fullenrich:list_industries` to find the exact match)
- Company size bracket
- Geography and company exclusion

Ask: how many lookalikes, and where to search.

### 3. Search

Call `fullenrich:search_people` with the confirmed criteria. If volume < requested, suggest broadening filters and let the user decide.

### 4. Rank and present

For each result, assess similarity across title, seniority, industry, company size, and location. Rank highest first.

For each lookalike, present: name, title, company, industry, headcount, LinkedIn URL, and a 1–2 sentence explanation of why this person matches.

### 5. Optional enrichment

If the user wants emails/phones: call `fullenrich:get_credits` first. Show: "Enriching [N] contacts will cost ~[estimate] credits. You have [balance]. Proceed?" — credits are the user's money and enrichment cannot be undone. Only after explicit "yes", call `fullenrich:enrich_search_contact` once with the same filters. Poll `fullenrich:get_enrichment_results`, then `fullenrich:export_contacts` (csv).

## Gotchas

- The "why this person matches" explanation is the most valuable output. Without it, this is just a search.
- Similarity scoring is a guide, not a science. If a profile has the exact same career trajectory, weight that even if the formal score is lower.
- `fullenrich:search_people` returns max 20 results. Use tight filters to get the best results and present the top N by similarity.
