require "ostruct"

class OpenaiChatClient
  class Error < StandardError; end

  MOCK_ENV_KEY = "MOCK_OPENAI_CHAT_COMPLETION_JSON"

  def initialize(client: OpenAI::Client.new)
    @client = client
  end

  def chat_completion!(payload)
    if Rails.env.test?
      mock_payload = ENV[MOCK_ENV_KEY]
      raise Error, "OpenAI client disabled in test without mock payload (#{MOCK_ENV_KEY})" if mock_payload.blank?

      return deep_open_struct(JSON.parse(mock_payload))
    end

    @client.chat.completions.create(payload)
  end

  private

  def deep_open_struct(value)
    case value
    when Hash
      OpenStruct.new(value.transform_values { |v| deep_open_struct(v) })
    when Array
      value.map { |v| deep_open_struct(v) }
    else
      value
    end
  end
end
