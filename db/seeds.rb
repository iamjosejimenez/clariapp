# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

user = User.find_or_create_by!(email_address: "admin@clariapp.com") do |u|
  u.password = "password1234*"
end

if ExternalAccount.where(user: user).none?
  external_account = FactoryBot.create(:external_account, user: user)
  FactoryBot.create_list(:goal, 3, :with_snapshots, external_account: external_account)
end

puts "Seeded user: #{user.email_address} (password: password1234*)"
