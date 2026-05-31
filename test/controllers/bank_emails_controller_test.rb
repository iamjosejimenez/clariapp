# frozen_string_literal: true

require "test_helper"

class BankEmailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, password: "password1234*")
    post login_path, params: { email_address: @user.email_address, password: "password1234*" }
  end

  test "lista los correos del usuario autenticado" do
    account = create(:gmail_account, user: @user)
    create(:bank_email, gmail_account: account, subject: "Compra Falabella")

    get bank_emails_path

    assert_response :success
    assert_select "td", text: /Compra Falabella/
  end

  test "muestra estado vacío cuando no hay correos" do
    get bank_emails_path

    assert_response :success
    assert_match "Aún no hay correos importados", response.body
  end
end
