class BudgetPeriodsController < ApplicationController
  include Pagy::Method

  before_action :set_budget


  def index
    @budget_periods = @budget.budget_periods.order(year: :desc, period: :desc)
    @pagy, @periods = pagy(@budget_periods)
  end

  private

    def set_budget
      @budget = current_user.budgets.find(params[:budget_id])
    end
end
