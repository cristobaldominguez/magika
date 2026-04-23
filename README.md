# Magika Ruby

Ruby bindings for [Google Magika](https://github.com/google/magika), an AI-powered file content type detection library.

## Installation

```ruby
gem "magika"
```

The published gem is intended to ship precompiled native extensions for macOS and Linux. Development builds require Ruby 3.1-3.4, Bundler, and Rust/Cargo. Ruby 4 is not supported yet because the current native dependency chain does not compile against Ruby 4 headers.

## Usage

```ruby
require "magika"

result = Magika.identify_bytes("#!/bin/sh\necho hello")
result.label      # => "shell"
result.mime_type  # => "text/x-shellscript"
result.score      # => 0.99...
result.text?      # => true

file = Magika.identify_path("Gemfile")
file.to_h
```

For repeated calls, reuse a detector:

```ruby
detector = Magika::Detector.new(mode: :high_confidence)
detector.identify_path("README.md")
```

## Prediction modes

The Ruby API reserves `:high_confidence`, `:medium_confidence`, and `:best_guess`. The current Magika Rust crate exposes high-confidence inference only, so non-high-confidence modes raise `NotImplementedError` until upstream supports them in Rust.

## Development

Use Ruby 3.4 for local development. If you use mise, the repository declares both Ruby and Rust tools:

```sh
mise install
bundle install
```

Without mise, install Ruby 3.4 with your preferred Ruby manager and make sure `ruby -v` reports Ruby 3.x before running Bundler. Ruby 4 is intentionally excluded until Magnus/rb-sys support it cleanly.

Run Ruby contract tests without compiling the native extension:

```sh
bundle exec rake test
```

To reproduce the GitHub Actions native build locally, install Rust/Cargo and run:

```sh
bundle exec rake compile
MAGIKA_NATIVE_TEST=1 bundle exec rake test
bundle exec rake native gem
```

Do not commit generated gems, compiled extensions, or local build output.
