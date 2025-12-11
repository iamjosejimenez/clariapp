class BudgetPeriodsController < ApplicationController
  before_action :set_budget


  def index
    @budget_periods = @budget.budget_periods.order(year: :desc, period: :desc)
  end

  private

    def set_budget
      @budget = current_user.budgets.find(params[:budget_id])
    end
end
