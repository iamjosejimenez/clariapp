# frozen_string_literal: true

class FetchBankEmailsJob < ApplicationJob
  queue_as :default

  def perform
    GmailAccount.status_active.find_each do |gmail_account|
      logger.info "Fetching bank emails for gmail account #{gmail_account.id}"
      SyncBankEmailsService.new(gmail_account).call
    end
  end
end
