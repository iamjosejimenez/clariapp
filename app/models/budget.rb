# == Schema Information
#
# Table name: budgets
#
#  id          :integer          not null, primary key
#  name        :string
#  category    :string
#  description :text
#  amount      :decimal(10, 2)
#  user_id     :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_budgets_on_user_id  (user_id)
#

class Budget < ApplicationRecord
  belongs_to :user
  has_many :budget_periods, dependent: :destroy

  CATEGORIES = %w[mensual quincenal semanal].freeze

  validates :name, presence: true
  validates :category, inclusion: { in: CATEGORIES }
  validates :amount, numericality: { greater_than_or_equal_to: 0 }

  def current_period
    year = Date.today.year
    period = current_period_number
    budget_periods.find_or_create_by(year: year, period: period)
  end

  def current_period_number
    today = Date.today
    case category
    when "mensual"
      today.month
    when "quincenal"
      ((today.yday - 1) / 14) + 1
    when "semanal"
      today.cweek
    else
      raise "Categoría desconocida: #{category}"
    end
  end
end
