# frozen_string_literal: true

module Magika
  class ContentType < Struct.new(:label, :description, :mime_type, :group, :extensions, :is_text, keyword_init: true)
    def initialize(label:, description:, mime_type:, group:, extensions:, is_text:)
      super(
        label: label,
        description: description,
        mime_type: mime_type,
        group: group,
        extensions: extensions.freeze,
        is_text: is_text
      )
      freeze
    end

    def text?
      is_text
    end

    def to_h
      {
        label: label,
        description: description,
        mime_type: mime_type,
        group: group,
        extensions: extensions,
        is_text: is_text
      }
    end
  end
end
