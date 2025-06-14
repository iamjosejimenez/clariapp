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

  def start_and_end_dates
    case budget.category
    when "mensual"
      start_date = Date.new(year, period, 1)
      end_date = start_date.end_of_month

    when "quincenal"
      # Quincena 1 → enero 1–15, Quincena 2 → enero 16–31, Quincena 3 → febrero 1–15, ...
      month = ((period - 1) / 2) + 1
      is_first_half = period.odd?

      start_date = is_first_half ? Date.new(year, month, 1) : Date.new(year, month, 16)
      end_date = is_first_half ? Date.new(year, month, 15) : start_date.end_of_month

    when "semanal"
      start_date = Date.commercial(year, period, 1)
      end_date = start_date + 6.days

    else
      return [ nil, nil ]
    end

    [ start_date, end_date ]
  end


  def human_label
    start_date, end_date = start_and_end_dates
    return "Periodo #{period}/#{year}" unless start_date && end_date
    "Del #{I18n.l(start_date, format: :short)} al #{I18n.l(end_date, format: :short)}"
  end
end
