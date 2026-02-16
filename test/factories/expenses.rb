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
FactoryBot.define do
  factory :expense do
    description { Faker::Lorem.sentence }
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    association :budget_period
  end
end
