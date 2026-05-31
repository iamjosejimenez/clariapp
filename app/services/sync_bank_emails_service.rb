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

  # Returns true on success, false when the account's Gmail authorization failed
  # (token revoked/expired). The failure is swallowed so the hourly job keeps
  # going with other accounts, but the boolean lets callers (e.g. the manual
  # sync action) surface the error to the user.
  def call
    api.fetch_bank_message_ids.each do |message_id|
      # Cheap pre-check to skip the extra fetch_message API call in the common
      # case. The actual insert is still made idempotent below to cover the race
      # where the hourly job and a manual sync both pass this check at once.
      next if already_imported?(message_id)

      data = api.fetch_message(message_id)
      import_message(message_id, data)
    end
    true
  rescue GmailApi::AuthError => e
    Rails.logger.warn("SyncBankEmailsService skipped account #{gmail_account.id}: #{e.message}")
    false
  end

  private

  attr_reader :gmail_account, :api

  def already_imported?(message_id)
    gmail_account.bank_emails.exists?(gmail_message_id: message_id)
  end

  # Idempotent insert keyed on gmail_message_id. Tolerates the race where the
  # hourly job and a manual sync both pass already_imported? and try to insert
  # the same message: the loser hits either the model's uniqueness validation
  # (RecordInvalid) or, if it slips past, the unique index (RecordNotUnique).
  # Both mean "already imported", so we swallow them instead of aborting the run.
  def import_message(message_id, data)
    gmail_account.bank_emails.create!(data.merge(gmail_message_id: message_id, bank: "bci"))
  rescue ActiveRecord::RecordNotUnique
    nil
  rescue ActiveRecord::RecordInvalid => e
    raise unless e.record.errors.of_kind?(:gmail_message_id, :taken)
  end
end
