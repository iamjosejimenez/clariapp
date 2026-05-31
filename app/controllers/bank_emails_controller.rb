# frozen_string_literal: true

class BankEmailsController < ApplicationController
  def index
    @bank_emails = current_user.bank_emails.order(received_at: :desc)
  end
end
