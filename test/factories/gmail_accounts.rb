# frozen_string_literal: true

# == Schema Information
#
# Table name: gmail_accounts
#
#  id               :bigint           not null, primary key
#  access_token     :text
#  email            :string           not null
#  refresh_token    :text
#  status           :string           default("active"), not null
#  token_expires_at :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  last_history_id  :string
#  user_id          :bigint           not null
#
# Indexes
#
#  index_gmail_accounts_on_email    (email) UNIQUE
#  index_gmail_accounts_on_user_id  (user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :gmail_account do
    association :user
    email { Faker::Internet.unique.email }
    refresh_token { Faker::Alphanumeric.alphanumeric(number: 40) }
    access_token { Faker::Alphanumeric.alphanumeric(number: 40) }
    token_expires_at { 1.hour.from_now }
    status { "active" }
  end
end
