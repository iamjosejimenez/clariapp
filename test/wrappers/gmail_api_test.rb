# frozen_string_literal: true

require "test_helper"
require "base64"

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

  # Fake service returning a single prebuilt message, regardless of arguments.
  class StubGmailService
    attr_accessor :authorization

    def initialize(message)
      @message = message
    end

    def get_user_message(*)
      @message
    end
  end

  def build_api(gmail_account, service: UnauthorizedGmailService.new)
    api = GmailApi.new(gmail_account)
    # Inject the service directly, bypassing real auth/token refresh.
    api.instance_variable_set(:@service, service)
    api
  end

  # Builds a Gmail message via from_json so #data is base64url-decoded exactly
  # like a real API response (raw bytes tagged ASCII-8BIT).
  def message_with_html_body(html, mime_type: "text/html")
    json = {
      "id" => "msg-1",
      "internalDate" => "1700000000000",
      "payload" => {
        "mimeType" => mime_type,
        "headers" => [
          { "name" => "From", "value" => "contacto@bci.cl" },
          { "name" => "Subject", "value" => "Aviso de cargo" }
        ],
        "body" => { "data" => Base64.urlsafe_encode64(html), "size" => html.bytesize }
      }
    }.to_json
    Google::Apis::GmailV1::Message.from_json(json)
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

  test "fetch_message devuelve el HTML decodificado en UTF-8, no el base64" do
    account = create(:gmail_account, token_expires_at: 1.hour.from_now)
    html = "<html><body>Compra por $10.000 áéí</body></html>"
    api = build_api(account, service: StubGmailService.new(message_with_html_body(html)))

    data = api.fetch_message("msg-1")

    assert_equal html, data[:raw_body]
    assert_equal Encoding::UTF_8, data[:raw_body].encoding
    assert data[:raw_body].valid_encoding?
    assert_equal "contacto@bci.cl", data[:from_address]
  end
end
