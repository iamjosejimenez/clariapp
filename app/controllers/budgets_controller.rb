class BudgetsController < ApplicationController
  include Pagy::Backend

  before_action :set_budget, only: [ :show ]

  def index
    @budgets = current_user.budgets.includes(:budget_periods)
    @pagy, @budgets = pagy(@budgets)
  end

  def show
  end

  def new
    @budget = current_user.budgets.build
  end

  def create
    @budget = current_user.budgets.build(budget_params)
    if @budget.save
      redirect_to @budget, notice: "Presupuesto creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_budget
    @budget = current_user.budgets.find(params[:id])
  end

  def budget_params
    params.require(:budget).permit(:name, :category, :description, :amount)
  end
end
