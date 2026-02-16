# frozen_string_literal: true

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
FactoryBot.define do
  factory :budget do
    name { Faker::Lorem.words(number: 3).join(" ") }
    category { "mensual" }
    amount { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
    description { Faker::Lorem.sentence }
    association :user

    trait :with_periods_and_expenses do
      after(:create) do |budget|
        12.times do |index|
          create(
            :budget_period, :with_expenses,
            budget: budget,
            year: Date.today.year,
            period: index + 1,
            total: budget.amount
          )
        end
      end
    end
  end
end
