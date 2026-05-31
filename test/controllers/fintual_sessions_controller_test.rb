# frozen_string_literal: true

require "test_helper"

class FintualSessionsControllerTest < ActionDispatch::IntegrationTest
  FakeHttpResponse = Struct.new(:code, :body)

  test "rechaza vincular una cuenta de fintual ya asociada a otro usuario" do
    current_user = create(:user, password: "password1234*")
    other_user = create(:user)
    create(
      :external_account,
      user: other_user,
      provider: "fintual",
      username: "fintual@example.com"
    )

    post login_path, params: {
      email_address: current_user.email_address,
      password: "password1234*"
    }

    response_body = {
      data: {
        attributes: {
          token: "token-seguro"
        }
      }
    }.to_json

    original_post = HTTParty.method(:post)
    HTTParty.singleton_class.send(:define_method, :post) do |*_args, **_kwargs|
      FakeHttpResponse.new(201, response_body)
    end

    post fintual_sessions_create_path, params: {
      email: "fintual@example.com",
      password: "secreto"
    }

    assert_redirected_to fintual_sessions_new_path
    assert_equal "La cuenta de Fintual ya está vinculada a otro usuario.", flash[:alert]
    assert_nil current_user.external_accounts.find_by(provider: "fintual")
  ensure
    HTTParty.singleton_class.send(:define_method, :post) do |*args, **kwargs, &block|
      original_post.call(*args, **kwargs, &block)
    end
  end
end
