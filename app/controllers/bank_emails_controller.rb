# frozen_string_literal: true

class BankEmailsController < ApplicationController
  def index
    @bank_emails = current_user.bank_emails.order(received_at: :desc)
  end

  def detail
    @bank_email = current_user.bank_emails.find(params[:id])

    render turbo_stream: turbo_stream.update(
      "modal-content",
      partial: "bank_emails/email_detail",
      locals: { bank_email: @bank_email }
    )
  end
end
