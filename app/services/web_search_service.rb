class WebSearchService
  class Error < StandardError; end

  CACHE_EXPIRY = 1.hour
  COUNTRY_CODE = "cl"
  LANGUAGE = "es-419"
  NEWS_VERTICAL = "nws"
  FRESHNESS_FILTER = "qdr:d" # últimas 24 horas

  def initialize(query:, num_results: 5, serper_client: SerperClient.new)
    @query = query
    @num_results = num_results
    @serper_client = serper_client
  end

  def call
    cache_key = "web_search:#{@query}:#{@num_results}"

    Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRY) do
      perform_search
    end
  end

  private

  def perform_search
    response = @serper_client.post_search!(
      body: {
        q: @query,
        num: @num_results,
        tbm: NEWS_VERTICAL,
        gl: COUNTRY_CODE,
        hl: LANGUAGE,
        tbs: FRESHNESS_FILTER
      }
    )

    parse_response(response)
  rescue SerperClient::Error => e
    raise Error, e.message
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

    parse_relative_date(date_string) || parse_absolute_date(date_string)
  rescue ArgumentError, TypeError, NoMethodError
    nil
  end

  def parse_relative_date(date_string)
    text = normalize_date_text(date_string)
    now = Time.zone.now

    case text
    when /\Ahace\s+(\d+)\s*(min|mins|minuto|minutos)\b/
      now - Regexp.last_match(1).to_i.minutes
    when /\Ahace\s+(\d+)\s*(hora|horas|hr|hrs)\b/
      now - Regexp.last_match(1).to_i.hours
    when /\Ahace\s+(\d+)\s*(dia|dias)\b/
      now - Regexp.last_match(1).to_i.days
    when /\A(\d+)\s*(min|mins|minute|minutes)\s+ago\z/
      now - Regexp.last_match(1).to_i.minutes
    when /\A(\d+)\s*(hour|hours|hr|hrs)\s+ago\z/
      now - Regexp.last_match(1).to_i.hours
    when /\A(\d+)\s*(day|days)\s+ago\z/
      now - Regexp.last_match(1).to_i.days
    when /\Aayer\z/
      now - 1.day
    else
      nil
    end
  end

  def parse_absolute_date(date_string)
    Time.zone.parse(date_string) || Date.parse(date_string).in_time_zone
  rescue ArgumentError, TypeError
    nil
  end

  def normalize_date_text(value)
    value
      .to_s
      .unicode_normalize(:nfkd)
      .encode("ASCII", replace: "", undef: :replace, invalid: :replace)
      .downcase
      .strip
  end
end
