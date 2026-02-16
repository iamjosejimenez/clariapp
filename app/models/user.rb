# frozen_string_literal: true

# == Schema Information
#
# Table name: users
# Database name: primary
#
#  id              :integer          not null, primary key
#  email_address   :string           not null
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email_address  (email_address) UNIQUE
#

class User < ApplicationRecord
  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :budgets, dependent: :destroy
  has_many :external_accounts, dependent: :destroy
  has_many :expenses, through: :budgets
  has_many :goals, through: :external_accounts

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def fintual_user
    @fintual_user ||= external_accounts.find_by(provider: "fintual")
  end

  def tests_user
    @tests_user ||= external_accounts.find_by(provider: "tests")
  end
end
