# == Schema Information
#
# Table name: news_summaries
# Database name: primary
#
#  id              :integer          not null, primary key
#  generation_date :date             not null
#  sources_count   :integer          default(0), not null
#  summary         :text             not null
#  title           :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_news_summaries_on_generation_date  (generation_date) UNIQUE
#
require "test_helper"

class NewsSummaryTest < ActiveSupport::TestCase
  test "is invalid without sources_count" do
    summary = NewsSummary.new(
      title: "Resumen Económico Chile - 14/02/2026",
      summary: "Contenido de prueba",
      generation_date: Date.current,
      sources_count: nil
    )

    assert_not summary.valid?
    assert summary.errors.added?(:sources_count, :blank)
  end
end
