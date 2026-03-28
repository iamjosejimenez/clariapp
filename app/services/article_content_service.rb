# frozen_string_literal: true

class ArticleContentService
  class Error < StandardError; end
  DEFAULT_MODEL = "gpt-5.4-nano-2026-03-17"
  EXTRACTION_FAILURE_MESSAGE = "No pude extraer la noticia"
  MAX_HTML_CHARS = 45_000

  NON_CONTENT_SELECTORS = [
    "script",
    "style",
    "noscript",
    "template",
    "nav",
    "header",
    "footer",
    "aside",
    "svg",
    "canvas",
    "iframe"
  ].join(", ").freeze

  def initialize(url:, http_client: HttpFetchClient.new, openai_client: OpenaiChatClient.new, model: DEFAULT_MODEL)
    @url = url
    @http_client = http_client
    @openai_client = openai_client
    @model = model
  end

  def call
    return EXTRACTION_FAILURE_MESSAGE if @url.blank?

    response = @http_client.get(@url)

    return EXTRACTION_FAILURE_MESSAGE unless response.success?
    return EXTRACTION_FAILURE_MESSAGE unless html_response?(response)

    html_fragment = prepare_html_for_llm(response.body)
    return EXTRACTION_FAILURE_MESSAGE if html_fragment.blank?

    extract_content_with_openai(html_fragment)
  rescue HttpFetchClient::Error, OpenaiChatClient::Error
    EXTRACTION_FAILURE_MESSAGE
  end

  private

  def html_response?(response)
    response.headers["content-type"].to_s.include?("text/html")
  end

  def prepare_html_for_llm(html)
    document = Nokogiri::HTML(html)
    body = document.at_css("body") || document.at_css("html")
    return if body.nil?

    body.css(NON_CONTENT_SELECTORS).remove
    compact_html(body.to_html).first(MAX_HTML_CHARS).presence
  rescue StandardError
    nil
  end

  def extract_content_with_openai(html_fragment)
    response = @openai_client.chat_completion!(request_payload(html_fragment))
    normalize_extracted_content(extract_response_text(response))
  end

  def request_payload(html_fragment)
    {
      model: @model,
      messages: [
        {
          role: "system",
          content: <<~PROMPT.squish
            Eres un extractor de contenido periodístico. Recibes el HTML de una página de noticias y debes devolver
            únicamente el contenido textual mínimo y fiel de la noticia principal. Ignora menús, publicidad, módulos
            de "más leídas", titulares secundarios, resúmenes de otras noticias, enlaces a otras noticias, comentarios,
            contenido repetido y cualquier texto que no pertenezca a la noticia central. Si no puedes identificar con
            claridad la noticia principal, si el contenido visible es insuficiente o si parece estar detrás de un paywall,
            responde exactamente: #{EXTRACTION_FAILURE_MESSAGE}
          PROMPT
        },
        {
          role: "user",
          content: <<~PROMPT
            Extrae sólo la noticia principal de esta página en texto plano.

            Reglas:
            - Devuelve únicamente el título y el cuerpo esencial de la noticia principal, en su versión mínima y fiel.
            - No incluyas resúmenes, listados o enlaces de otras noticias de la misma página.
            - No agregues explicaciones, etiquetas, markdown ni texto adicional.
            - Si no logras extraer la noticia principal, responde exactamente: #{EXTRACTION_FAILURE_MESSAGE}

            HTML:
            #{html_fragment}
          PROMPT
        }
      ]
    }
  end

  def extract_response_text(response)
    content = response&.choices&.first&.message&.content

    case content
    when String
      content
    when Array
      content.filter_map { |chunk| text_from_chunk(chunk) }.join("\n")
    else
      text_from_chunk(content)
    end
  end

  def text_from_chunk(chunk)
    return chunk if chunk.is_a?(String)
    return chunk.text if chunk.respond_to?(:text) && chunk.text.present?
    return chunk.content if chunk.respond_to?(:content) && chunk.content.is_a?(String)
    return chunk[:text] if chunk.respond_to?(:[]) && chunk[:text].present?
    return chunk["text"] if chunk.respond_to?(:[]) && chunk["text"].present?
    return chunk[:content] if chunk.respond_to?(:[]) && chunk[:content].is_a?(String)
    return chunk["content"] if chunk.respond_to?(:[]) && chunk["content"].is_a?(String)

    nil
  end

  def normalize_extracted_content(content)
    normalized = sanitize_code_fence(content).to_s.gsub(/\A["']+|["']+\z/, "").strip
    return EXTRACTION_FAILURE_MESSAGE if normalized.blank?
    return EXTRACTION_FAILURE_MESSAGE if normalized.casecmp(EXTRACTION_FAILURE_MESSAGE).zero?

    normalized
  end

  def sanitize_code_fence(content)
    return if content.blank?

    content
      .to_s
      .sub(/\A```(?:text|markdown)?\s*/i, "")
      .sub(/\s*```\z/, "")
      .strip
  end

  def compact_html(html)
    html.to_s.gsub(/>\s+</, "><").gsub(/\s+/, " ").strip
  end
end
