# frozen_string_literal: true

require "test_helper"
require "ostruct"

class NewsItemComponentTest < ViewComponent::TestCase
  test "renderiza la fecha publicada usando el helper de chile" do
    item = OpenStruct.new(
      title: "IPC sorprende al mercado",
      source_url: "https://example.com/noticia",
      snippet: "El dato mensual supero las expectativas.",
      category: "Inflacion",
      published_at: Time.utc(2026, 1, 15, 2, 30, 0)
    )

    result = render_inline(NewsItemComponent.new(item: item))

    assert_includes result.to_html, "14/01/2026 23:30"
  end
end
