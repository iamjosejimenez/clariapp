# frozen_string_literal: true

class CreateNewsSummaries < ActiveRecord::Migration[8.1]
  def change
    create_table :news_summaries do |t|
      t.string :title, null: false
      t.text :summary, null: false
      t.date :generation_date, null: false
      t.integer :sources_count, default: 0

      t.timestamps
    end

    add_index :news_summaries, :generation_date, unique: true
  end
end
