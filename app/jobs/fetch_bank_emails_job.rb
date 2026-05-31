# frozen_string_literal: true

class FetchBankEmailsJob < ApplicationJob
  queue_as :default

  def perform
    GmailAccount.status_active.find_each do |gmail_account|
      logger.info "Enqueuing bank email sync for gmail account #{gmail_account.id}"
      SyncBankEmailsJob.perform_later(gmail_account)
    end
  end
end
