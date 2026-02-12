class WebSearchService
  class Error < StandardError; end

  SERPER_ENDPOINT = "https://google.serper.dev/search"
  CACHE_EXPIRY = 1.hour

  def initialize(query:, num_results: 5)
    @query = query
    @num_results = num_results
  end

  def call
    cache_key = "web_search:#{@query}:#{@num_results}"

    Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRY) do
      perform_search
    end
  end

  private

  def perform_search
    api_key = ENV["SERPER_API_KEY"]
    raise Error, "Missing SERPER_API_KEY environment variable" if api_key.blank?

    response = HTTParty.post(
      SERPER_ENDPOINT,
      headers: {
        "X-API-KEY" => api_key,
        "Content-Type" => "application/json"
      },
      body: {
        q: @query,
        num: @num_results
      }.to_json,
      timeout: 10
    )

    unless response.success?
      raise Error, "Serper API request failed: #{response.code} - #{response.message}"
    end

    parse_response(response)
  rescue HTTParty::Error, Timeout::Error => e
    raise Error, "Network error calling Serper API: #{e.message}"
  end

  def parse_response(response)
    data = JSON.parse(response.body)
    organic = data["organic"] || []

    organic.map.with_index do |result, index|
      {
        title: result["title"],
        url: result["link"],
        snippet: result["snippet"],
        date: parse_date(result["date"]),
        position: index + 1
      }
    end
  rescue JSON::ParserError => e
    raise Error, "Failed to parse Serper API response: #{e.message}"
  end

  def parse_date(date_string)
    return nil if date_string.blank?

    # Serper puede devolver fechas en varios formatos
    # Intentar parsear, si falla retornar nil
    Date.parse(date_string)
  rescue ArgumentError, TypeError
    nil
  end
end
