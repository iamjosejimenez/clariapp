# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  email_address   :string           not null
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email_address  (email_address) UNIQUE
#
FactoryBot.define do
  factory :user do
    email_address { Faker::Internet.unique.email }
    password { "password1234*" }

    trait :with_external_accounts do
      after(:create) do |user|
        create_list(:external_account, 2, :with_goals, user: user)
      end
    end
  end
end
