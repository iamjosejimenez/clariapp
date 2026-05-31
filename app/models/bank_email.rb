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
#  index_bank_emails_on_gmail_account_id                       (gmail_account_id)
#  index_bank_emails_on_gmail_account_id_and_gmail_message_id  (gmail_account_id,gmail_message_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (gmail_account_id => gmail_accounts.id)
#
class BankEmail < ApplicationRecord
  belongs_to :gmail_account

  validates :gmail_message_id, presence: true, uniqueness: { scope: :gmail_account_id }

  scope :unprocessed, -> { where(processed_at: nil) }
end
