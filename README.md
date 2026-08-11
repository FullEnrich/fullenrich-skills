# FullEnrich MCP — B2B contact enrichment for AI agents

[![License: MIT](https://img.shields.io/github/license/FullEnrich/fullenrich-skills)](./LICENSE)
[![Version](https://img.shields.io/github/v/tag/FullEnrich/fullenrich-skills?label=version)](./CHANGELOG.md)

[FullEnrich](https://fullenrich.com) finds verified B2B contact data (emails and mobile phone numbers) through waterfall enrichment across 25+ data providers. This repository is the official FullEnrich integration for AI agents: a remote MCP server and a Claude Code plugin with 9 guided skills for prospecting, enrichment, outreach, and recruiting.

## Install

### Claude Code

Install the plugin to connect the MCP server and add the 9 skills:

```
/plugin marketplace add FullEnrich/fullenrich-skills
/plugin install fullenrich@fullenrich
```

### Cursor local install

Cursor loads root Agent Plugins from `~/.cursor/plugins/local`. Clone this repository, then symlink the checkout:

```sh
mkdir -p ~/.cursor/plugins/local
ln -s /absolute/path/to/fullenrich-skills ~/.cursor/plugins/local/fullenrich
```

Restart Cursor or run `Developer: Reload Window`, then verify that the 9 skills and the `fullenrich` MCP server appear. The package is not yet listed in the Cursor Marketplace or published to the official MCP Registry.

### Other Agent Plugins clients

The repository root follows Agent Plugins 1.0. Point a compatible client's local plugin loader at this directory. Installation remains client-specific.

### MCP only

Connect the public endpoint from any MCP-compatible client:

```
https://mcp.fullenrich.com/mcp
```

On first use, authenticate with your FullEnrich account (OAuth). You need a FullEnrich workspace with credits.

## Capability boundary

FullEnrich MCP searches B2B people and companies, enriches contacts, and exports results as CSV or JSON. It has no CRM write tools.

The `full-crm` skill can orchestrate a separately connected CRM MCP. It checks field mapping and duplicates, then requires explicit confirmation before the separate CRM connector creates or updates records.

## Why FullEnrich

- **Waterfall enrichment across 25+ providers.** Each contact is looked up provider by provider until a verified email or phone number is found. Coverage is higher than any single data source.
- **Credits refunded on invalid data.** You pay for a verified contact, not a query. If a contact comes back invalid, the credits are refunded.
- **Free preview, paid enrichment.** Search previews are free (within the MCP preview limit). Exporting search results and enriching contacts cost credits: about 1 credit per email found, 10 per phone found. The skills always state the estimated cost before spending.
- **Remote MCP server with OAuth 2.1.** No API key to copy around. The server at `https://mcp.fullenrich.com/mcp` uses the standard OAuth 2.1 flow and works from any MCP client (Claude, Cursor, Windsurf, custom agents).

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
| `full-crm` | Coordinate a separately connected CRM MCP, with explicit confirmation before any create or update |

Invoke them directly (e.g. `/full-prospecting`) or just describe what you want and Claude picks the right skill.

## Example prompts

- "Find me 20 VP Sales in Software Development companies in France, enrich their emails"
- "Enrich this CSV with emails and phones"
- "I have a call with [name] at [company] tomorrow, brief me"
- "Map the org chart of [company] and tell me who to talk to"

## What's in this repo

- `plugin.json` — portable Agent Plugins 1.0 manifest
- `mcp.json` — portable MCP connection for `https://mcp.fullenrich.com/mcp`
- `server.json` — unpublished MCP Registry metadata
- `.claude-plugin/plugin.json` — plugin manifest
- `.claude-plugin/marketplace.json` — self-hosted plugin marketplace
- `.mcp.json` — connects the FullEnrich MCP server (`https://mcp.fullenrich.com/mcp`)
- `skills/` — the 9 skills
- `fullenrich-mcp-documentation.md` — MCP server tool reference

## Links

- [FullEnrich](https://fullenrich.com)
- [Help center](https://help.fullenrich.com)
- [Pricing](https://fullenrich.com/pricing)
- [Documentation](https://docs.fullenrich.com)
- [Privacy policy](https://fullenrich.com/privacy-policy)
- [Trust Center](https://fullenrich.com/trust)
- [Support](mailto:support@fullenrich.com)
- [MCP server reference](./fullenrich-mcp-documentation.md)
