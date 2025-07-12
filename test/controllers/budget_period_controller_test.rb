require "test_helper"

class BudgetPeriodControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get budget_period_index_url
    assert_response :success
  end
end
