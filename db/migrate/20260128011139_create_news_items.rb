# frozen_string_literal: true

class CreateNewsItems < ActiveRecord::Migration[8.1]
  def change
    create_table :news_items do |t|
      t.references :news_summary, null: false, foreign_key: true, index: true
      t.string :title, null: false
      t.string :source_url
      t.text :snippet
      t.string :category
      t.datetime :published_at
      t.decimal :relevance_score

      t.timestamps
    end
  end
end
