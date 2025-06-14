# == Schema Information
#
# Table name: expenses
#
#  id               :integer          not null, primary key
#  description      :string
#  amount           :decimal(, )
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  budget_period_id :integer          not null
#
# Indexes
#
#  index_expenses_on_budget_period_id  (budget_period_id)
#

class Expense < ApplicationRecord
  belongs_to :budget_period

  validates :description, presence: true
  validates :amount, numericality: { greater_than: 0 }
end
