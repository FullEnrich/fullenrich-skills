# FullEnrich MCP

13 MCP tools for B2B contact search, enrichment, and export inside AI agents.

---

## What is FullEnrich MCP?

FullEnrich MCP lets an AI agent use FullEnrich directly from a conversation. Instead of switching between a web app, CSVs, and manual filters, the user can ask an agent to search for people or companies, enrich contact data, and export results from the same chat.

The goal is simple: make FullEnrich usable where agent-native workflows now start.

## Why it matters

FullEnrich MCP is designed around three jobs:

1. **Search contacts or companies**
   Use natural language or structured filters to find relevant people and accounts.

2. **Enrich contacts**
   Find professional emails, phones, and other contact data for known people.

3. **Export results**
   Turn search or enrichment output into files the user can download and keep working from.

This makes the MCP useful both for quick lookups and for repeatable prospecting workflows.

## How to connect

### Public MCP endpoint

```
https://mcp.fullenrich.com/mcp
```

### Authentication model

FullEnrich MCP uses Streamable HTTP transport with OAuth-based authentication. On first connection, the user signs in with their FullEnrich account in the browser and authorizes access. There is no static end-user client secret to copy into the client.

### Minimal configuration example

```json
{
  "mcpServers": {
    "fullenrich": {
      "url": "https://mcp.fullenrich.com/mcp"
    }
  }
}
```

### What a reviewer can test first

1. Connect the MCP endpoint.
2. Authenticate with a FullEnrich account.
3. Ask the client to check credits.
4. Run a search query.
5. Enrich one contact after confirmation.

## Available capabilities

### Authenticate and credits

- Connect a FullEnrich account to the MCP session
- Check remaining credits before running paid actions
- Validate that the user is ready to use enrichment tools

### Search

- Search contacts with filters such as role, company, industry, location, and company size
- Search companies with structured company-level filters
- Use search to identify the right records before deciding whether to enrich

### Enrichment

- Enrich a single contact
- Launch async enrichment flows
- Enrich multiple contacts in batch flows
- Retrieve enrichment status and results

Typical enrichable fields include:

- Professional email
- Phone number

### Export and results

- Export contact search results
- Export company search results
- Retrieve download links and result metadata

## Available tools

FullEnrich MCP currently exposes 13 tools:

| Tool | Description |
|------|-------------|
| `get_credits` | Return the current credit balance before running paid actions |
| `list_industries` | List valid industry codes and labels (use before filtering by industry) |
| `list_seniorities` | List valid seniority levels for people filters |
| `list_functions_subfunctions` | List valid function and subfunction codes for people filters |
| `search_people` | Search for people with structured contact and company filters |
| `search_companies` | Search for companies with structured company filters |
| `search_contact_by_email` | Find a contact from an email address (reverse lookup) |
| `enrich_search_contact` | Enrich contacts matching search filters with verified emails and phones |
| `enrich_bulk` | Enrich multiple known contacts in one batch flow |
| `get_enrichment_results` | Poll status and fetch results for async or bulk enrichment |
| `export_contacts` | Export contact results to CSV |
| `export_companies` | Export company results to CSV |
| `export_enrichment_results` | Export enrichment job results to CSV or JSON |

## Credits, confirmations, and safety

The MCP is designed so users can explore before spending.

- Checking credits is a free action.
- Search previews are free for the contacts displayed by the MCP, within its preview limit.
- Exporting search results costs credits, so users should see balance before larger runs.
- Enrichment is the main paid action and should be confirmed by the user before execution.
- Human confirmation is recommended for any workflow that spends credits or triggers larger batch actions.

From user research and internal testing, the critical trust pattern is:

1. Preview first
2. Show balance
3. Confirm paid action
4. Execute
5. Report back in chat

That pattern is important both for user trust and for reviewer evaluation.

## MCP vs Skills

The MCP server exposes the tools.

Skills provide higher-level workflow guidance for clients that support them. In practice, this means:

- MCP tool descriptions stay short and discovery-friendly
- More advanced behavior, guardrails, and workflow instructions can live in skills
- The best agent experience comes from using both when the client supports skills

This separation exists because real MCP clients do not all consume server-side guidance in the same way. FullEnrich keeps the MCP layer focused on reliable tool access, then uses skills to improve routing, confirmation, and workflow quality when available.

## Known limitations

- Tool descriptions must remain short enough to work well with client-side tool discovery.
- Advanced agent behavior can vary by MCP client.
- Some workflow guidance is handled better through skills than through MCP tool descriptions alone.
- Reviewers should evaluate the core MCP on setup, auth, search, enrichment, and result handling first, then consider skills as an experience layer.

## Troubleshooting

### The connection succeeds but nothing happens

Start with a simple request such as:

> Check my FullEnrich credits

If that works, auth and routing are in place.

### Browser auth completes but the client looks stuck

Close the browser tab after the FullEnrich sign-in confirmation page if the client does not auto-close it.

### Search works but enrichment should not run yet

The expected behavior is to preview or clarify first, then confirm before paid enrichment.

### Results look thin

Use more standard company or industry language, and start broad before narrowing.

### Need support

- Help Center: [https://help.fullenrich.com](https://help.fullenrich.com)
- Support: [support@fullenrich.com](mailto:support@fullenrich.com)

## FAQ

**Does this require a FullEnrich account?**
Yes. Users authenticate with a FullEnrich account during connection.

**Is the MCP read-only?**
No. It supports both read flows and paid enrichment/export actions.

**Is the transport HTTP or SSE?**
Streamable HTTP.

**What should a reviewer test first?**
Credits check, one contact search, one company search, then a single-contact enrichment after confirmation.

**Why is this a centralized page instead of duplicating the API docs?**
Because the audience is different. API documentation explains endpoints for developers. This page explains setup, behavior, limitations, and support for MCP users and reviewers in one place that can be updated without splitting the source of truth.

**Does this page replace the API docs?**
No. It complements them. The API docs remain the reference for REST/API behavior. This page is the MCP-facing setup and reviewer guide.
