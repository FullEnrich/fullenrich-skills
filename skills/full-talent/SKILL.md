---
name: full-talent
description: "Searches FullEnrich for people who match a role's criteria (title, skills, location, company type) and enriches their contact details after cost confirmation. Use when the user is hiring or recruiting. Search and contact lookup only. Not for sales prospecting (full-prospecting)."
---

# Full Talent Sourcing

See [references/fullenrich-reference.md](references/fullenrich-reference.md) for MCP tool names, response schema, statuses, and business rules.

## Scope

- This skill searches for profiles and looks up their contact details. That is all it does.
- It does not score, rank, tier, shortlist, or screen people, and it does not label anyone a fit or a reject. The user reads the profiles and makes every hiring decision.
- If the user asks for a ranking, a fit score, or a pass/reject label, say it is outside this skill and offer to narrow the search filters instead.

## Rules

- Always ask for the user's company domain and exclude it from results. Never source their own employees.
- Search only on job-related criteria the user states: title, skills, seniority, location, company type. Never filter on or infer age, gender, ethnicity, health, or any other protected characteristic.
- Probe vague requirements: "Senior Engineer" means different things at a 10-person startup vs. a 5,000-person enterprise. Ask about scope, stack, and team.
- Present results in the order the search returns them, with the same fields for every person.
- Default to email + phone for enrichment, and let the user choose fewer fields.

## Workflow

### 1. Intake

Start with open questions: what role, what the team looks like, which criteria are required, and the user's company domain (for exclusion).

Probe based on answers:
- Vague title → ask about scope (IC vs. team lead vs. architect).
- Generic skills → ask about the specific context (e.g. "Python for data science" vs. "Python for backend APIs").
- No location → ask about on-site/hybrid/remote and timezone constraints.

If the user shares a reference profile, use it only to derive search filters (title, skills, seniority, company type).

Keep probing until the role, required skills, location, target company profile, and exclusions are clear.

### 2. Confirm search filters

Summarize: role + scope, required skills, location, target company profile, exclusions, volume. Wait for confirmation.

### 3. Search

If an industry filter is needed, call `fullenrich:list_industries` first. Call `fullenrich:search_people` as a preview and report `metadata.total`.

If volume < requested, say so and suggest which filter to broaden. If volume is far above the request, suggest which filter to tighten. The user decides.

### 4. Enrich

Call `fullenrich:get_credits`. Estimate: [count] × ~11 credits (email + phone).

Show the cost estimate and balance, wait for explicit "yes", then call `fullenrich:enrich_search_contact` once with `limit` set to the exact count the user confirmed and fields `["contact.work_emails", "contact.phones"]`. The default limit is 10000, so omitting it will enrich far more contacts than the user approved. Poll `fullenrich:get_enrichment_results` every ~20s (progress only). After FINISHED, call `fullenrich:export_enrichment_results` (csv, using the returned enrichment ID) for all results.

### 5. Present

Show a summary: total found, the filters used, email/phone found %.

Then list every person in search order with the same fields: name, title, company, location, LinkedIn URL, email, phone. Add factual profile fields on request (career path, education, listed skills). Do not add a fit assessment or an order of preference.

## Gotchas

- Titles do not travel across company sizes: a "CTO" at a 5-person startup is a tech lead who codes. Pair a title filter with a headcount filter instead of interpreting titles after the search.
- `fullenrich:search_people` returns max 20 results with no pagination. Use `metadata.total` for volume.
- People found here can ask FullEnrich to remove their data. The reference file gives the opt-out address.
