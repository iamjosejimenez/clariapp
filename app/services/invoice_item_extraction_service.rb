# frozen_string_literal: true

require "base64"
require "json"

class InvoiceItemExtractionService
  class Error < StandardError; end

  DEFAULT_MODEL = "gpt-4o-mini"
  OPENAI_ENDPOINT = "https://api.openai.com/v1/chat/completions"

  def initialize(image, model: DEFAULT_MODEL, client: HTTParty)
    @image = image
    @model = model
    @client = client
  end

  def call
    raise Error, "Missing invoice image" if image.blank?

    api_key = ENV["OPENAI_API_KEY"]
    raise Error, "Missing OpenAI API key" if api_key.blank?

    response = client.post(
      OPENAI_ENDPOINT,
      headers: request_headers(api_key),
      body: request_body.to_json
    )

    unless response.success?
      message = response.parsed_response.dig("error", "message") rescue nil
      raise Error, "OpenAI request failed (status #{response.code})#{": #{message}" if message.present?}"
    end

    raw_content = response.parsed_response.dig("choices", 0, "message", "content")
    parsed_content = parse_response_content(raw_content)

    items = parsed_content["items"] || parsed_content[:items]
    raise Error, "OpenAI response did not contain items" unless items.is_a?(Array)

    items
  end

  private

  attr_reader :image, :model, :client

  def parse_response_content(raw_content)
    case raw_content
    when String
      parse_json_string(sanitize_code_fence(raw_content))
    when Array
      combined = raw_content.filter_map { |chunk| extract_text_chunk(chunk) }.join
      parse_json_string(sanitize_code_fence(combined))
    when Hash
      return raw_content if raw_content.key?("items") || raw_content.key?(:items)

      text = raw_content["text"] || raw_content[:text] || raw_content["content"] || raw_content[:content]
      if text.present?
        parse_json_string(sanitize_code_fence(text))
      else
        raw_content
      end
    else
      raise Error, "Empty response from OpenAI"
    end
  end

  def sanitize_code_fence(content)
    return if content.blank?

    content
      .to_s
      .sub(/\A```(?:json)?\s*/i, "")
      .sub(/\s*```\z/, "")
      .strip
  end

  def parse_json_string(content)
    raise Error, "Empty response from OpenAI" if content.blank?

    JSON.parse(content)
  rescue JSON::ParserError
    raise Error, "Failed to parse OpenAI response"
  end

  def extract_text_chunk(chunk)
    return chunk if chunk.is_a?(String)
    return chunk["text"] if chunk.is_a?(Hash) && chunk["text"].present?
    return chunk[:text] if chunk.respond_to?(:[]) && chunk[:text].present?
    return chunk["content"] if chunk.is_a?(Hash) && chunk["content"].is_a?(String)
    return chunk[:content] if chunk.respond_to?(:[]) && chunk[:content].is_a?(String)

    nil
  end

  def request_headers(api_key)
    {
      "Authorization" => "Bearer #{api_key}",
      "Content-Type" => "application/json"
    }
  end

  def request_body
    {
      model: model,
      temperature: 0.2,
      messages: [
        {
          role: "system",
          content: <<~PROMPT.squish
            You extract structured line items from invoice images.
            Respond strictly with JSON that matches: {"items":[{"name":"string","quantity":number,"unit_price":number,"total":number}]}
            Use null for unknown numeric values.
          PROMPT
        },
        {
          role: "user",
          content: [
            {
              type: "text",
              text: "Analyze this invoice and list each line item with name, quantity, unit_price, and total."
            },
            {
              type: "image_url",
              image_url: {
                url: encoded_image_url
              }
            }
          ]
        }
      ]
    }
  end

  def encoded_image_url
    "data:#{mime_type};base64,#{Base64.strict_encode64(read_image_binary)}"
  end

  def mime_type
    return image.content_type if image.respond_to?(:content_type) && image.content_type.present?

    "image/jpeg"
  end

  def read_image_binary
    if image.respond_to?(:read)
      data = image.read
      image.rewind if image.respond_to?(:rewind)
      data
    elsif image.respond_to?(:tempfile) && image.tempfile.respond_to?(:read)
      tempfile = image.tempfile
      data = tempfile.read
      tempfile.rewind if tempfile.respond_to?(:rewind)
      data
    elsif image.respond_to?(:path)
      File.binread(image.path)
    else
      raise Error, "Unsupported image input"
    end
  end
end
