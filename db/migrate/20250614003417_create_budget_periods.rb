# frozen_string_literal: true

class CreateBudgetPeriods < ActiveRecord::Migration[8.0]
  def change
    create_table :budget_periods do |t|
      t.references :budget, null: false, foreign_key: true
      t.integer :year
      t.integer :period

      t.timestamps
    end

    add_index :budget_periods, [ :budget_id, :year, :period ], unique: true
  end
end
