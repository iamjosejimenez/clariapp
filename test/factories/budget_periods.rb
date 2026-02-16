# frozen_string_literal: true

# == Schema Information
#
# Table name: budget_periods
# Database name: primary
#
#  id         :integer          not null, primary key
#  period     :integer
#  total      :decimal(10, 2)   default(0.0), not null
#  year       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  budget_id  :integer          not null
#
# Indexes
#
#  index_budget_periods_on_budget_id                      (budget_id)
#  index_budget_periods_on_budget_id_and_year_and_period  (budget_id,year,period) UNIQUE
#
# Foreign Keys
#
#  budget_id  (budget_id => budgets.id)
#
FactoryBot.define do
  factory :budget_period do
    year { Date.today.year }
    period { Date.today.month }
    total { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
    association :budget

    trait :with_expenses do
      after(:create) do |budget_period|
        create_list(:expense, 5, budget_period: budget_period)
      end
    end
  end
end
