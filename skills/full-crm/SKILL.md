---
name: full-crm
description: "Pushes already-enriched FullEnrich contacts into a CRM through a separately connected CRM MCP (HubSpot, Salesforce, Attio, Pipedrive), with field mapping and duplicate checks. Not for finding contacts."
---

# Full CRM Push

See [references/fullenrich-reference.md](references/fullenrich-reference.md) for MCP tool names, response schema, statuses, and business rules.

## Capability boundary

- FullEnrich MCP searches, enriches, and exports results as CSV or JSON.
- FullEnrich MCP does not write to CRMs.
- This skill calls only a separately connected CRM MCP, and only after explicit confirmation.

## Rules

- Always check for duplicates before creating CRM records — match on email, LinkedIn URL, or name + company.
- Never overwrite existing CRM data without explicit user permission; fill empty fields only.
- Always show a summary (new/update/skip counts) and wait for explicit "yes" before pushing.
- If the CRM MCP returns an auth error, stop immediately and ask the user to reconnect.
- Tag imports with source + date so the team knows where the data came from.

## Workflow

### 1. Check prerequisites

Two things are needed:
1. Enriched contacts (from prospecting, CSV, or prior enrichment).
2. A separately connected CRM MCP.

If no enriched contacts → suggest running full-prospecting first.
If no CRM MCP detected → explain that FullEnrich cannot write CRM records. Offer CSV/JSON export, or ask the user to connect their CRM's MCP.

### 2. Detect CRM

Identify the connected CRM MCP by checking available tools (look for hubspot/salesforce/attio/pipedrive in tool names). Explore the CRM's schema for available fields, required fields, and limitations.

Confirm with the user: "I see [CRM name] connected via its MCP. Is that right?"

### 3. Propose field mapping

Map FullEnrich fields to CRM fields: Full Name, Work Email, Phone, Job Title, Company Name, LinkedIn URL, Location, Industry, Headcount.

Ask: does the mapping look right? Any custom fields to populate? Wait for confirmation.

### 4. Duplicate detection

Check if contacts already exist in the CRM (match on email → LinkedIn URL → name + company).

For duplicates: show CRM data vs. enriched data side by side. Options: fill empty fields, let user choose when data differs, or skip.

### 5. Confirm and push

Show summary: CRM name, new contacts to create, existing to update, skipped. Wait for explicit "yes".

Use only the CRM MCP's tools to push. Log failures.

### 6. Report

Show: created count, updated count, failed (with reasons), skipped.

## Gotchas

- Field mapping varies per CRM: "Phone" vs. "Phone Number" vs. "Mobile Phone" + "Work Phone". Always check the CRM schema.
- Rate limits: some CRM APIs throttle. Batch and handle throttling gracefully.
- Auth errors from the CRM MCP → stop immediately, ask user to reconnect. Never retry or work around.
