# Cursor and MCP Registry Distribution Design

**Date:** 2026-08-10
**Status:** Approved for local implementation; no push or publication approved

## Outcome

Make the existing FullEnrich skills repository installable as a portable Agent Plugin in Cursor and publishable as a remote server in the official MCP Registry, without changing the FullEnrich MCP server or silently modifying the already-submitted Anthropic integration.

## Constraints

- Work only on `codex/cursor-core-distribution` until Nylan approves a push.
- Keep the existing `.claude-plugin/` manifests and `.mcp.json` valid.
- Do not publish to Cursor, the MCP Registry, or any marketplace in this implementation pass.
- Do not spend FullEnrich credits during validation.
- Do not claim that the FullEnrich MCP itself writes to a CRM. The optional `full-crm` skill can orchestrate a separate CRM MCP when the user has connected one.
- Use the existing public OAuth endpoint: `https://mcp.fullenrich.com/mcp`.

## Smallest portable package

The repository will use Cursor's supported Agent Plugins format:

```text
plugin.json                  portable plugin identity
mcp.json                     portable Streamable HTTP MCP definition
server.json                  official MCP Registry metadata
assets/fullenrich-icon.svg   committed marketplace logo
skills/*/SKILL.md            existing guided workflows
```

A second `.cursor-plugin/plugin.json` is intentionally omitted. Cursor accepts a root `plugin.json`, and one canonical manifest avoids duplicated version and copy fields.

## Compatibility boundary

The first implementation commit is additive. It does not edit `.claude-plugin/`, `.mcp.json`, or existing skills. This makes it easy to inspect or cherry-pick independently.

Truthful copy corrections will live in a separate commit. They may touch shared README or Claude metadata, so that commit must not be pushed while an Anthropic review is live unless the review behavior is confirmed.

## Validation

Local validation must prove:

1. Existing Claude marketplace validation still passes.
2. All JSON parses.
3. `plugin.json` and `mcp.json` validate against Agent Plugins 1.0 schemas.
4. `server.json` validates against the official MCP Registry schema.
5. Every skill has valid frontmatter and a unique name.
6. The endpoint responds as an MCP OAuth-protected Streamable HTTP endpoint.
7. A connected client can list tools and run a free command such as `get_credits`; paid enrichment is out of scope.

## Shipping gate

After local verification, Nylan gets one exact decision:

- push only the additive portable package;
- push both package and truthful copy corrections;
- or move the portable files to a separate repository if Anthropic's live review follows the default branch dynamically.

Publishing, release creation, Cursor re-indexing, and Registry login remain separate human-approved actions.
