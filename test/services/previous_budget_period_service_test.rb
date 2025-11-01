# frozen_string_literal: true

require "test_helper"

class PreviousBudgetPeriodServiceTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @budget = create(:budget, user: @user, category: "mensual")
    @quincenal_budget = create(:budget, user: @user, category: "quincenal")
    @semanal_budget = create(:budget, user: @user, category: "semanal")
  end

  test "for mensual budget, returns previous period when period is greater than 1" do
    previous_period = create(:budget_period, budget: @budget, year: 2024, period: 5, total: 1000.0)
    current_period = create(:budget_period, budget: @budget, year: 2024, period: 6, total: 1200.0)

    result = PreviousBudgetPeriodService.new(current_period).call

    assert_equal previous_period.id, result.id
    assert_equal 5, result.period
    assert_equal 2024, result.year
  end

  test "for mensual budget, returns nil when no previous period exists in same year" do
    current_period = create(:budget_period, budget: @budget, year: 2024, period: 1, total: 1000.0)

    result = PreviousBudgetPeriodService.new(current_period).call

    assert_nil result
  end

  test "for mensual budget, returns last period of previous year when period is 1" do
    last_period_2023 = create(:budget_period, budget: @budget, year: 2023, period: 12, total: 1500.0)
    first_period_2024 = create(:budget_period, budget: @budget, year: 2024, period: 1, total: 1000.0)

    result = PreviousBudgetPeriodService.new(first_period_2024).call

    assert_equal last_period_2023.id, result.id
    assert_equal 12, result.period
    assert_equal 2023, result.year
  end

  test "for mensual budget, returns last period of previous year when period is 1 and multiple periods exist" do
    create(:budget_period, budget: @budget, year: 2023, period: 10, total: 1000.0)
    create(:budget_period, budget: @budget, year: 2023, period: 11, total: 1100.0)
    last_period_2023 = create(:budget_period, budget: @budget, year: 2023, period: 12, total: 1500.0)
    first_period_2024 = create(:budget_period, budget: @budget, year: 2024, period: 1, total: 1000.0)

    result = PreviousBudgetPeriodService.new(first_period_2024).call

    assert_equal last_period_2023.id, result.id
    assert_equal 12, result.period
    assert_equal 2023, result.year
  end

  test "for mensual budget, returns nil when period is 1 and no previous year exists" do
    first_period_2024 = create(:budget_period, budget: @budget, year: 2024, period: 1, total: 1000.0)

    result = PreviousBudgetPeriodService.new(first_period_2024).call

    assert_nil result
  end

  test "for mensual budget, returns correct period when multiple periods exist with gaps" do
    create(:budget_period, budget: @budget, year: 2024, period: 2, total: 1000.0)
    previous_period = create(:budget_period, budget: @budget, year: 2024, period: 5, total: 1200.0)
    current_period = create(:budget_period, budget: @budget, year: 2024, period: 6, total: 1500.0)

    result = PreviousBudgetPeriodService.new(current_period).call

    assert_equal previous_period.id, result.id
    assert_equal 5, result.period
  end

  test "for quincenal budget, returns previous period when period is greater than 1" do
    previous_period = create(:budget_period, budget: @quincenal_budget, year: 2024, period: 3, total: 1000.0)
    current_period = create(:budget_period, budget: @quincenal_budget, year: 2024, period: 4, total: 1200.0)

    result = PreviousBudgetPeriodService.new(current_period).call

    assert_equal previous_period.id, result.id
    assert_equal 3, result.period
    assert_equal 2024, result.year
  end

  test "for quincenal budget, returns nil when period is 1 and no previous year exists" do
    first_period = create(:budget_period, budget: @quincenal_budget, year: 2024, period: 1, total: 1000.0)

    result = PreviousBudgetPeriodService.new(first_period).call

    assert_nil result
  end

  test "for quincenal budget, does not return periods from other budgets" do
    other_budget = create(:budget, user: @user, category: "mensual")
    create(:budget_period, budget: other_budget, year: 2024, period: 5, total: 1000.0)
    current_period = create(:budget_period, budget: @quincenal_budget, year: 2024, period: 6, total: 1200.0)

    result = PreviousBudgetPeriodService.new(current_period).call

    assert_nil result
  end

  test "for semanal budget, returns previous period when period is greater than 1" do
    previous_period = create(:budget_period, budget: @semanal_budget, year: 2024, period: 3, total: 1000.0)
    current_period = create(:budget_period, budget: @semanal_budget, year: 2024, period: 4, total: 1200.0)

    result = PreviousBudgetPeriodService.new(current_period).call

    assert_equal previous_period.id, result.id
    assert_equal 3, result.period
    assert_equal 2024, result.year
  end

  test "for semanal budget, returns nil when period is 1 and no previous year exists" do
    first_period = create(:budget_period, budget: @semanal_budget, year: 2024, period: 1, total: 1000.0)

    result = PreviousBudgetPeriodService.new(first_period).call

    assert_nil result
  end
end
