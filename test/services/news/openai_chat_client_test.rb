require "test_helper"

class OpenaiChatClientTest < ActiveSupport::TestCase
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
end
