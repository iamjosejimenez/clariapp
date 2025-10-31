FactoryBot.define do
  factory :user do
    email_address { Faker::Internet.unique.email }
    password { "password1234*" }
  end
end
