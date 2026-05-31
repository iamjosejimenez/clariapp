# frozen_string_literal: true

require "test_helper"

class GmailSessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, password: "password1234*")
    post login_path, params: { email_address: @user.email_address, password: "password1234*" }
  end

  test "sync sin cuenta conectada redirige pidiendo conectar Gmail" do
    post gmail_sessions_sync_path

    assert_redirected_to gmail_sessions_new_path
    assert_equal "Primero conecta tu cuenta de Gmail.", flash[:alert]
  end

  test "sync exitoso redirige a la tabla con aviso de éxito" do
    create(:gmail_account, user: @user)
    stub_sync(result: true) do
      post gmail_sessions_sync_path
    end

    assert_redirected_to bank_emails_path
    assert_equal "Sincronización completada.", flash[:notice]
  end

  test "sync fallido por auth muestra alert y no dice que se completó" do
    create(:gmail_account, user: @user)
    stub_sync(result: false) do
      post gmail_sessions_sync_path
    end

    assert_redirected_to gmail_sessions_new_path
    assert_nil flash[:notice]
    assert_match(/no se pudo sincronizar/i, flash[:alert])
  end

  private

  # Stubs SyncBankEmailsService#call to return the given result for the block.
  def stub_sync(result:)
    original = SyncBankEmailsService.instance_method(:call)
    SyncBankEmailsService.define_method(:call) { result }
    yield
  ensure
    SyncBankEmailsService.define_method(:call, original)
  end
end
