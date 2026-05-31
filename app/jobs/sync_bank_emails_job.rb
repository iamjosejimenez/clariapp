# frozen_string_literal: true

# Syncs one connected GmailAccount's bank emails in the background, updating
# sync_status so the UI can reflect progress (via the model's Turbo broadcast).
#
# Used both by the manual "Sincronizar ahora" action and by FetchBankEmailsJob,
# which enqueues one of these per active account on its hourly schedule.
class SyncBankEmailsJob < ApplicationJob
  queue_as :default

  def perform(gmail_account)
    gmail_account.update!(sync_status: "syncing")

    if SyncBankEmailsService.new(gmail_account).call
      gmail_account.update!(sync_status: "synced", last_synced_at: Time.current)
    else
      # call returned false → auth expired/revoked; the API wrapper already set
      # status: "error". Surface it on the sync axis too.
      gmail_account.update!(sync_status: "failed")
    end
  rescue StandardError
    gmail_account.update!(sync_status: "failed")
    raise
  end
end
