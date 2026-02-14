class ArticleContentService
  class Error < StandardError; end

  REQUEST_TIMEOUT_SECONDS = 8
  OPEN_TIMEOUT_SECONDS = 5
  READ_TIMEOUT_SECONDS = 8
  MAX_PARAGRAPHS = 25
  MAX_CONTENT_CHARS = 7000
  MIN_CONTENT_CHARS = 250
  USER_AGENT = "Mozilla/5.0 (compatible; ClariNewsBot/1.0; +https://clariapp.local)"

  def initialize(url:)
    @url = url
  end

  def call
    return nil if @url.blank?

    response = HTTParty.get(
      @url,
      headers: {
        "User-Agent" => USER_AGENT,
        "Accept" => "text/html,application/xhtml+xml"
      },
      timeout: REQUEST_TIMEOUT_SECONDS,
      open_timeout: OPEN_TIMEOUT_SECONDS,
      read_timeout: READ_TIMEOUT_SECONDS
    )

    return nil unless response.success?
    return nil unless html_response?(response)

    extract_content(response.body)
  rescue HTTParty::Error, Timeout::Error, SocketError, URI::InvalidURIError
    nil
  end

  private

  def html_response?(response)
    response.headers["content-type"].to_s.include?("text/html")
  end

  def extract_content(html)
    document = Nokogiri::HTML(html)
    document.css("script, style, nav, header, footer, aside, form, noscript, svg").remove

    container = document.at_css("article") || document.at_css("main") || document.at_css("body")
    return nil if container.nil?

    paragraphs = container.css("p").map { |node| normalize_text(node.text) }.reject(&:blank?)
    paragraphs = paragraphs.select { |text| text.length >= 45 }.first(MAX_PARAGRAPHS)
    return nil if paragraphs.empty?

    content = paragraphs.join("\n\n")
    content = normalize_text(content)
    return nil if content.length < MIN_CONTENT_CHARS

    content[0, MAX_CONTENT_CHARS]
  rescue StandardError
    nil
  end

  def normalize_text(text)
    text.to_s.gsub(/\s+/, " ").strip
  end
end
