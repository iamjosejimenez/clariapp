# == Schema Information
#
# Table name: budgets
# Database name: primary
#
#  id          :integer          not null, primary key
#  amount      :decimal(10, 2)
#  category    :string
#  description :text
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :integer          not null
#
# Indexes
#
#  index_budgets_on_user_id  (user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#

class Budget < ApplicationRecord
  belongs_to :user
  has_many :budget_periods, dependent: :destroy
  has_many :expenses, through: :budget_periods

  CATEGORIES = %w[mensual quincenal semanal].freeze

  validates :name, presence: true
  validates :category, inclusion: { in: CATEGORIES }
  validates :amount, numericality: { greater_than_or_equal_to: 0 }

  def current_period
    year = Date.today.year
    period = current_period_number
    budget_period = budget_periods.find_or_create_by(year: year, period: period)
    surplus = budget_period.previous_period&.remaining || 0
    budget_period.total = amount + surplus
    budget_period.save
    budget_period
  end

  def current_period_number
    today = Date.today
    case category
    when "mensual"
      today.month
    when "quincenal"
      month = today.month
      is_first_half = today.day <= 15
      period = (month - 1) * 2 + (is_first_half ? 1 : 2)
      period
    when "semanal"
      today.cweek
    else
      raise "Categoría desconocida: #{category}"
    end
  end
end
