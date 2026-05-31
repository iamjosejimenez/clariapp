# frozen_string_literal: true

require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "emite la cookie de sesion como secure en requests https" do
    user = create(:user, password: "password1234*")

    https!
    post login_path, params: {
      email_address: user.email_address,
      password: "password1234*"
    }

    assert_redirected_to root_url(protocol: "https")

    session_cookie = Array(response.headers["Set-Cookie"]).find { |cookie| cookie.start_with?("session_id=") }

    assert_not_nil session_cookie
    assert_includes session_cookie, "secure"
    assert_includes session_cookie, "httponly"
    assert_includes session_cookie, "samesite=lax"
  end
end
