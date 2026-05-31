# frozen_string_literal: true

require "test_helper"
require "ostruct"

class NewsAggregationServiceTest < ActiveSupport::TestCase
  class FakeResponsesApi
    def initialize(responses)
      @responses = responses
    end

    def create(**)
      @responses.shift
    end
  end

  class FakeOpenAIClient
    attr_reader :responses

    def initialize(responses)
      @responses = FakeResponsesApi.new(responses)
    end
  end

  class FakeArticleContentService
    def initialize(url:)
      @url = url
    end

    def call
      "Contenido extendido para #{@url}"
    end
  end

  setup do
    NewsSummary.delete_all
  end

  def with_replaced_singleton_method(target, method_name, implementation)
    singleton_class = target.singleton_class
    original_defined = singleton_class.method_defined?(method_name) || singleton_class.private_method_defined?(method_name)
    original_method = singleton_class.instance_method(method_name) if original_defined

    singleton_class.define_method(method_name, &implementation)
    yield
  ensure
    if original_defined
      singleton_class.define_method(method_name, original_method)
    else
      singleton_class.remove_method(method_name)
    end
  end

  test "ignora indices invalidos antes de acceder a la noticia" do
    search_results = [
      {
        "title" => "Dólar cierra con baja",
        "link" => "https://example.com/dolar",
        "snippet" => "El tipo de cambio cerró a la baja."
      }
    ]

    ranking_response = OpenStruct.new(output_text: "99,0")
    summary_response = OpenStruct.new(output_text: "Resumen generado de prueba")
    openai_client = FakeOpenAIClient.new([ ranking_response, summary_response ])

    with_replaced_singleton_method(WebSearchService, :new, ->(**) { OpenStruct.new(call: search_results) }) do
      with_replaced_singleton_method(OpenAI::Client, :new, -> { openai_client }) do
        with_replaced_singleton_method(ArticleContentService, :new, ->(url:) { FakeArticleContentService.new(url: url) }) do
          news_summary = NewsAggregationService.new.call

          assert_equal "Resumen generado de prueba", news_summary.summary
          assert_equal 1, news_summary.news_items.count
          assert_equal "Dólar cierra con baja", news_summary.news_items.first.title
        end
      end
    end
  end
end
