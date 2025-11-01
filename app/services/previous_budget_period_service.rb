# frozen_string_literal: true

class PreviousBudgetPeriodService
  def initialize(budget_period)
    @budget_period = budget_period
    @budget = budget_period.budget
  end

  def call
    previous_year = budget_period.year
    previous_period_number = budget_period.period - 1

    if previous_period_number < 1
      previous_year -= 1
      find_last_period_of_year(previous_year)
    else
      find_period_by_year_and_period(previous_year, previous_period_number)
    end
  end

  private

  attr_reader :budget_period, :budget

  def find_last_period_of_year(year)
    budget.budget_periods
          .where(year: year)
          .order(period: :desc)
          .limit(1)
          .take
  end

  def find_period_by_year_and_period(year, period)
    budget.budget_periods.find_by(year: year, period: period)
  end
end
