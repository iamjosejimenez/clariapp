# frozen_string_literal: true

class AddBudgetPeriodToExpenses < ActiveRecord::Migration[8.0]
  def change
    add_reference :expenses, :budget_period, null: false, foreign_key: true
  end
end
