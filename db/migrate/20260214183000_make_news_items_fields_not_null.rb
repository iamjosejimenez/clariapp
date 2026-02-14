class MakeNewsItemsFieldsNotNull < ActiveRecord::Migration[8.1]
  def change
    change_column_null :news_items, :category, false, "economia"
    change_column_null :news_items, :published_at, false, Time.current
    change_column_null :news_items, :relevance_score, false, 0
    change_column_null :news_items, :snippet, false, "No disponible"
    change_column_null :news_items, :source_url, false, "https://sin-fuente.local"
  end
end
