# frozen_string_literal: true

require "test_helper"

class GmailSessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Dummy OAuth config so #authorize can build the consent URL without hitting Google.
    ENV["GOOGLE_OAUTH_CLIENT_ID"] = "test-client-id"
    ENV["GOOGLE_OAUTH_CLIENT_SECRET"] = "test-client-secret"
    ENV["GOOGLE_OAUTH_REDIRECT_URI"] = "http://localhost/gmail_sessions/callback"

    @user = create(:user, password: "password1234*")
    post login_path, params: { email_address: @user.email_address, password: "password1234*" }
  end

  teardown do
    ENV.delete("GOOGLE_OAUTH_CLIENT_ID")
    ENV.delete("GOOGLE_OAUTH_CLIENT_SECRET")
    ENV.delete("GOOGLE_OAUTH_REDIRECT_URI")
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

  test "la pantalla en estado error ofrece reconectar, no solo sincronizar" do
    create(:gmail_account, user: @user, status: "error", email: "yo@gmail.com")

    get gmail_sessions_new_path

    assert_response :success
    assert_select "form[action=?]", gmail_sessions_authorize_path
    assert_select "form[action=?]", gmail_sessions_sync_path, count: 0
  end

  test "reconectar una cuenta en error la reactiva y conserva los correos importados" do
    account = create(:gmail_account, user: @user, status: "error", email: "yo@gmail.com")
    create(:bank_email, gmail_account: account, gmail_message_id: "msg-1")

    stub_oauth(email: "yo@gmail.com") do
      get gmail_sessions_callback_path, params: { code: "auth-code", state: oauth_state }
    end

    assert_redirected_to gmail_sessions_new_path
    assert_equal account.id, @user.reload.gmail_account.id
    assert @user.gmail_account.status_active?
    assert_equal 1, @user.gmail_account.bank_emails.where(gmail_message_id: "msg-1").count
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

  # Primes the OAuth state in the session by starting the authorize flow, and
  # returns it so the callback's CSRF check passes.
  def oauth_state
    # GmailSessionsController#authorize stores a random state in the session.
    # Re-create that flow so the callback validates against a matching value.
    get gmail_sessions_new_path # ensure session cookie
    post gmail_sessions_authorize_path
    # The state lives in the session; read it back from the redirect's authorize URL.
    redirect_to_url = response.location
    Rack::Utils.parse_query(URI(redirect_to_url).query)["state"]
  end

  # Stubs the OAuth boundary (token exchange + Gmail profile email lookup) so the
  # callback runs without hitting Google.
  def stub_oauth(email:)
    fake_client = Struct.new(:access_token, :refresh_token, :expires_at).new(
      "new-access-token", "new-refresh-token", 1.hour.from_now
    )
    exchange = GmailSessionsController.instance_method(:exchange_code)
    fetch = GmailSessionsController.instance_method(:fetch_email_address)
    GmailSessionsController.define_method(:exchange_code) { |_code| fake_client }
    GmailSessionsController.define_method(:fetch_email_address) { |_token| email }
    yield
  ensure
    GmailSessionsController.define_method(:exchange_code, exchange)
    GmailSessionsController.define_method(:fetch_email_address, fetch)
  end
end
