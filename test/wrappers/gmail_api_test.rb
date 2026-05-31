# frozen_string_literal: true

require "test_helper"

class GmailApiTest < ActiveSupport::TestCase
  # Fake Gmail service whose live calls raise a 401 the way the real client does
  # when the token is rejected (e.g. access revoked before token_expires_at).
  class UnauthorizedGmailService
    attr_accessor :authorization

    def list_user_messages(*)
      raise Google::Apis::AuthorizationError, "Unauthorized"
    end

    def get_user_message(*)
      raise Google::Apis::AuthorizationError, "Unauthorized"
    end
  end

  def build_api(gmail_account)
    api = GmailApi.new(gmail_account)
    # Inject a service whose live API calls raise a 401, bypassing real auth.
    api.instance_variable_set(:@service, UnauthorizedGmailService.new)
    api
  end

  test "traduce un 401 de list_user_messages a AuthError y marca la cuenta en error" do
    account = create(:gmail_account, status: "active", token_expires_at: 1.hour.from_now)
    api = build_api(account)

    assert_raises(GmailApi::AuthError) do
      api.fetch_bank_message_ids
    end
    assert account.reload.status_error?
  end

  test "traduce un 401 de get_user_message a AuthError y marca la cuenta en error" do
    account = create(:gmail_account, status: "active", token_expires_at: 1.hour.from_now)
    api = build_api(account)

    assert_raises(GmailApi::AuthError) do
      api.fetch_message("msg-1")
    end
    assert account.reload.status_error?
  end
end
