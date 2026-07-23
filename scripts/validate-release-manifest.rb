#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "lib/release_manifest"

abort "usage: validate-release-manifest.rb MANIFEST [RELEASE_ID]" unless (1..2).cover?(ARGV.length)

ReleaseManifest.load!(ARGV[0], ARGV[1])
puts "Release manifest is valid."
