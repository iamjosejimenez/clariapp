# frozen_string_literal: true

# == Schema Information
#
# Table name: bank_emails
#
#  id               :bigint           not null, primary key
#  bank             :string           default("bci"), not null
#  from_address     :string
#  processed_at     :datetime
#  raw_body         :text
#  received_at      :datetime
#  snippet          :string
#  subject          :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  gmail_account_id :bigint           not null
#  gmail_message_id :string           not null
#
# Indexes
#
#  index_bank_emails_on_gmail_account_id  (gmail_account_id)
#  index_bank_emails_on_gmail_message_id  (gmail_message_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (gmail_account_id => gmail_accounts.id)
#
require "test_helper"

class BankEmailTest < ActiveSupport::TestCase
  test "requiere gmail_message_id" do
    bank_email = build(:bank_email, gmail_message_id: nil)
    assert_not bank_email.valid?
    assert bank_email.errors.of_kind?(:gmail_message_id, :blank)
  end

  test "gmail_message_id es único" do
    existing = create(:bank_email)
    duplicate = build(:bank_email, gmail_message_id: existing.gmail_message_id)
    assert_not duplicate.valid?
    assert duplicate.errors.of_kind?(:gmail_message_id, :taken)
  end

  test "scope unprocessed solo devuelve correos sin procesar" do
    unprocessed = create(:bank_email, processed_at: nil)
    create(:bank_email, processed_at: Time.current)

    assert_equal [ unprocessed ], BankEmail.unprocessed.to_a
  end
end
