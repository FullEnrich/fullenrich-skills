# Changelog

## 1.0.3 — 2026-08-11

- Correct the MCP Registry name to the case-sensitive GitHub organization namespace `io.github.FullEnrich/fullenrich`
- Add a version-locked GitHub Actions OIDC workflow for validating and publishing tagged releases
- Honor explicit opt-out, suppression, and do-not-contact signals in outreach workflows
- Require a final deployment confirmation before any sequencer mutation
- Remove internal implementation plans from the public package

## 1.0.2 — 2026-08-10

- Add the portable Agent Plugins and MCP Registry package
- Add the Gemini CLI extension manifest
- Align skill metadata with Agent Skills and clarify the separate CRM connector boundary

## 1.0.1 — 2026-07-08

- Fix provider count in plugin manifest (25+ data providers, aligned with README)
- Add MIT license

## 1.0.0 — 2026-07-07

- Initial release as an installable Claude plugin
- Plugin manifest (`.claude-plugin/plugin.json`) and self-hosted marketplace (`.claude-plugin/marketplace.json`)
- Auto-connects the FullEnrich MCP server (`https://mcp.fullenrich.com/mcp`) via `.mcp.json`
- 9 skills in `SKILL.md` format: full-prospecting, full-csv, full-outreach, full-sequence, full-meeting, full-talent, full-lookalike, full-org, full-crm
