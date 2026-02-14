# == Schema Information
#
# Table name: budgets
# Database name: primary
#
#  id          :integer          not null, primary key
#  amount      :decimal(10, 2)
#  category    :string
#  description :text
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :integer          not null
#
# Indexes
#
#  index_budgets_on_user_id  (user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#

require "test_helper"

class BudgetTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  setup do
    @user = create(:user)
  end

  test "current_year uses calendar year for mensual" do
    budget = create(:budget, user: @user, category: "mensual")
    date = Date.new(2021, 1, 1)

    assert_equal 2021, budget.current_year(date)
  end

  test "current_year uses calendar year for quincenal" do
    budget = create(:budget, user: @user, category: "quincenal")
    date = Date.new(2021, 1, 1)

    assert_equal 2021, budget.current_year(date)
  end

  test "current_year uses iso week-year for semanal" do
    budget = create(:budget, user: @user, category: "semanal")
    date = Date.new(2021, 1, 1)

    assert_equal 2020, budget.current_year(date)
  end

  test "current_period creates weekly period using iso week-year and cweek on january boundary" do
    budget = create(:budget, user: @user, category: "semanal", amount: 1000)

    travel_to Date.new(2021, 1, 1) do
      period = budget.current_period

      assert_equal 2020, period.year
      assert_equal 53, period.period
      assert_equal budget.id, period.budget_id
    end
  end

  test "current_period uses previous period remaining balance when carrying over" do
    budget = create(:budget, user: @user, category: "semanal", amount: 1000)
    create(:budget_period, budget: budget, year: 2020, period: 52, total: 800)
    create(:expense, budget_period: budget.budget_periods.find_by(year: 2020, period: 52), amount: 300)

    travel_to Date.new(2021, 1, 1) do
      period = budget.current_period

      # previous remaining is 800 - 300 = 500, so carried total should be 1500
      assert_equal BigDecimal("1500.0"), period.total
    end
  end
end
