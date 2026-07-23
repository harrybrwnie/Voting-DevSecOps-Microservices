# frozen_string_literal: true

require "json"
require "time"

module ReleaseManifest
  REPOSITORY = "harrybrwnie/Voting-DevSecOps-Microservices"
  REGISTRY = "911540681678.dkr.ecr.us-east-1.amazonaws.com"
  SERVICES = {
    "vote" => "voting-vote",
    "result" => "voting-result",
    "worker" => "voting-worker"
  }.freeze

  SHA_PATTERN = /\A[0-9a-f]{40}\z/
  DIGEST_PATTERN = /\Asha256:[0-9a-f]{64}\z/

  module_function

  def load!(path, expected_release_id = nil)
    manifest = JSON.parse(File.read(path))
    raise "release manifest must be a JSON object" unless manifest.is_a?(Hash)

    release_id = manifest.fetch("release_id")

    raise "schema_version must be 1" unless manifest["schema_version"] == 1
    raise "invalid release_id" unless SHA_PATTERN.match?(release_id)
    raise "commit_sha must equal release_id" unless manifest["commit_sha"] == release_id
    raise "repository must be #{REPOSITORY}" unless manifest["repository"] == REPOSITORY
    raise "workflow_run_id must be numeric" unless /\A[0-9]+\z/.match?(manifest["workflow_run_id"])
    unless %r{\Ahttps://github\.com/#{Regexp.escape(REPOSITORY)}/actions/runs/[0-9]+\z}.match?(manifest["workflow_url"])
      raise "workflow_url is invalid"
    end
    validate_created_at!(manifest["created_at"])

    if expected_release_id && release_id != expected_release_id
      raise "manifest release_id does not match #{expected_release_id}"
    end

    images = manifest.fetch("images")
    raise "images must be a JSON object" unless images.is_a?(Hash)
    raise "manifest must contain exactly vote, result and worker" unless images.keys.sort == SERVICES.keys.sort

    SERVICES.each do |service, repository|
      image = images.fetch(service)
      raise "#{service} image must be a JSON object" unless image.is_a?(Hash)

      digest = image.fetch("digest")
      uri = image.fetch("uri")
      expected_uri = "#{REGISTRY}/#{repository}"

      raise "#{service} repository must be #{repository}" unless image["repository"] == repository
      raise "#{service} digest is invalid" unless DIGEST_PATTERN.match?(digest)
      raise "#{service} URI must be #{expected_uri}" unless uri == expected_uri
      raise "#{service} reference does not match URI and digest" unless image["reference"] == "#{uri}@#{digest}"
    end

    manifest
  rescue JSON::ParserError, KeyError, TypeError => e
    raise "invalid release manifest: #{e.message}"
  end

  def validate_created_at!(created_at)
    raise "created_at must be a UTC ISO-8601 timestamp" unless created_at.is_a?(String) && created_at.end_with?("Z")

    parsed = Time.iso8601(created_at)
    raise "created_at must use UTC" unless parsed.utc?
  rescue ArgumentError
    raise "created_at must be a UTC ISO-8601 timestamp"
  end
end
