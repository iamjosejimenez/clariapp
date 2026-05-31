# frozen_string_literal: true

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
