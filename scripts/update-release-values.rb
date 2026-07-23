#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require_relative "lib/release_manifest"

abort "usage: update-release-values.rb MANIFEST VALUES_FILE" unless ARGV.length == 2

manifest_path, values_path = ARGV
manifest = ReleaseManifest.load!(manifest_path)
values = YAML.safe_load(File.read(values_path), aliases: false)
abort "#{values_path} must contain a YAML object" unless values.is_a?(Hash)

values["release"] ||= {}
values["release"]["id"] = manifest.fetch("release_id")

ReleaseManifest::SERVICES.each_key do |service|
  values[service] ||= {}
  values[service]["image"] ||= {}
  values[service]["image"]["digest"] = manifest.fetch("images").fetch(service).fetch("digest")
end

File.write(values_path, YAML.dump(values).sub(/\A---\s*\n/, ""))
puts "Updated #{values_path} to release #{manifest.fetch('release_id')}."
