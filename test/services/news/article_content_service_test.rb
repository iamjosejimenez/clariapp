# frozen_string_literal: true

require "test_helper"
require "ostruct"

class ArticleContentServiceTest < ActiveSupport::TestCase
  class FakeHttpClient
    def initialize(body:, content_type: "text/html", success: true)
      @body = body
      @content_type = content_type
      @success = success
    end

    def get(_url)
      OpenStruct.new(
        body: @body,
        headers: { "content-type" => @content_type },
        success?: @success
      )
    end
  end

  class FakeOpenaiClient
    attr_reader :last_payload

    def initialize(content:)
      @content = content
    end

    def chat_completion!(payload)
      @last_payload = payload
      OpenStruct.new(
        choices: [
          OpenStruct.new(
            message: OpenStruct.new(
              content: @content
            )
          )
        ]
      )
    end
  end

  test "returns the extracted main article from chatgpt" do
    html = <<~HTML
      <html>
        <body>
          <article><h1>Título principal</h1><div>Contenido central de la noticia</div></article>
          <section><a href="/otra">Otra noticia resumida</a></section>
        </body>
      </html>
    HTML
    openai_client = FakeOpenaiClient.new(content: "Título principal\nContenido central de la noticia")

    service = ArticleContentService.new(
      url: "https://example.com/noticia",
      http_client: FakeHttpClient.new(body: html),
      openai_client: openai_client
    )

    content = service.call

    assert_equal("Título principal\nContenido central de la noticia", content)
    assert_includes(openai_client.last_payload[:messages].second[:content], "No incluyas resúmenes, listados o enlaces de otras noticias")
    assert_includes(openai_client.last_payload[:messages].second[:content], "<article><h1>Título principal</h1><div>Contenido central de la noticia</div></article>")
  end

  test "instructs chatgpt to return the fallback when the page is paywalled or ambiguous" do
    html = <<~HTML
      <html>
        <body>
          <article><h1>Título visible</h1><p>Suscríbete para seguir leyendo</p></article>
        </body>
      </html>
    HTML
    openai_client = FakeOpenaiClient.new(content: ArticleContentService::EXTRACTION_FAILURE_MESSAGE)

    service = ArticleContentService.new(
      url: "https://example.com/noticia",
      http_client: FakeHttpClient.new(body: html),
      openai_client: openai_client
    )

    content = service.call

    assert_equal(ArticleContentService::EXTRACTION_FAILURE_MESSAGE, content)
    assert_includes(openai_client.last_payload[:messages].first[:content], "si parece estar detrás de un paywall")
  end

  test "returns fallback when response is not html" do
    service = ArticleContentService.new(
      url: "https://example.com/noticia",
      http_client: FakeHttpClient.new(body: "{}", content_type: "application/json"),
      openai_client: FakeOpenaiClient.new(content: "No debería usarse")
    )

    assert_equal(ArticleContentService::EXTRACTION_FAILURE_MESSAGE, service.call)
  end

  test "returns fallback when chatgpt responds with blank content" do
    html = <<~HTML
      <html>
        <body>
          <article><h1>Título principal</h1><p>Contenido visible</p></article>
        </body>
      </html>
    HTML

    service = ArticleContentService.new(
      url: "https://example.com/noticia",
      http_client: FakeHttpClient.new(body: html),
      openai_client: FakeOpenaiClient.new(content: "   ")
    )

    assert_equal(ArticleContentService::EXTRACTION_FAILURE_MESSAGE, service.call)
  end
end
