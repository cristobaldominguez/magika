# frozen_string_literal: true

require "test_helper"
require_relative "../tools/release"

class ReleaseValidationTest < Minitest::Test
  def test_stable_tag_maps_to_rubygems_version_and_main
    release = MagikaRelease.parse_tag("v1.2.3")

    assert_equal "1.2.3", release.version
    assert release.stable?
    refute release.prerelease?
    assert_equal "main", release.expected_branch
  end

  def test_beta_tag_maps_to_rubygems_prerelease_and_development
    release = MagikaRelease.parse_tag("v1.2.3-beta.1")

    assert_equal "1.2.3.beta.1", release.version
    refute release.stable?
    assert release.prerelease?
    assert_equal "development", release.expected_branch
  end

  def test_rc_tag_maps_to_rubygems_prerelease_and_development
    release = MagikaRelease.parse_tag("v1.2.3-rc.2")

    assert_equal "1.2.3.rc.2", release.version
    refute release.stable?
    assert release.prerelease?
    assert_equal "development", release.expected_branch
  end

  def test_invalid_tag_is_rejected
    error = assert_raises(ArgumentError) { MagikaRelease.parse_tag("1.2.3-beta.1") }

    assert_match(/Invalid release tag/, error.message)
  end

  def test_zero_prerelease_number_is_rejected
    error = assert_raises(ArgumentError) { MagikaRelease.parse_tag("v1.2.3-beta.0") }

    assert_match(/Invalid release tag/, error.message)
  end

  def test_version_mismatch_is_rejected
    release = MagikaRelease.parse_tag("v1.2.3")
    error = assert_raises(ArgumentError) { MagikaRelease.validate_version!(release, "1.2.4") }

    assert_match(/Version mismatch/, error.message)
  end
end
