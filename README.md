# FullEnrich for Claude Code

B2B contact enrichment for AI agents. This plugin connects Claude Code to [FullEnrich](https://fullenrich.com) — waterfall enrichment across 15+ data providers — and ships 9 guided skills for prospecting, enrichment, outreach, and recruiting.

## Installation

```
/plugin marketplace add FullEnrich/fullenrich-skills
/plugin install fullenrich@fullenrich
```

On first use, Claude Code will prompt you to authenticate with your FullEnrich account (OAuth). You need a FullEnrich workspace with credits. Search previews are free (within the MCP preview limit); exporting search results and enriching contacts cost credits — ~1 credit per email found, ~10 per phone found. The skills always tell you the estimated cost before spending.

## Skills

| Skill | What it does |
|---|---|
| `full-prospecting` | Find and enrich B2B contacts matching an ICP (title, industry, location, company size) |
| `full-csv` | Bulk-enrich a CSV of contacts with verified emails and phone numbers |
| `full-outreach` | Draft hyper-personalized cold emails, LinkedIn DMs, and call scripts from enriched data |
| `full-sequence` | Design and deploy multi-touch outreach sequences |
| `full-meeting` | Brief before a meeting: profile, company context, talking points |
| `full-talent` | Source, enrich, and rank candidates for a role |
| `full-lookalike` | Find people similar to a given LinkedIn profile (ICP expansion) |
| `full-org` | Map a company's team structure and identify who to contact |
| `full-crm` | Push enriched contacts to HubSpot, Salesforce, Attio, Pipedrive, or any CRM with an MCP |

Invoke them directly (e.g. `/full-prospecting`) or just describe what you want — Claude picks the right skill.

## Example prompts

- "Find me 20 VP Sales in Software Development companies in France, enrich their emails"
- "Enrich this CSV with emails and phones"
- "I have a call with [name] at [company] tomorrow, brief me"
- "Map the org chart of [company] and tell me who to talk to"

## What's in this repo

- `.claude-plugin/plugin.json` — plugin manifest
- `.mcp.json` — connects the FullEnrich MCP server (`https://mcp.fullenrich.com/mcp`)
- `skills/` — the 9 skills
- `fullenrich-mcp-documentation.md` — MCP server tool reference

## Links

- [FullEnrich](https://fullenrich.com)
- [Documentation](https://docs.fullenrich.com)
- [MCP server reference](./fullenrich-mcp-documentation.md)
