# frozen_string_literal: true

require_relative "content_type"

module Magika
  class Result < Struct.new(:content_type, :score, keyword_init: true)
    def self.from_native(payload)
      content_type = ContentType.new(
        label: payload.fetch("label"),
        description: payload.fetch("description"),
        mime_type: payload.fetch("mime_type"),
        group: payload.fetch("group"),
        extensions: payload.fetch("extensions"),
        is_text: payload.fetch("is_text")
      )

      new(content_type: content_type, score: payload.fetch("score"))
    end

    def initialize(content_type:, score:)
      super
      freeze
    end

    def label = content_type.label
    def description = content_type.description
    def mime_type = content_type.mime_type
    def group = content_type.group
    def extensions = content_type.extensions
    def text? = content_type.text?

    def to_h
      content_type.to_h.merge(score: score)
    end
  end
end
