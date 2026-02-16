# frozen_string_literal: true

require "test_helper"
require "ostruct"

class NewsAggregationServiceTest < ActiveSupport::TestCase
  class FakeOpenaiClient
    def initialize(responses)
      @responses = responses
    end

    def chat_completion!(_payload)
      @responses.shift
    end
  end

  class FakeWebSearchService
    def initialize(query:, num_results:)
      @query = query
      @num_results = num_results
    end

    def call
      [
        {
          title: "Dólar cierra con baja",
          url: "https://example.com/dolar",
          snippet: "El tipo de cambio cerró a la baja.",
          date: Time.zone.now,
          position: 1
        }
      ]
    end
  end

  class FakeArticleContentService
    def initialize(url:)
      @url = url
    end

    def call
      "Contenido extendido de la noticia para mejorar el resumen."
    end
  end

  test "creates summary and items using injected clients only" do
    today = Time.zone.today
    NewsSummary.where(generation_date: today).destroy_all

    tool_call = OpenStruct.new(
      id: "call_1",
      function: OpenStruct.new(
        name: "web_search",
        arguments: { query: "economia chile hoy", num_results: 5 }.to_json
      )
    )

    first_response = OpenStruct.new(
      choices: [ OpenStruct.new(message: OpenStruct.new(tool_calls: [ tool_call ])) ]
    )
    second_response = OpenStruct.new(
      choices: [ OpenStruct.new(message: OpenStruct.new(content: "Resumen generado de prueba")) ]
    )

    service = NewsAggregationService.new(
      openai_client: FakeOpenaiClient.new([ first_response, second_response ]),
      web_search_service_class: FakeWebSearchService,
      article_content_service_class: FakeArticleContentService
    )

    news_summary = service.call

    assert_equal("Resumen generado de prueba", news_summary.summary)
    assert_equal(today, news_summary.generation_date)
    assert_equal(1, news_summary.news_items.count)
    assert_equal("Dólar cierra con baja", news_summary.news_items.first.title)
  end
end
