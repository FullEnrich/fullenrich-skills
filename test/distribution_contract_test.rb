# frozen_string_literal: true

require "json"
require "minitest/autorun"

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
  MCP_ENDPOINT = "https://mcp.fullenrich.com/mcp"

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

  def test_portable_json_manifests_parse
    JSON_MANIFESTS.each do |relative_path|
      assert_path_exists relative_path
      assert_kind_of Hash, JSON.parse(File.read(File.join(ROOT, relative_path)))
    end
  end

  def test_plugin_uses_the_agent_plugins_schema_and_name
    plugin = read_json("plugin.json")

    assert_equal "https://agent-plugins.org/schemas/1.0.0/plugin.schema.json", plugin.fetch("$schema")
    assert_equal "fullenrich", plugin.fetch("name")
  end

  def test_plugin_description_does_not_claim_direct_crm_writes
    description = read_json("plugin.json").fetch("description")
    direct_crm_claim = /\b(?:sync|push|write|send|save)(?:s|ed|ing)?\b.{0,80}\b(?:CRM|HubSpot|Salesforce|Attio|Pipedrive)\b/i

    refute_match direct_crm_claim, description
  end

  def test_mcp_uses_streamable_http_at_the_public_endpoint
    fullenrich = read_json("mcp.json").dig("mcpServers", "fullenrich")

    assert_equal "streamable-http", fullenrich.fetch("type")
    assert_equal MCP_ENDPOINT, fullenrich.fetch("url")
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

  private

  def assert_path_exists(relative_path)
    assert File.file?(File.join(ROOT, relative_path)), "Expected #{relative_path} to exist"
  end

  def read_json(relative_path)
    assert_path_exists relative_path
    JSON.parse(File.read(File.join(ROOT, relative_path)))
  end

  def readme
    File.read(File.join(ROOT, "README.md"))
  end
end
