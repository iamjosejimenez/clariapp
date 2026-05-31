# frozen_string_literal: true

class BankEmailDetailComponent < ApplicationComponent
  def initialize(bank_email:)
    @bank_email = bank_email
  end
end
