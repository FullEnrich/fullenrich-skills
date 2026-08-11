# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"

class DistributionContractTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  PORTABLE_FILES = %w[
    plugin.json
    mcp.json
    server.json
    assets/fullenrich-icon.svg
    SECURITY.md
  ].freeze
  JSON_MANIFESTS = %w[plugin.json mcp.json server.json].freeze
  PACKAGE_JSON_MANIFESTS = (JSON_MANIFESTS + %w[
    .claude-plugin/plugin.json
    .claude-plugin/marketplace.json
  ]).freeze
  EXPECTED_SKILLS = %w[
    full-crm
    full-csv
    full-lookalike
    full-meeting
    full-org
    full-outreach
    full-prospecting
    full-sequence
    full-talent
  ].freeze
  AGENT_SKILLS_FRONTMATTER_KEYS = %w[
    allowed-tools
    compatibility
    description
    license
    metadata
    name
  ].freeze
  MCP_ENDPOINT = "https://mcp.fullenrich.com/mcp"
  AGENT_PLUGIN_SCHEMA = "https://agent-plugins.org/schemas/1.0.0/plugin.schema.json"
  AGENT_PLUGIN_MCP_SCHEMA = "https://agent-plugins.org/schemas/1.0.0/mcp.schema.json"
  MCP_REGISTRY_SCHEMA = "https://static.modelcontextprotocol.io/schemas/2025-12-11/server.schema.json"
  CRM_TARGET = /(?:CRMs?|HubSpot|Salesforce|Attio|Pipedrive)/i
  DIRECT_CRM_ACTION = /(?:
    sync(?:s|ed|ing)? |
    push(?:es|ed|ing)? |
    writ(?:e|es|ten|ing) | wrote |
    send(?:s|ing)? | sent |
    sav(?:e|es|ed|ing) |
    creat(?:e|es|ed|ing) |
    updat(?:e|es|ed|ing) |
    upsert(?:s|ed|ing)? |
    insert(?:s|ed|ing)? |
    import(?:s|ed|ing)? |
    export(?:s|ed|ing)?
  )/ix
  DIRECT_CRM_CLAIMS = [
    /\b(?:directly|straight)\s+(?:to|into)\s+(?:an?\s+|the\s+|your\s+)?#{CRM_TARGET}\b/i,
    /\b#{DIRECT_CRM_ACTION}\b.{0,80}\b(?:directly\s+|straight\s+)?(?:to|into|in|with)\s+(?:an?\s+|the\s+|your\s+)?#{CRM_TARGET}\b/i,
    /\b#{CRM_TARGET}\b.{0,40}\b(?:sync|syncs|write|writes|writing|push|pushes|create|creates|creation|update|updates|upsert|insert)\b/i
  ].freeze

  def test_portable_distribution_files_exist
    PORTABLE_FILES.each do |relative_path|
      assert_path_exists relative_path
    end
  end

  def test_exactly_the_expected_nine_skills_exist
    actual_skills = Dir[File.join(ROOT, "skills", "*", "SKILL.md")]
      .map { |path| File.basename(File.dirname(path)) }
      .sort

    assert_equal EXPECTED_SKILLS, actual_skills
  end

  def test_all_skill_frontmatter_uses_only_agent_skills_standard_keys
    unsupported_keys = EXPECTED_SKILLS.each_with_object({}) do |skill_name, result|
      extra_keys = skill_frontmatter(skill_name).keys.map(&:to_s) - AGENT_SKILLS_FRONTMATTER_KEYS
      result[skill_name] = extra_keys unless extra_keys.empty?
    end

    assert_empty unsupported_keys,
      "Unsupported Agent Skills frontmatter keys: #{unsupported_keys.inspect}"
  end

  def test_package_json_manifests_parse
    PACKAGE_JSON_MANIFESTS.each do |relative_path|
      assert_path_exists relative_path
      assert_kind_of Hash, JSON.parse(File.read(File.join(ROOT, relative_path)))
    end
  end

  def test_plugin_uses_the_agent_plugins_schema_and_name
    plugin = read_json("plugin.json")

    assert_equal AGENT_PLUGIN_SCHEMA, plugin.fetch("$schema")
    assert_equal "fullenrich", plugin.fetch("name")
  end

  def test_package_manifests_do_not_claim_direct_crm_writes
    PACKAGE_JSON_MANIFESTS.each do |relative_path|
      claim = string_values(read_json(relative_path)).find { |value| direct_crm_claim?(value) }

      assert_nil claim, "#{relative_path} must not claim that FullEnrich writes directly to a CRM: #{claim.inspect}"
    end
  end

  def test_direct_crm_guard_recognizes_direct_write_claims
    claims = [
      "Route enriched contacts directly to Salesforce/HubSpot/CRM.",
      "Send enriched records into HubSpot.",
      "Push contacts to your CRM.",
      "Write contacts in Attio.",
      "Pipedrive sync is built in.",
      "Export contacts to Salesforce."
    ]

    claims.each do |claim|
      assert direct_crm_claim?(claim), "Expected direct CRM claim to be rejected: #{claim.inspect}"
    end
  end

  def test_direct_crm_guard_allows_truthful_file_export_claims
    allowed_claims = [
      "Export enriched contacts to CSV or JSON.",
      "Export Salesforce-ready records as CSV.",
      "Create a CSV for manual CRM import.",
      "Use a separately connected CRM MCP to import exported CSV files."
    ]

    allowed_claims.each do |claim|
      refute direct_crm_claim?(claim), "Expected portable file export claim to be allowed: #{claim.inspect}"
    end
  end

  def test_mcp_uses_the_agent_plugins_schema
    assert_equal AGENT_PLUGIN_MCP_SCHEMA, read_json("mcp.json").fetch("$schema")
  end

  def test_mcp_uses_streamable_http_at_the_public_endpoint
    fullenrich = read_json("mcp.json").dig("mcpServers", "fullenrich")

    assert_equal "streamable-http", fullenrich.fetch("type")
    assert_equal MCP_ENDPOINT, fullenrich.fetch("url")
  end

  def test_registry_manifest_uses_the_2025_12_11_schema
    assert_equal MCP_REGISTRY_SCHEMA, read_json("server.json").fetch("$schema")
  end

  def test_registry_manifest_does_not_claim_the_skills_repo_as_server_source
    server = read_json("server.json")

    refute server.key?("repository"),
      "server.json must not identify the public skills repository as the private MCP server source"
  end

  def test_registry_manifest_declares_the_expected_remote
    server = read_json("server.json")

    assert_equal "io.github.fullenrich/fullenrich", server.fetch("name")
    assert_equal [{ "type" => "streamable-http", "url" => MCP_ENDPOINT }], server.fetch("remotes")
  end

  def test_readme_links_to_the_privacy_policy
    assert_includes readme, "https://fullenrich.com/privacy-policy"
  end

  def test_readme_links_to_the_trust_center
    assert_includes readme, "https://fullenrich.com/trust"
  end

  def test_readme_lists_the_support_email
    assert_includes readme, "support@fullenrich.com"
  end

  def test_readme_defines_the_fullenrich_and_separate_crm_boundaries
    assert_includes readme,
      "FullEnrich MCP searches B2B people and companies, enriches contacts, and exports results as CSV or JSON."
    assert_includes readme, "separately connected CRM MCP"
    assert_includes readme, "explicit confirmation"
  end

  def test_readme_documents_portable_local_install_and_unpublished_status
    assert_includes readme, "Agent Plugins"
    assert_includes readme, "~/.cursor/plugins/local"
    assert_match(/not yet listed/i, readme)
  end

  def test_full_crm_uses_a_separate_connector_with_confirmation
    assert_includes full_crm_skill, "separately connected CRM MCP"
    assert_includes full_crm_skill, "FullEnrich MCP does not write to CRMs"
    assert_includes full_crm_skill, "explicit confirmation"
  end

  def test_mcp_documentation_declares_thirteen_tools
    assert_match(/\A# FullEnrich MCP\n\n13 MCP tools\b/, mcp_documentation)
    refute_match(/\A# FullEnrich MCP\n\n10 MCP tools\b/, mcp_documentation)
  end

  private

  def assert_path_exists(relative_path)
    assert File.file?(File.join(ROOT, relative_path)), "Expected #{relative_path} to exist"
  end

  def read_json(relative_path)
    assert_path_exists relative_path
    JSON.parse(File.read(File.join(ROOT, relative_path)))
  end

  def skill_frontmatter(skill_name)
    contents = File.read(File.join(ROOT, "skills", skill_name, "SKILL.md"))
    match = contents.match(/\A---\s*\n(.*?)\n---\s*(?:\n|\z)/m)

    refute_nil match, "Expected skills/#{skill_name}/SKILL.md to start with YAML frontmatter"
    YAML.safe_load(match[1], permitted_classes: [], aliases: false) || {}
  end

  def direct_crm_claim?(value)
    DIRECT_CRM_CLAIMS.any? { |pattern| pattern.match?(value) }
  end

  def string_values(value)
    case value
    when Hash
      value.values.flat_map { |child| string_values(child) }
    when Array
      value.flat_map { |child| string_values(child) }
    when String
      [value]
    else
      []
    end
  end

  def readme
    File.read(File.join(ROOT, "README.md"))
  end

  def full_crm_skill
    File.read(File.join(ROOT, "skills", "full-crm", "SKILL.md"))
  end

  def mcp_documentation
    File.read(File.join(ROOT, "fullenrich-mcp-documentation.md"))
  end
end
