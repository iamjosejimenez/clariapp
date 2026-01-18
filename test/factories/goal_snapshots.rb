# == Schema Information
#
# Table name: goal_snapshots
# Database name: primary
#
#  id                :integer          not null, primary key
#  deposited         :text             not null
#  extraction_date   :date
#  nav               :text             not null
#  not_net_deposited :text             not null
#  profit            :text             not null
#  withdrawn         :text             not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  goal_id           :integer          not null
#
# Indexes
#
#  index_goal_snapshots_on_goal_id  (goal_id)
#
# Foreign Keys
#
#  goal_id  (goal_id => goals.id)
#
FactoryBot.define do
  factory :goal_snapshot do
    deposited { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
    extraction_date { Faker::Date.backward(days: 10) }
    nav { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
    not_net_deposited { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    profit { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    withdrawn { Faker::Number.decimal(l_digits: 3, r_digits: 2) }

    association :goal
  end
end
