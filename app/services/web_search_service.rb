# frozen_string_literal: true

class WebSearchService
  class Error < StandardError; end

  attr_reader :query
  attr_reader :num_pages

  def initialize(query:, num_pages: 2, serper_client: SerperClient.new)
    @query = query
    @num_pages = num_pages
    @serper_client = serper_client
  end

  def call
    perform_search
  end

  private

  def perform_search
    news_list = []
    index = 0
    num_pages.times do |page|
      response = @serper_client.post_search!(
        body: {
          "q": query,
          "gl": "cl",
          "hl": "es-419",
          "tbs": "qdr:d",
          "page": page + 1
        }
      )

      JSON.parse(response.body)["news"].each do |news|
        news.delete("imageUrl")
        news["index"] = index
        index += 1
        news_list << news
      end
    end

    news_list
  end
end
