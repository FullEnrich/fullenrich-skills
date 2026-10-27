---
name: full-talent
description: "Sources job candidates with FullEnrich: clarifies the role, searches and ranks profiles, enriches contact details after cost confirmation. Use when the user is hiring or recruiting."
---

# Full Talent Sourcing

See [references/fullenrich-reference.md](references/fullenrich-reference.md) for MCP tool names, response schema, statuses, and business rules.

## Rules

- Always ask for the user's company domain and exclude it from results — never source their own employees.
- Always enrich both email + phone for recruitment candidates.
- Probe vague requirements: "Senior Engineer" means different things at a 10-person startup vs. a 5,000-person enterprise. Ask about scope, stack, and team.
- Rank candidates into tiers and explain why each Tier 1 candidate is a strong fit.

## Workflow

### 1. Intake

Start with open questions: what role, why hiring, what the team looks like, what the ideal candidate profile is, and the user's company domain (for exclusion).

Probe based on answers:
- Vague title → ask about scope (IC vs. team lead vs. architect).
- Generic skills → ask about the specific context (e.g. "Python for data science" vs. "Python for backend APIs").
- No location → ask about on-site/hybrid/remote and timezone constraints.

Keep probing until the role, must-have skills, location, target company profile, and exclusions are clear.

### 2. Confirm search strategy

Summarize: role + scope, must-have skills, nice-to-haves, location, target company profile, exclusions, volume. Wait for confirmation.

### 3. Search and enrich

Call `fullenrich:get_credits`. Estimate: [count] × ~11 credits (email + phone).

If industry filter → call `fullenrich:list_industries`. Call `fullenrich:search_people` as preview. If volume < requested → suggest adjustments.

Show cost estimate, wait for explicit "yes", then call `fullenrich:enrich_search_contact` once with `["contact.work_emails", "contact.phones"]`. Poll → export.

### 4. Rank

Analyze each candidate against intake criteria. Rank into tiers:

- **Tier 1** — Call first: explain why in 1–2 sentences per candidate (career trajectory, skills match, company fit, likely motivation to move).
- **Tier 2** — Worth considering: good profiles with gaps to validate.
- **Tier 3** — Backup: partial matches.

### 5. Present

Show summary (total sourced, tier counts, email/phone found %). For Tier 1: name, title, company, years in role, email, phone, career path, education, key skills, why they fit, recommended outreach channel.

## Gotchas

- A "CTO" at a 5-person startup is a tech lead who codes. A "Senior" at Google is 8+ years. Always cross-reference titles with company size.
- `fullenrich:search_people` returns max 20 results with no pagination. Use `metadata.total` for volume.
- The Tier 1 profiles with "why this person fits" are the most valuable output — they separate sourcing from keyword search.
