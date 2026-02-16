# frozen_string_literal: true

class CreateBudgets < ActiveRecord::Migration[8.0]
  def change
    create_table :budgets do |t|
      t.string :name
      t.string :category
      t.text :description
      t.decimal :amount, precision: 10, scale: 2

      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_check_constraint :budgets, "category IN ('mensual', 'quincenal', 'semanal')", name: "budget_category_check"
  end
end
