# == Schema Information
#
# Table name: budget_periods
#
#  id         :integer          not null, primary key
#  budget_id  :integer          not null
#  year       :integer
#  period     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_budget_periods_on_budget_id                      (budget_id)
#  index_budget_periods_on_budget_id_and_year_and_period  (budget_id,year,period) UNIQUE
#

class BudgetPeriod < ApplicationRecord
  belongs_to :budget
  has_many :expenses, dependent: :destroy

  validates :year, presence: true
  validates :period, presence: true

  def total_spent
    expenses.sum(:amount)
  end

  def remaining
    budget.amount - total_spent
  end
end
