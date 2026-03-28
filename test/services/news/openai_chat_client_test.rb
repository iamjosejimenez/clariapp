# frozen_string_literal: true

require "test_helper"
require "uri"

class OpenaiChatClientTest < ActiveSupport::TestCase
  class FakeSdkClient
    def initialize(error:)
      @error = error
    end

    def chat
      self
    end

    def completions
      self
    end

    def create(_payload)
      raise @error
    end
  end

  test "raises in test environment without mock payload" do
    previous = ENV["MOCK_OPENAI_CHAT_COMPLETION_JSON"]
    ENV.delete("MOCK_OPENAI_CHAT_COMPLETION_JSON")

    client = OpenaiChatClient.new(client: Object.new)

    error = assert_raises(OpenaiChatClient::Error) do
      client.chat_completion!({})
    end

    assert_match("OpenAI client disabled in test", error.message)
  ensure
    ENV["MOCK_OPENAI_CHAT_COMPLETION_JSON"] = previous
  end

  test "returns object-like mock response when payload is provided" do
    previous = ENV["MOCK_OPENAI_CHAT_COMPLETION_JSON"]
    ENV["MOCK_OPENAI_CHAT_COMPLETION_JSON"] = {
      choices: [
        {
          message: {
            content: "Resumen de prueba"
          }
        }
      ]
    }.to_json

    client = OpenaiChatClient.new(client: Object.new)
    response = client.chat_completion!({})

    assert_equal("Resumen de prueba", response.choices.first.message.content)
  ensure
    ENV["MOCK_OPENAI_CHAT_COMPLETION_JSON"] = previous
  end

  test "wraps sdk errors in production mode" do
    sdk_error = OpenAI::Errors::RateLimitError.new(
      url: URI("https://api.openai.com/v1/chat/completions"),
      status: 429,
      headers: nil,
      body: nil,
      request: nil,
      response: nil,
      message: "Too many requests"
    )
    client = OpenaiChatClient.new(client: FakeSdkClient.new(error: sdk_error), test_mode: false)

    error = assert_raises(OpenaiChatClient::Error) do
      client.chat_completion!({})
    end

    assert_match("OpenAI chat completion failed: Too many requests", error.message)
    assert_instance_of(OpenAI::Errors::RateLimitError, error.cause)
  end
end
