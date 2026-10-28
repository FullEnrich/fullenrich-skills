---
name: full-csv
description: "Enriches a CSV or spreadsheet of contacts (LinkedIn URLs, or names plus company) with verified emails and phones via FullEnrich bulk enrichment. Use when the user uploads or pastes a contact file."
---

# Full CSV Enrichment

See [references/fullenrich-reference.md](references/fullenrich-reference.md) for MCP tool names, response schema, statuses, and business rules.

## Rules

- Always preview the CSV and confirm column mapping with the user before enriching — never assume.
- Deduplicate rows before spending credits.
- Never overwrite existing data: if the CSV already has emails, only fill empty cells.
- `contacts` parameter for `fullenrich:enrich_bulk` must be a JSON array, not a string — the #1 integration bug.

## Workflow

### 1. Parse and preview

Read the uploaded file. Detect columns and map them to FullEnrich fields: `linkedin_url`, `firstname`, `lastname`, `company`/`domain`, existing `email`.

Show the first 5 rows with detected columns. State: "[X] contacts found with [Y] columns. Detected fields: [list]." Ask the user to confirm mapping and choose enrichment fields (work emails, phones, or both).

Flag rows with insufficient data (no LinkedIn URL and no name+company): "[X] rows don't have enough data — I'll skip them."

### 2. Check credits

Call `fullenrich:get_credits`. Estimate: valid contacts × ~1 credit/email + ~10 credits/phone. Show balance, estimate, and wait for explicit "yes".

### 3. Normalize and enrich

Before calling `fullenrich:enrich_bulk`:
- Normalize LinkedIn URLs: strip trailing slashes, locale suffixes (/en, /fr), ensure `https://`.
- Clean names: trim whitespace, handle "firstname lastname" in a single column.
- Batch: max 100 contacts per `fullenrich:enrich_bulk` call.

Pass `contacts` as a JSON array (not a string) and a descriptive `name` label.

### 4. Poll and export

Poll `fullenrich:get_enrichment_results` every ~20 seconds. After FINISHED, call `fullenrich:export_enrichment_results` (format: csv) to get all results.

Present: Full Name, Company, LinkedIn, Email, Phone, Status. Show a summary: total contacts, emails found (count + %), phones found, not found count.

## Gotchas

- `fullenrich:enrich_bulk` accepts max 100 contacts per call. Batch larger files.
- `fullenrich:get_enrichment_results` returns max 10 results — always use export for the full dataset.
- CREDITS_INSUFFICIENT means "no data found" for that contact, not a balance problem.
