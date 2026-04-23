# frozen_string_literal: true

module MagikaRelease
  TAG_PATTERN = /\Av(?<base>\d+\.\d+\.\d+)(?:-(?<channel>beta|rc)\.(?<number>[1-9]\d*))?\z/

  Release = Struct.new(:tag, :version, :stable, :expected_branch, keyword_init: true) do
    def prerelease?
      !stable
    end

    def stable?
      stable
    end
  end

  module_function

  def parse_tag(tag)
    match = TAG_PATTERN.match(tag.to_s)
    raise ArgumentError, "Invalid release tag #{tag.inspect}. Expected vX.Y.Z, vX.Y.Z-beta.N, or vX.Y.Z-rc.N." unless match

    version = if match[:channel]
                "#{match[:base]}.#{match[:channel]}.#{match[:number]}"
              else
                match[:base]
              end
    stable = match[:channel].nil?

    Release.new(
      tag: tag,
      version: version,
      stable: stable,
      expected_branch: stable ? "main" : "development"
    )
  end

  def validate_version!(release, actual_version)
    return if actual_version.to_s == release.version

    raise ArgumentError,
          "Version mismatch: tag #{release.tag.inspect} maps to #{release.version.inspect}, " \
          "but Magika::VERSION is #{actual_version.inspect}."
  end
end
