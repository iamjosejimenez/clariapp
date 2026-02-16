# frozen_string_literal: true

# == Schema Information
#
# Table name: external_accounts
# Database name: primary
#
#  id           :integer          not null, primary key
#  access_token :string
#  provider     :string
#  status       :string
#  username     :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :integer          not null
#
# Indexes
#
#  index_external_accounts_on_user_id                (user_id)
#  index_external_accounts_on_username_and_provider  (username,provider) UNIQUE
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
require "test_helper"

class ExternalAccountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
