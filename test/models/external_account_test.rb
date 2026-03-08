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
#  index_external_accounts_on_user_id_and_provider   (user_id,provider) UNIQUE
#  index_external_accounts_on_username_and_provider  (username,provider) UNIQUE
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
require "test_helper"

class ExternalAccountTest < ActiveSupport::TestCase
  test "no permite mas de una cuenta del mismo provider por usuario" do
    user = create(:user)
    create(:external_account, user:, provider: "fintual")

    duplicate = build(:external_account, user:, provider: "fintual")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:provider], "ya esta vinculado para este usuario"
  end

  test "no permite reutilizar el mismo username provider en otro usuario" do
    create(:external_account, provider: "fintual", username: "fintual@example.com")

    duplicate = build(:external_account, provider: "fintual", username: "fintual@example.com")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:username], "ya esta vinculado a otro usuario"
  end
end
