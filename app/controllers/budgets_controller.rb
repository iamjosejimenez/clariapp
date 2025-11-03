class BudgetsController < ApplicationController
  include Pagy::Method

  before_action :set_budget, only: [ :show ]

  def index
    @budgets = current_user.budgets.includes(:budget_periods).order(created_at: :desc)
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
      redirect_to budgets_path, notice: "Presupuesto creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @budget = current_user.budgets.find(params[:id])
    if @budget.destroy
      redirect_to budgets_path, notice: "Presupuesto eliminado exitosamente."
    else
      redirect_to budgets_path, notice: "Error al eliminar el presupuesto."
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
