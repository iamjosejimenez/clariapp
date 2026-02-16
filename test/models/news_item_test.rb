# frozen_string_literal: true

# == Schema Information
#
# Table name: news_items
# Database name: primary
#
#  id              :integer          not null, primary key
#  category        :string           not null
#  published_at    :datetime         not null
#  relevance_score :decimal(, )      not null
#  snippet         :text             not null
#  source_url      :string           not null
#  title           :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  news_summary_id :integer          not null
#
# Indexes
#
#  index_news_items_on_news_summary_id  (news_summary_id)
#
# Foreign Keys
#
#  news_summary_id  (news_summary_id => news_summaries.id)
#
require "test_helper"

class NewsItemTest < ActiveSupport::TestCase
  test "is invalid when required fields are missing" do
    news_summary = NewsSummary.create!(
      title: "Resumen Económico Chile - 14/02/2026",
      summary: "Contenido de prueba",
      generation_date: Date.current,
      sources_count: 1
    )

    item = NewsItem.new(
      news_summary: news_summary,
      title: "Noticia sin datos"
    )

    assert_not item.valid?
    assert item.errors.added?(:source_url, :blank)
    assert item.errors.added?(:snippet, :blank)
    assert item.errors.added?(:category, :blank)
    assert item.errors.added?(:published_at, :blank)
    assert item.errors.added?(:relevance_score, :blank)
  end
end
