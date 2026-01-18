# == Schema Information
#
# Table name: goals
# Database name: primary
#
#  id                  :bigint           not null, primary key
#  deposited           :text             not null
#  external_created_at :string
#  name                :string
#  nav                 :text             not null
#  not_net_deposited   :text             not null
#  profit              :text             not null
#  withdrawn           :text             not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  external_account_id :bigint
#  external_id         :string
#
# Indexes
#
#  index_goals_on_external_account_id  (external_account_id)
#
# Foreign Keys
#
#  fk_rails_...  (external_account_id => external_accounts.id)
#

FactoryBot.define do
  factory :goal do
    deposited { Faker::Number.decimal(l_digits: 4, r_digits: 2).to_s }
    external_created_at { Faker::Time.backward(days: 30).iso8601 }
    name { Faker::Lorem.words(number: 3).join(" ") }
    nav { Faker::Number.decimal(l_digits: 4, r_digits: 2).to_s }
    not_net_deposited { Faker::Number.decimal(l_digits: 3, r_digits: 2).to_s }
    profit { Faker::Number.decimal(l_digits: 3, r_digits: 2).to_s }
    withdrawn { Faker::Number.decimal(l_digits: 3, r_digits: 2).to_s }
    external_id { Faker::Alphanumeric.unique.alphanumeric(number: 10) }

    association :external_account

    trait :with_snapshots do
      after(:create) do |goal|
        create_list(:goal_snapshot, 12, goal: goal)
      end
    end
  end
end
