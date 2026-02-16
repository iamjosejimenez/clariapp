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

  test "extracts article content from html body" do
    html = <<~HTML
      <html>
        <body>
          <article>
            <p>La economía chilena mostró señales de recuperación durante la jornada, con movimientos graduales en distintos sectores productivos y una reacción positiva de parte de los analistas locales.</p>
            <p>El tipo de cambio cerró con baja volatilidad y el mercado reaccionó de forma moderada, mientras inversionistas monitorean próximas decisiones del Banco Central y datos de inflación esperados para el cierre de semana.</p>
          </article>
        </body>
      </html>
    HTML

    service = ArticleContentService.new(
      url: "https://example.com/noticia",
      http_client: FakeHttpClient.new(body: html)
    )

    content = service.call
    assert_includes(content, "La economía chilena mostró señales de recuperación")
  end

  test "returns nil when response is not html" do
    service = ArticleContentService.new(
      url: "https://example.com/noticia",
      http_client: FakeHttpClient.new(body: "{}", content_type: "application/json")
    )

    assert_nil(service.call)
  end
end
