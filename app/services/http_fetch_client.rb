# frozen_string_literal: true

require "ostruct"

class HttpFetchClient
  class Error < StandardError; end

  REQUEST_TIMEOUT_SECONDS = 8
  OPEN_TIMEOUT_SECONDS = 5
  READ_TIMEOUT_SECONDS = 8
  USER_AGENT = "Mozilla/5.0 (compatible; ClariNewsBot/1.0; +https://clariapp.local)"
  MOCK_ENV_KEY = "MOCK_HTTP_FETCH_BODY"

  def get(url)
    if Rails.env.test?
      mock_body = ENV[MOCK_ENV_KEY]
      raise Error, "HTTP fetch client disabled in test without mock payload (#{MOCK_ENV_KEY})" if mock_body.blank?

      return OpenStruct.new(
        body: mock_body,
        headers: { "content-type" => "text/html" },
        success?: true
      )
    end

    HTTParty.get(
      url,
      headers: {
        "User-Agent" => USER_AGENT,
        "Accept" => "text/html,application/xhtml+xml"
      },
      timeout: REQUEST_TIMEOUT_SECONDS,
      open_timeout: OPEN_TIMEOUT_SECONDS,
      read_timeout: READ_TIMEOUT_SECONDS
    )
  rescue HTTParty::Error, Timeout::Error, SocketError, URI::InvalidURIError => e
    raise Error, "HTTP fetch failed: #{e.message}"
  end
end
