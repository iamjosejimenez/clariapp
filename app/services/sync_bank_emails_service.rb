# frozen_string_literal: true

# Imports BCI notification emails for a connected GmailAccount, storing them raw.
#
# Mirrors SyncGoalsService: constructed with the account, fetches via the API
# wrapper, and upserts records idempotently. Parsing/expense creation is out of
# scope for this iteration — emails are persisted raw for later processing.
class SyncBankEmailsService
  def initialize(gmail_account, api: GmailApi.new(gmail_account))
    @gmail_account = gmail_account
    @api = api
  end

  def call
    api.fetch_bank_message_ids.each do |message_id|
      next if already_imported?(message_id)

      data = api.fetch_message(message_id)
      gmail_account.bank_emails.create!(data.merge(bank: "bci"))
    end
  rescue GmailApi::AuthError => e
    Rails.logger.warn("SyncBankEmailsService skipped account #{gmail_account.id}: #{e.message}")
  end

  private

  attr_reader :gmail_account, :api

  def already_imported?(message_id)
    BankEmail.exists?(gmail_message_id: message_id)
  end
end
