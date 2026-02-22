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

  test "extracts all readable text from body" do
    html = <<~HTML
      <html>
        <body>
          <main><p>Texto en main</p></main>
          <article><h1>Título principal</h1><div>Contenido de noticia</div></article>
          <section><p>Bloque adicional</p></section>
        </body>
      </html>
    HTML

    service = ArticleContentService.new(
      url: "https://example.com/noticia",
      http_client: FakeHttpClient.new(body: html)
    )

    content = service.call
    assert_includes(content, "Texto en main")
    assert_includes(content, "Título principal")
    assert_includes(content, "Contenido de noticia")
    assert_includes(content, "Bloque adicional")
  end

  test "ignores functional page elements" do
    html = <<~HTML
      <html>
        <body>
          <header>Menú superior</header>
          <nav>Enlaces de navegación</nav>
          <form><input value="buscar"><button>Buscar</button></form>
          <main><p>Texto relevante</p></main>
          <footer>Pie</footer>
          <script>console.log("script")</script>
        </body>
      </html>
    HTML

    service = ArticleContentService.new(
      url: "https://example.com/noticia",
      http_client: FakeHttpClient.new(body: html)
    )

    content = service.call
    assert_includes(content, "Texto relevante")
    refute_includes(content, "Menú superior")
    refute_includes(content, "Enlaces de navegación")
    refute_includes(content, "Buscar")
    refute_includes(content, "Pie")
  end

  test "returns nil when response is not html" do
    service = ArticleContentService.new(
      url: "https://example.com/noticia",
      http_client: FakeHttpClient.new(body: "{}", content_type: "application/json")
    )

    assert_nil(service.call)
  end

  test "returns nil when body has no readable text content" do
    html = <<~HTML
      <html>
        <body>
          <script>console.log("sin contenido")</script>
          <style>.hide { display: none; }</style>
        </body>
      </html>
    HTML

    service = ArticleContentService.new(
      url: "https://example.com/noticia",
      http_client: FakeHttpClient.new(body: html)
    )

    assert_nil(service.call)
  end
end
