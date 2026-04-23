# frozen_string_literal: true

require_relative "magika/version"
require_relative "magika/detector"

begin
  require_relative "magika/magika"
rescue LoadError => error
  raise LoadError, "Could not load Magika native extension. Install a platform gem or build it with Rust/Cargo. #{error.message}"
end

module Magika
  class << self
    def identify_path(path, mode: Detector::DEFAULT_MODE)
      default_detector(mode).identify_path(path)
    end

    def identify_bytes(bytes, mode: Detector::DEFAULT_MODE)
      default_detector(mode).identify_bytes(bytes)
    end

    private

    def default_detector(mode)
      normalized = mode.to_s.tr("-", "_").to_sym
      @detectors ||= {}
      @detectors[normalized] ||= Detector.new(mode: normalized)
    end
  end
end
