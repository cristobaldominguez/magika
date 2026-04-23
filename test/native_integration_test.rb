# frozen_string_literal: true

require_relative "test_helper"

class NativeIntegrationTest < Minitest::Test
  def setup
    skip "set MAGIKA_NATIVE_TEST=1 after compiling the native extension" unless ENV["MAGIKA_NATIVE_TEST"] == "1"

    require "magika"
  end

  def test_identify_bytes_returns_typed_result
    result = Magika.identify_bytes("#!/bin/sh\necho hello\n")

    assert_instance_of Magika::Result, result
    assert_kind_of String, result.label
    assert_kind_of String, result.mime_type
    assert_kind_of Numeric, result.score
  end

  def test_identify_path_returns_typed_result
    path = File.expand_path("fixtures/shell.sh", __dir__)

    result = Magika.identify_path(path)

    assert_instance_of Magika::Result, result
    assert_kind_of String, result.label
    assert_kind_of Array, result.extensions
  end
end
