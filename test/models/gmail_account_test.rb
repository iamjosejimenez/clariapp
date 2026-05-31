# frozen_string_literal: true

# == Schema Information
#
# Table name: gmail_accounts
#
#  id               :bigint           not null, primary key
#  access_token     :text
#  email            :string           not null
#  last_synced_at   :datetime
#  refresh_token    :text
#  status           :string           default("active"), not null
#  sync_status      :string           default("idle"), not null
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
require "test_helper"

class GmailAccountTest < ActiveSupport::TestCase
  test "requiere email" do
    account = build(:gmail_account, email: nil)
    assert_not account.valid?
    assert account.errors.of_kind?(:email, :blank)
  end

  test "una casilla de Gmail no puede vincularse a dos usuarios" do
    existing = create(:gmail_account)
    duplicate = build(:gmail_account, email: existing.email)

    assert_not duplicate.valid?
    assert account_email_taken?(duplicate)
  end

  test "token_expired? es true cuando no hay expiración" do
    account = build(:gmail_account, token_expires_at: nil)
    assert account.token_expired?
  end

  test "token_expired? es true cuando ya pasó la expiración" do
    account = build(:gmail_account, token_expires_at: 1.minute.ago)
    assert account.token_expired?
  end

  test "token_expired? es false cuando aún no expira" do
    account = build(:gmail_account, token_expires_at: 1.hour.from_now)
    assert_not account.token_expired?
  end

  private

  def account_email_taken?(account)
    account.errors.of_kind?(:email, :taken)
  end
end
