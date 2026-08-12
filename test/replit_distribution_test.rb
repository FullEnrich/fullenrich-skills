# frozen_string_literal: true

require "base64"
require "json"
require "minitest/autorun"
require "uri"

class ReplitDistributionTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  README_PATH = File.join(ROOT, "README.md")
  RECIPE_PATH = File.join(ROOT, "examples", "replit-sales-agent.md")
  MCP_ENDPOINT = "https://mcp.fullenrich.com/mcp"
  EXPECTED_PAYLOAD = {
    "displayName" => "FullEnrich",
    "baseUrl" => MCP_ENDPOINT
  }.freeze
  EXPECTED_CALLS = %w[get_credits list_industries search_people get_credits].freeze

  def test_readme_has_an_official_replit_badge_with_the_exact_secretless_payload
    match = readme.match(
      %r{\[!\[Add to Replit\]\(https://replit\.com/badge\?caption=Add%20to%20Replit\)\]\((https://replit\.com/integrations\?mcp=[^)]+)\)}
    )

    refute_nil match, "README must expose the official Add to Replit badge"

    uri = URI.parse(match[1])
    payload = URI.decode_www_form(uri.query).to_h.fetch("mcp")
    configuration = JSON.parse(Base64.strict_decode64(payload))

    assert_equal EXPECTED_PAYLOAD, configuration
    refute configuration.key?("headers"), "The public install link must not embed headers or secrets"
  end

  def test_readme_distinguishes_custom_install_from_curated_directory_listing
    assert_match(/custom MCP install is available now/i, readme)
    assert_match(/not listed in the curated Replit MCP directory/i, readme)
  end

  def test_readme_links_to_the_replit_sales_agent_recipe
    assert_includes readme,
      "[zero-FullEnrich-credit, read-only sales-agent recipe](./examples/replit-sales-agent.md)"
    assert_match(/Replit plan or Agent usage may still consume Replit credits/i, readme)
    assert_match(/does not write contact data to project files/i, readme)
  end

  def test_replit_sales_agent_recipe_exists
    assert File.file?(RECIPE_PATH), "Expected #{RECIPE_PATH} to exist"
  end

  def test_recipe_uses_only_the_ordered_free_read_only_smoke_calls
    calls = copy_paste_prompt.scan(/`([a-z_]+)`/).flatten

    assert_equal EXPECTED_CALLS, calls
    assert_match(/zero FullEnrich credits/i, recipe)
    assert_match(/free preview/i, copy_paste_prompt)
    assert_match(/do not run enrichment, export, contact lookup, CRM, or file-write tools/i,
      copy_paste_prompt)
  end

  def test_recipe_requires_explicit_confirmation_before_any_paid_action
    assert_match(/state the exact tool, scope, and estimated credit cost/i, recipe)
    assert_match(/wait for my explicit confirmation before calling it/i, recipe)
  end

  def test_recipe_forbids_committing_personal_data
    assert_match(/do not copy returned people or contact data into project files/i, recipe)
    assert_match(/do not commit personal data/i, recipe)
    refute_match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}/i, recipe)
  end

  private

  def readme
    @readme ||= File.read(README_PATH)
  end

  def recipe
    @recipe ||= File.file?(RECIPE_PATH) ? File.read(RECIPE_PATH) : ""
  end

  def copy_paste_prompt
    match = recipe.match(/## Copy\/paste prompt\s+```text\s+(.*?)\s+```/m)
    match ? match[1] : flunk("Recipe must contain a text fenced block under Copy/paste prompt")
  end
end
