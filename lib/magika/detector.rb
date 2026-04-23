# frozen_string_literal: true

require_relative "result"

module Magika
  class Detector
    SUPPORTED_MODES = %i[high_confidence medium_confidence best_guess].freeze
    NATIVE_SUPPORTED_MODES = %i[high_confidence].freeze
    DEFAULT_MODE = :high_confidence

    attr_reader :mode

    def initialize(mode: DEFAULT_MODE)
      @mode = normalize_mode(mode)
      return if NATIVE_SUPPORTED_MODES.include?(@mode)

      raise NotImplementedError,
            "Magika Rust crate currently exposes high-confidence inference only; " \
            "#{@mode.inspect} is reserved in the Ruby API but not implemented yet"
    end

    def identify_path(path, mode: @mode)
      validate_mode!(mode)
      path = String(path)
      raise ArgumentError, "path does not exist: #{path}" unless File.exist?(path)
      raise ArgumentError, "path is a directory: #{path}" if File.directory?(path)

      Result.from_native(Native.identify_path(path))
    end

    def identify_bytes(bytes, mode: @mode)
      validate_mode!(mode)
      raise TypeError, "bytes must be a String" unless bytes.is_a?(String)

      Result.from_native(Native.identify_bytes(bytes.b))
    end

    private

    def validate_mode!(mode)
      normalized = normalize_mode(mode)
      return if normalized == @mode

      self.class.new(mode: normalized)
    end

    def normalize_mode(mode)
      normalized = mode.to_s.tr("-", "_").to_sym
      return normalized if SUPPORTED_MODES.include?(normalized)

      raise ArgumentError, "unsupported prediction mode: #{mode.inspect}"
    end
  end
end
