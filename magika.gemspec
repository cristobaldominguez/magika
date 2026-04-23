# frozen_string_literal: true

require_relative "lib/magika/version"

Gem::Specification.new do |spec|
  spec.name = "magika"
  spec.version = Magika::VERSION
  spec.authors = ["Cristobal Dominguez"]
  spec.email = ["cristobald@gmail.com"]

  spec.summary = "Ruby bindings for Google's Magika file type detection library"
  spec.description = "A Ruby-first native binding for Magika, Google's AI-powered file content type detection library."
  spec.homepage = "https://github.com/cristobaldominguez/magika"
  spec.license = "Apache-2.0"
  spec.required_ruby_version = ">= 3.2.2", "< 4.0"

  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage,
    "changelog_uri" => "#{spec.homepage}/blob/main/CHANGELOG.md",
    "rubygems_mfa_required" => "true"
  }

  spec.files = Dir.glob(%w[
    lib/**/*.rb
    ext/**/*.{rs,toml,rb}
    Cargo.toml
    Cargo.lock
    README.md
    LICENSE.txt
    CHANGELOG.md
  ]).select { |path| File.file?(path) }

  spec.extensions = ["ext/magika/extconf.rb"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "minitest", "~> 5.25"
  spec.add_development_dependency "rake", "~> 13.2"
  spec.add_development_dependency "rake-compiler", "~> 1.2"
  spec.add_development_dependency "rake-compiler-dock", "~> 1.10"
  spec.add_development_dependency "rb_sys", "~> 0.9"
end
