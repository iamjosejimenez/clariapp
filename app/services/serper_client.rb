require "ostruct"

class SerperClient
  class Error < StandardError; end

  ENDPOINT = "https://google.serper.dev/search"
  MOCK_ENV_KEY = "MOCK_SERPER_RESPONSE_JSON"

  def post_search!(body:)
    if Rails.env.test?
      mock_payload = ENV[MOCK_ENV_KEY]
      raise Error, "Serper client disabled in test without mock payload (#{MOCK_ENV_KEY})" if mock_payload.blank?

      return OpenStruct.new(
        code: 200,
        body: mock_payload,
        success?: true,
        message: "OK"
      )
    end

    response = HTTParty.post(
      ENDPOINT,
      headers: {
        "X-API-KEY" => api_key,
        "Content-Type" => "application/json"
      },
      body: body.to_json,
      timeout: 10
    )

    return response if response.success?

    raise Error, "Serper API request failed: #{response.code} - #{response.message}"
  rescue HTTParty::Error, Timeout::Error => e
    raise Error, "Network error calling Serper API: #{e.message}"
  end

  private

  def api_key
    key = ENV["SERPER_API_KEY"]
    raise Error, "Missing SERPER_API_KEY environment variable" if key.blank?

    key
  end
end
