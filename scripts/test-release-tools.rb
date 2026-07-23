#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "rbconfig"
require "tmpdir"
require "yaml"
require_relative "lib/release_manifest"

release_id = "a" * 40
digest = "sha256:#{'b' * 64}"
registry = ReleaseManifest::REGISTRY
updater = File.expand_path("update-release-values.rb", __dir__)

manifest = {
  "schema_version" => 1,
  "release_id" => release_id,
  "commit_sha" => release_id,
  "created_at" => "2026-07-23T00:00:00Z",
  "repository" => ReleaseManifest::REPOSITORY,
  "workflow_run_id" => "1",
  "workflow_url" => "https://github.com/#{ReleaseManifest::REPOSITORY}/actions/runs/1",
  "images" => {}
}

ReleaseManifest::SERVICES.each do |service, repository|
  uri = "#{registry}/#{repository}"
  manifest["images"][service] = {
    "repository" => repository,
    "uri" => uri,
    "digest" => digest,
    "reference" => "#{uri}@#{digest}"
  }
end

Dir.mktmpdir do |directory|
  manifest_path = File.join(directory, "manifest.json")
  values_path = File.join(directory, "values.yaml")
  File.write(manifest_path, JSON.pretty_generate(manifest))
  File.write(values_path, { "release" => { "id" => "0" * 40 } }.merge(
    ReleaseManifest::SERVICES.keys.to_h { |service| [service, { "image" => { "digest" => "sha256:#{'0' * 64}" } }] }
  ).to_yaml)

  ReleaseManifest.load!(manifest_path, release_id)
  system(RbConfig.ruby, updater, manifest_path, values_path) || abort("update failed")

  updated = YAML.safe_load(File.read(values_path), aliases: false)
  abort "release ID was not updated" unless updated.dig("release", "id") == release_id
  ReleaseManifest::SERVICES.each_key do |service|
    abort "#{service} digest was not updated" unless updated.dig(service, "image", "digest") == digest
  end

  tampered = Marshal.load(Marshal.dump(manifest))
  tampered["images"]["worker"]["digest"] = "sha256:bad"
  File.write(manifest_path, JSON.pretty_generate(tampered))
  begin
    ReleaseManifest.load!(manifest_path)
    abort "invalid digest was accepted"
  rescue RuntimeError => e
    raise unless e.message.include?("worker digest is invalid")
  end

  missing_service = Marshal.load(Marshal.dump(manifest))
  missing_service["images"].delete("result")
  File.write(manifest_path, JSON.pretty_generate(missing_service))
  begin
    ReleaseManifest.load!(manifest_path)
    abort "manifest with a missing service was accepted"
  rescue RuntimeError => e
    raise unless e.message.include?("exactly vote, result and worker")
  end

  begin
    ReleaseManifest.load!(File.join(directory, "missing.json"))
    abort "nonexistent manifest was accepted"
  rescue Errno::ENOENT
    nil
  end

  File.write(manifest_path, JSON.pretty_generate(manifest))
  begin
    ReleaseManifest.load!(manifest_path, "c" * 40)
    abort "mixed release was accepted"
  rescue RuntimeError => e
    raise unless e.message.include?("does not match")
  end

  missing_values = File.join(directory, "missing-values.yaml")
  if system(RbConfig.ruby, updater, manifest_path, missing_values, out: File::NULL, err: File::NULL)
    abort "nonexistent values file was accepted"
  end
end

puts "Release tooling tests passed."
