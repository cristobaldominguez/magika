# Magika Ruby

Ruby bindings for [Google Magika](https://github.com/google/magika), an AI-powered file content type detection library.

## Installation

```ruby
gem "magika"
```

The published gem is intended to ship precompiled native extensions for macOS and Linux. Development builds require Ruby 3.2.2-3.4, Bundler, and Rust/Cargo. Ruby 4 is not supported yet because the current native dependency chain does not compile against Ruby 4 headers.

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

Without mise, install Ruby 3.4 with your preferred Ruby manager and make sure `ruby -v` reports Ruby >= 3.2.2 and < 4.0 before running Bundler. Ruby 4 is intentionally excluded until Magnus/rb-sys support it cleanly.

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

The native build enables `ort`'s ONNX Runtime binary download/copy features so contributors do not need to install ONNX Runtime manually. `bundle exec rake compile` runs a preflight check for `cdn.pyke.io` and prints a Magika-specific error if ONNX Runtime cannot be downloaded. Advanced users can point to a custom ONNX Runtime build with `ORT_LIB_LOCATION`, or set `MAGIKA_SKIP_NETWORK_PREFLIGHT=1` when the runtime is already cached.

## Release workflow

Releases are intentional and tag-driven. Pushes to `development` or `main` never publish the gem by themselves. The full repository workflow is documented in [`workflow.md`](workflow.md). In short:

1. Implement changes in a feature/fix branch and open a PR to `development`.
2. Publish beta or RC versions from `development` with tags like `v0.2.0-beta.1` or `v0.2.0-rc.1`.
3. Promote validated code with a PR from `development` to `main`.
4. Publish stable versions from `main` with tags like `v0.2.0`.

The release workflow validates the tag, checks that `Magika::VERSION` matches it exactly, runs tests/builds, builds source and native gems, and publishes to RubyGems through Trusted Publishing. Stable tags also create a GitHub Release.

Do not commit generated gems, compiled extensions, or local build output.
