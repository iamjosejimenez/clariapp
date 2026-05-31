# frozen_string_literal: true

require "test_helper"

class SyncBankEmailsServiceTest < ActiveSupport::TestCase
  # Stubs GmailApi: returns a fixed set of message ids and a payload per id.
  class FakeGmailApi
    def initialize(messages)
      @messages = messages
    end

    def fetch_bank_message_ids(bank: "bci")
      @messages.keys
    end

    def fetch_message(message_id)
      @messages.fetch(message_id)
    end
  end

  def message_payload(id)
    {
      gmail_message_id: id,
      from_address: "notificaciones@bci.cl",
      subject: "Aviso de cargo",
      received_at: Time.current,
      snippet: "Compra por $10.000",
      raw_body: "<html>Compra por $10.000</html>"
    }
  end

  test "importa correos nuevos y persiste los campos crudos" do
    account = create(:gmail_account)
    api = FakeGmailApi.new("msg-1" => message_payload("msg-1"), "msg-2" => message_payload("msg-2"))

    assert_difference -> { account.bank_emails.count }, 2 do
      SyncBankEmailsService.new(account, api: api).call
    end

    email = account.bank_emails.find_by(gmail_message_id: "msg-1")
    assert_equal "bci", email.bank
    assert_equal "notificaciones@bci.cl", email.from_address
    assert_includes email.raw_body, "Compra"
  end

  test "es idempotente: una segunda corrida no duplica correos" do
    account = create(:gmail_account)
    api = FakeGmailApi.new("msg-1" => message_payload("msg-1"))

    SyncBankEmailsService.new(account, api: api).call
    assert_no_difference -> { BankEmail.count } do
      SyncBankEmailsService.new(account, api: api).call
    end
  end

  test "no duplica un message_id ya importado por otra cuenta" do
    create(:bank_email, gmail_message_id: "msg-1")
    account = create(:gmail_account)
    api = FakeGmailApi.new("msg-1" => message_payload("msg-1"))

    assert_no_difference -> { BankEmail.count } do
      SyncBankEmailsService.new(account, api: api).call
    end
  end
end
