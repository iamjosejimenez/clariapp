# frozen_string_literal: true

class MakeNewsSummarySourcesCountNotNull < ActiveRecord::Migration[8.1]
  def change
    change_column_null :news_summaries, :sources_count, false, 0
  end
end
