---
name: full-prospecting
description: "Finds B2B contacts matching an ICP with FullEnrich search, then enriches emails and phones after the user confirms the credit cost. Use when the user wants a prospect or lead list by title, seniority, industry, location, or company size."
---

# Full Prospecting

See [references/fullenrich-reference.md](references/fullenrich-reference.md) for MCP tool names, response schema, statuses, and business rules.

## Rules

- Search is free; enrichment costs credits. Validate volume with `fullenrich:search_people` before any enrichment.
- If `metadata.total` < requested count, say so and propose broader filters before spending.
- If the title is vague and no company size or industry is given, ask for one — results vary too much otherwise.
- Call `fullenrich:list_industries` (and `fullenrich:list_seniorities` when relevant) before using those filters; common terms like "SaaS" or "AI" are not valid values.
- Never invent contacts; report missing data as not found.

## Workflow

### 1. Check credits

Call `fullenrich:get_credits`. Show balance and estimate: ~1 credit/email, ~10 credits/phone × requested count. Warn if balance is insufficient.

### 2. Collect filters

Map the user's request to person filters (title, seniority, location, skills) and company filters (industry, headcount, HQ, type). Use `exact_match: false` for job titles by default because exact wording varies across companies and regions.

If industry filter is needed, call `fullenrich:list_industries` first — never guess values.

### 3. Preview

Call `fullenrich:search_people` to validate filters and volume. Show: "[total] contacts match. Here's a preview."

- If volume < requested → stop, suggest broadening title/location/industry.
- If title returns 0 → explain that this exact title may not be common and suggest 2–3 variations.

### 4. Confirm and enrich

No credits are spent until the user says "yes". Show: "[X] contacts found. Enriching [N] with [fields] will cost ~[estimate] credits. You have [balance]. Proceed?" — credits are the user's money and enrichment cannot be undone.

Only after explicit confirmation, call `fullenrich:enrich_search_contact` once with the same filters and the user's requested `limit` (never the default 10000).

### 5. Poll and export

Poll `fullenrich:get_enrichment_results` for progress (it caps at 10 results — never use it for final data).

After status = FINISHED, call `fullenrich:export_enrichment_results` (format: csv) with the returned enrichment ID to retrieve all results. Present: Full Name, Title, Company, Headcount, Location, LinkedIn, Email, Phone.

## Gotchas

- `fullenrich:search_people` returns max 20 results with no pagination. Use `metadata.total` for volume, not manual paging.
- CREDITS_INSUFFICIENT means "no data found", not "out of credits" — explain this to the user.
- CSV export is ~10x lighter than JSON. Use CSV unless the user asks for JSON.
- If export fails due to file size, provide the download URL instead.
