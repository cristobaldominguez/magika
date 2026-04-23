# frozen_string_literal: true

require_relative "test_helper"

class MagikaApiTest < Minitest::Test
  def test_content_type_to_h
    content_type = Magika::ContentType.new(
      label: "ruby",
      description: "Ruby source",
      mime_type: "text/x-ruby",
      group: "code",
      extensions: ["rb"],
      is_text: true
    )

    assert_equal "ruby", content_type.to_h.fetch(:label)
    assert_predicate content_type, :text?
  end

  def test_result_delegates_content_type_fields
    result = Magika::Result.from_native(
      "label" => "ruby",
      "description" => "Ruby source",
      "mime_type" => "text/x-ruby",
      "group" => "code",
      "extensions" => ["rb"],
      "is_text" => true,
      "score" => 0.99
    )

    assert_equal "ruby", result.label
    assert_equal "text/x-ruby", result.mime_type
    assert_in_delta 0.99, result.score
  end

  def test_detector_rejects_invalid_mode_before_native_call
    error = assert_raises(ArgumentError) { Magika::Detector.new(mode: :wild_guess) }

    assert_match(/unsupported prediction mode/, error.message)
  end

  def test_detector_reserves_modes_not_supported_by_upstream_rust
    error = assert_raises(NotImplementedError) { Magika::Detector.new(mode: :best_guess) }

    assert_match(/high-confidence inference only/, error.message)
  end
end
