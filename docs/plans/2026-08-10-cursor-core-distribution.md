# Cursor/Core Distribution Implementation Plan

> **For Codex:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Package and verify FullEnrich as a portable Cursor Agent Plugin and an official MCP Registry remote server, while isolating any effect on the submitted Anthropic integration.

**Architecture:** Add one portable root manifest and MCP configuration beside the existing Claude-specific package. Add Registry metadata for the same remote endpoint. Keep compatibility and copy changes in separate commits, then gate all remote state changes behind Nylan's explicit approval.

**Tech Stack:** JSON manifests, Agent Plugins 1.0 schemas, MCP Registry 2025-12-11 schema, Ruby standard library validation, Claude Code plugin validator, Cursor desktop/CLI where available.

---

### Task 1: Add a failing distribution contract test

**Files:**
- Create: `test/distribution_contract_test.rb`

**Step 1: Write the failing test**

The test must assert that `plugin.json`, `mcp.json`, `server.json`, `assets/fullenrich-icon.svg`, `SECURITY.md`, and the expected nine skill files exist. It must parse every JSON file and assert:

```ruby
assert_equal "https://agent-plugins.org/schemas/1.0.0/plugin.schema.json", plugin.fetch("$schema")
assert_equal "fullenrich", plugin.fetch("name")
assert_equal "streamable-http", mcp.dig("mcpServers", "fullenrich", "type")
assert_equal "https://mcp.fullenrich.com/mcp", mcp.dig("mcpServers", "fullenrich", "url")
assert_equal "io.github.fullenrich/fullenrich", server.fetch("name")
assert_equal [{"type" => "streamable-http", "url" => "https://mcp.fullenrich.com/mcp"}], server.fetch("remotes")
```

It must also reject direct-CRM claims in portable manifest descriptions and require support/privacy URLs in `README.md`.

**Step 2: Run the test to verify it fails**

Run: `ruby test/distribution_contract_test.rb`
Expected: FAIL because the portable distribution files do not exist.

**Step 3: Commit the red test**

```bash
git add test/distribution_contract_test.rb
git commit -m "test: define portable distribution contract"
```

### Task 2: Add the portable plugin and Registry package

**Files:**
- Create: `plugin.json`
- Create: `mcp.json`
- Create: `server.json`
- Create: `assets/fullenrich-icon.svg`
- Create: `SECURITY.md`

**Step 1: Add the minimal portable manifest**

Use Agent Plugins 1.0, version `1.0.1`, FullEnrich author/repository metadata, `MIT`, and factual search/enrichment/export wording. Do not include Cursor-only fields in the portable schema.

**Step 2: Add the portable MCP configuration**

Declare `fullenrich` with type `streamable-http` and URL `https://mcp.fullenrich.com/mcp`. Do not embed credentials; OAuth remains client-managed.

**Step 3: Add Registry metadata**

Use the GitHub organization namespace `io.github.fullenrich/fullenrich`, the current Registry schema, repository metadata, version `1.0.1`, and one remote Streamable HTTP endpoint.

**Step 4: Reuse the existing FullEnrich SVG icon**

Copy the canonical 32x32 SVG path data from the existing marketplace launch asset. Do not redraw or alter the mark.

**Step 5: Add a security policy**

Route private vulnerability reports to `support@fullenrich.com`, link the Trust Center, and explicitly prohibit public disclosure of unpatched reports or testing that accesses other customers' data.

**Step 6: Run the contract test**

Run: `ruby test/distribution_contract_test.rb`
Expected: PASS for file and manifest contracts.

**Step 7: Validate schemas**

Download the three official schemas to a temporary directory and validate the manifests with an available JSON Schema validator. Do not commit downloaded schemas.

**Step 8: Commit the additive package**

```bash
git add plugin.json mcp.json server.json assets/fullenrich-icon.svg SECURITY.md
git commit -m "feat: add portable Cursor and MCP Registry package"
```

### Task 3: Correct shared distribution claims

**Files:**
- Modify: `README.md`
- Modify: `.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`
- Modify: `fullenrich-mcp-documentation.md`
- Modify: `skills/full-crm/SKILL.md`

**Step 1: Make the capability boundary explicit**

Keep `full-crm`, but state that it uses a separately connected CRM MCP. Replace wording that implies the FullEnrich MCP directly writes to HubSpot, Salesforce, Attio, or Pipedrive.

**Step 2: Fix the stale tool count**

Change the MCP documentation heading from 10 tools to 13 tools, matching its live tool table.

**Step 3: Document portable install paths**

Add Cursor and generic Agent Plugin installation/testing information, the public endpoint, privacy, Trust Center, support, and Registry status language that remains truthful before publication.

**Step 4: Run the contract and Claude validations**

Run:

```bash
ruby test/distribution_contract_test.rb
claude plugin validate .
```

Expected: both PASS.

**Step 5: Commit copy corrections separately**

```bash
git add README.md .claude-plugin/plugin.json .claude-plugin/marketplace.json fullenrich-mcp-documentation.md skills/full-crm/SKILL.md
git commit -m "docs: clarify CRM and distribution capabilities"
```

### Task 4: Prove the endpoint and local client path

**Files:**
- Create: `docs/verification/cursor-core-2026-08-10.md`

**Step 1: Verify the unauthenticated endpoint behavior**

Send a non-mutating MCP initialize request. Record HTTP status, `WWW-Authenticate`, content type, and whether OAuth discovery metadata is reachable. Do not record tokens or cookies.

**Step 2: Verify the free connected-client path**

Use an already-connected MCP client to list the FullEnrich tools and, if available, run `get_credits`. Do not run enrichment or exports.

**Step 3: Test local Cursor installation**

Use Cursor's supported local plugin flow against this worktree. Confirm that nine skills are discovered and the `fullenrich` MCP entry is present. Complete OAuth only if the existing signed-in FullEnrich session allows it without exposing secrets; otherwise record the exact human gate.

**Step 4: Record immutable evidence**

Write commands, timestamps, results, failures, and the current git SHA to the verification file. Never claim a check passed if it was not observed.

**Step 5: Commit verification evidence**

```bash
git add docs/verification/cursor-core-2026-08-10.md
git commit -m "test: record Cursor core verification"
```

### Task 5: Prepare, but do not execute, distribution actions

**Files:**
- Create: `docs/release/cursor-registry-release-checklist.md`

**Step 1: Define independent external gates**

Create exact checkboxes for push, PR/merge, tag/release, Cursor marketplace re-index request, MCP Registry login/publish, and post-publication verification. Each must name its external target and require a fresh Nylan approval.

**Step 2: Include the Anthropic compatibility decision**

Document whether to ship from the shared repo or a separate repo based on the read-only Anthropic audit. Keep the additive package and shared-copy commit separable.

**Step 3: Run the full local gate**

Run:

```bash
ruby test/distribution_contract_test.rb
claude plugin validate .
git status --short
git log --oneline --decorate -5
```

Expected: tests pass and only planned files/commits exist.

**Step 4: Commit the release checklist**

```bash
git add docs/release/cursor-registry-release-checklist.md
git commit -m "docs: add gated distribution checklist"
```

### Task 6: Independent review

**Files:** Review all changes from `main...codex/cursor-core-distribution`.

**Step 1: Spec compliance review**

Verify the branch satisfies this plan and did not modify MCP server code or publish anything.

**Step 2: Code and security review**

Check schemas, copy truthfulness, OAuth handling, data/credit guardrails, and compatibility with the existing Claude package.

**Step 3: Re-run final gates after fixes**

No issue may remain open before presenting the branch and exact next approval to Nylan.
