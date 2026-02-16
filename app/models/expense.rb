# frozen_string_literal: true

# == Schema Information
#
# Table name: expenses
# Database name: primary
#
#  id               :integer          not null, primary key
#  amount           :decimal(, )
#  description      :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  budget_period_id :integer          not null
#
# Indexes
#
#  index_expenses_on_budget_period_id  (budget_period_id)
#
# Foreign Keys
#
#  budget_period_id  (budget_period_id => budget_periods.id)
#

class Expense < ApplicationRecord
  belongs_to :budget_period

  validates :description, presence: true
  validates :amount, numericality: { greater_than: 0 }
end
