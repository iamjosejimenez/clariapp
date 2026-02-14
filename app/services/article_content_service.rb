class ArticleContentService
  class Error < StandardError; end

  MAX_PARAGRAPHS = 25
  MAX_CONTENT_CHARS = 7000
  MIN_CONTENT_CHARS = 250

  def initialize(url:, http_client: HttpFetchClient.new)
    @url = url
    @http_client = http_client
  end

  def call
    return nil if @url.blank?

    response = @http_client.get(@url)

    return nil unless response.success?
    return nil unless html_response?(response)

    extract_content(response.body)
  rescue HttpFetchClient::Error
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
