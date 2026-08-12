# frozen_string_literal: true

require "minitest/autorun"
require "json"
require "open3"
require "tmpdir"
require "yaml"

class McpRegistryWorkflowTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  WORKFLOW_PATH = File.join(ROOT, ".github", "workflows", "publish-mcp-registry.yml")
  CHECKOUT_SHA = "3d3c42e5aac5ba805825da76410c181273ba90b1"
  PUBLISHER_VERSION = "1.8.1"
  PUBLISHER_SHA256 = "a06c9096dcb9727c13555b6be26c7effa707b01f06a4c561ba7a3635443cf2cc"

  def test_workflow_exists_and_parses
    assert File.file?(WORKFLOW_PATH), "Expected #{WORKFLOW_PATH} to exist"
    assert_kind_of Hash, workflow
  end

  def test_triggers_version_tags_only
    triggers = workflow.fetch("on")

    assert_equal ["push"], triggers.keys
    assert_equal ["v*"], triggers.dig("push", "tags")
    refute triggers.key?("pull_request")
    refute triggers.key?("pull_request_target")
  end

  def test_job_uses_least_privilege_oidc_and_declares_the_publish_environment
    assert_equal({}, workflow.fetch("permissions"))

    publish = publish_job
    assert_equal "ubuntu-24.04", publish.fetch("runs-on")
    assert_equal "mcp-registry-publish", publish.fetch("environment")
    assert_equal({ "contents" => "read", "id-token" => "write" }, publish.fetch("permissions"))
    assert_includes publish.fetch("if"), "github.repository == 'FullEnrich/fullenrich-skills'"
  end

  def test_checkout_is_immutable_and_does_not_persist_credentials
    checkout = step_named("Checkout release source")

    assert_equal "actions/checkout@#{CHECKOUT_SHA}", checkout.fetch("uses")
    assert_equal false, checkout.dig("with", "persist-credentials")
    assert_equal "${{ github.ref }}", checkout.dig("with", "ref")
    refute_match(/@(main|master|v\d+)\z/, checkout.fetch("uses"))
  end

  def test_publisher_binary_is_version_and_checksum_pinned
    install = step_named("Install verified mcp-publisher")
    script = install.fetch("run")

    assert_includes script, "v#{PUBLISHER_VERSION}/mcp-publisher_linux_amd64.tar.gz"
    assert_includes script, PUBLISHER_SHA256
    refute_includes script, "/latest/"
    assert_includes script, "sha256sum --check"
  end

  def test_publisher_version_check_captures_stderr_and_matches_exact_semver
    script = step_named("Install verified mcp-publisher").fetch("run")

    assert_includes script, "--version 2>&1"
    assert_includes script, "BASH_REMATCH[2]"
    assert_match(/actual_publisher_version.*!=.*expected_publisher_version/, script)
    refute_match(/"mcp-publisher #{Regexp.escape(PUBLISHER_VERSION)}"\*/, script)
  end

  def test_publisher_version_guard_accepts_stderr_and_rejects_lookalike_version
    install_script = step_named("Install verified mcp-publisher").fetch("run")
    version_guard = install_script[install_script.index("expected_publisher_version=")..]

    Dir.mktmpdir do |runner_temp|
      publisher = File.join(runner_temp, "mcp-publisher")
      write_fake_publisher(publisher, PUBLISHER_VERSION)

      _stdout, stderr, status = Open3.capture3({ "RUNNER_TEMP" => runner_temp }, "bash", "-c", version_guard)
      assert status.success?, stderr

      write_fake_publisher(publisher, "1.8.10")
      stdout, stderr, status = Open3.capture3({ "RUNNER_TEMP" => runner_temp }, "bash", "-c", version_guard)
      refute status.success?
      assert_includes "#{stdout}\n#{stderr}", "Unexpected publisher version: 1.8.10"
    end
  end

  def test_manifest_is_validated_before_oidc_and_publish
    steps = publish_job.fetch("steps")
    validate_index = step_index("Validate server.json")
    login_index = step_index("Authenticate with GitHub OIDC")
    publish_index = step_index("Publish server.json")

    assert_operator validate_index, :<, login_index
    assert_operator login_index, :<, publish_index
    assert_match(/mcp-publisher"? validate server\.json/, steps[validate_index].fetch("run"))
    assert_match(/mcp-publisher"? login github-oidc --registry=https:\/\/registry\.modelcontextprotocol\.io/,
      steps[login_index].fetch("run"))
    assert_match(/mcp-publisher"? publish server\.json/, steps[publish_index].fetch("run"))
  end

  def test_workflow_guards_release_version_and_is_idempotent
    source_guard = step_named("Verify canonical source and release version").fetch("run")
    registry_check = step_named("Check existing Registry version").fetch("run")
    final_verify = step_named("Verify published Registry version").fetch("run")

    assert_includes source_guard, 'refs/tags/${release_tag}^{commit}'
    assert_includes source_guard, "git rev-parse HEAD"
    assert_includes source_guard, "GITHUB_SHA"
    assert_includes source_guard, '${GITHUB_SHA}^{commit}'
    assert_includes source_guard, "git status --porcelain"
    assert_includes source_guard, "server.json"
    assert_includes source_guard, "GITHUB_REF_NAME"
    assert_includes source_guard, 'io.github.${GITHUB_REPOSITORY_OWNER}/'
    assert_includes registry_check, "/v0.1/servers/"
    assert_includes registry_check, "include_deleted=true"
    assert_includes registry_check, 'status == "active"'
    assert_includes registry_check, "publish_needed=false"
    assert_includes final_verify, "jq --exit-status"
    assert_includes final_verify, "server.json"
    assert_includes final_verify, "include_deleted=true"
  end

  def test_release_guard_requires_the_exact_oidc_manifest_name_before_authentication
    source_guard_index = step_index("Verify canonical source and release version")
    assert_operator source_guard_index, :<, step_index("Authenticate with GitHub OIDC")
    assert_operator source_guard_index, :<, step_index("Publish server.json")

    with_manifest_fixture(server_name: "io.github.FullEnrich/fullenrich-extra") do |directory|
      stdout, stderr, status = run_manifest_guard(directory)

      refute status.success?
      assert_includes "#{stdout}\n#{stderr}",
        "server.json name must exactly match io.github.FullEnrich/fullenrich"
    end
  end

  def test_release_guard_requires_every_package_version_to_match_the_release_tag
    %w[server.json plugin.json .claude-plugin/plugin.json gemini-extension.json].each do |manifest_path|
      with_manifest_fixture(versions: { manifest_path => "9.9.9" }) do |directory|
        stdout, stderr, status = run_manifest_guard(directory)

        refute status.success?, "Expected #{manifest_path} version mismatch to fail"
        assert_includes "#{stdout}\n#{stderr}",
          "#{manifest_path} version 9.9.9 does not match 1.0.3"
      end
    end
  end

  def test_workflow_does_not_use_long_lived_registry_credentials
    contents = File.read(WORKFLOW_PATH)

    refute_match(/MCP_GITHUB_TOKEN|personal access token|\bPAT\b/i, contents)
    refute_match(/secrets\./, contents)
  end

  private

  def workflow
    @workflow ||= YAML.safe_load(File.read(WORKFLOW_PATH), permitted_classes: [], aliases: false)
  end

  def publish_job
    workflow.dig("jobs", "publish")
  end

  def step_named(name)
    publish_job.fetch("steps").find { |step| step["name"] == name } || flunk("Missing step: #{name}")
  end

  def step_index(name)
    index = publish_job.fetch("steps").index { |step| step["name"] == name }
    index || flunk("Missing step: #{name}")
  end

  def write_fake_publisher(path, version)
    File.write(path, <<~SH)
      #!/usr/bin/env bash
      printf '%s\n' '2026/08/11 20:13:24 mcp-publisher #{version} (commit: fixture, built: fixture)' >&2
    SH
    File.chmod(0o755, path)
  end

  def manifest_guard_script
    script = step_named("Verify canonical source and release version").fetch("run")
    start = script.index('expected_version="${release_tag#v}"')
    start ? script[start..] : flunk("Missing manifest release guard")
  end

  def run_manifest_guard(directory)
    env = {
      "GITHUB_ENV" => File.join(directory, "github-env"),
      "GITHUB_REPOSITORY_OWNER" => "FullEnrich"
    }
    script = "set -euo pipefail\nrelease_tag=v1.0.3\n#{manifest_guard_script}"

    Open3.capture3(env, "bash", "-c", script, chdir: directory)
  end

  def with_manifest_fixture(server_name: "io.github.FullEnrich/fullenrich", versions: {})
    Dir.mktmpdir do |directory|
      Dir.mkdir(File.join(directory, ".claude-plugin"))
      manifests = {
        "server.json" => server_name,
        "plugin.json" => "fullenrich",
        ".claude-plugin/plugin.json" => "fullenrich",
        "gemini-extension.json" => "fullenrich"
      }
      manifests.each do |path, name|
        payload = { "name" => name, "version" => versions.fetch(path, "1.0.3") }
        File.write(File.join(directory, path), JSON.generate(payload))
      end

      yield directory
    end
  end
end
