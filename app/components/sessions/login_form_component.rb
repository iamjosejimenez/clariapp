# frozen_string_literal: true

class Sessions::LoginFormComponent < ViewComponent::Base
  def initialize(email_address: "", error: nil)
    @email_address = email_address
    @error = error
  end
end
