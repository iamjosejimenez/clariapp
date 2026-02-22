# frozen_string_literal: true

class ArticleContentService
  class Error < StandardError; end

  NON_CONTENT_SELECTORS = [
    "script",
    "style",
    "noscript",
    "template",
    "nav",
    "header",
    "footer",
    "aside",
    "form",
    "button",
    "input",
    "select",
    "textarea",
    "option",
    "label",
    "svg",
    "canvas",
    "iframe"
  ].join(", ").freeze

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
    body = document.at_css("body")
    return nil if body.nil?

    body.css(NON_CONTENT_SELECTORS).remove

    text_nodes = body.xpath(".//text()[normalize-space()]")
    content = text_nodes.map { |node| normalize_text(node.text) }.reject(&:blank?).join("\n")

    content.presence
  rescue StandardError
    nil
  end

  def normalize_text(text)
    text.to_s.gsub(/\s+/, " ").strip
  end
end
