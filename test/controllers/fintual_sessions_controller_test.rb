require "test_helper"

class FintualSessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get fintual_sessions_new_url
    assert_response :success
  end

  test "should get create" do
    get fintual_sessions_create_url
    assert_response :success
  end

  test "should get destroy" do
    get fintual_sessions_destroy_url
    assert_response :success
  end
end
