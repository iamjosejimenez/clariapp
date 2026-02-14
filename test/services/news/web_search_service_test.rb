require "test_helper"
require "ostruct"

class WebSearchServiceTest < ActiveSupport::TestCase
  class FakeSerperClient
    def initialize(body_json)
      @body_json = body_json
    end

    def post_search!(body:)
      @request_body = body
      OpenStruct.new(code: 200, success?: true, body: @body_json, message: "OK")
    end

    attr_reader :request_body
  end

  test "parses serper results from injected client without external request" do
    body_json = {
      organic: [
        {
          title: "BCCh mantiene tasa",
          link: "https://example.com/noticia-1",
          snippet: "El Banco Central mantuvo la TPM.",
          date: "hace 2 horas"
        }
      ]
    }.to_json

    fake_client = FakeSerperClient.new(body_json)
    results = WebSearchService.new(query: "bcch hoy", num_results: 5, serper_client: fake_client).call

    assert_equal(1, results.size)
    assert_equal("BCCh mantiene tasa", results.first[:title])
    assert_equal("https://example.com/noticia-1", results.first[:url])
    assert_equal("El Banco Central mantuvo la TPM.", results.first[:snippet])
    assert_equal(1, results.first[:position])
    assert_instance_of(ActiveSupport::TimeWithZone, results.first[:date])
    assert_equal("bcch hoy", fake_client.request_body[:q])
  end
end
