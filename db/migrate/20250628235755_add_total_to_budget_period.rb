# frozen_string_literal: true

class AddTotalToBudgetPeriod < ActiveRecord::Migration[8.0]
  def change
    add_column :budget_periods, :total, :decimal, precision: 10, scale: 2, null: false, default: 0.0
  end
end
