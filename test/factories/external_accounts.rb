# == Schema Information
#
# Table name: external_accounts
# Database name: primary
#
#  id           :bigint           not null, primary key
#  access_token :string
#  provider     :string
#  status       :string
#  username     :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_external_accounts_on_user_id                (user_id)
#  index_external_accounts_on_username_and_provider  (username,provider) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :external_account do
    provider { "tests" }
    access_token { Faker::Alphanumeric.alphanumeric(number: 20) }
    status { "active" }
    username { Faker::Internet.unique.username }

    association :user

    trait :with_goals do
      after(:create) do |external_account|
        create_list(:goal, 3, :with_snapshots, external_account: external_account)
      end
    end
  end
end
