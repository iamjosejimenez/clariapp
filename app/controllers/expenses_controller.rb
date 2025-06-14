class ExpensesController < ApplicationController
  before_action :set_budget_and_period

  def index
    @expenses = @budget_period.expenses.order(created_at: :desc)
  end


  def new
    @expense = @budget_period.expenses.build
  end

  def create
    @expense = @budget_period.expenses.build(expense_params)
    if @expense.save
      redirect_to budget_budget_period_expenses_path(@budget, @budget_period), notice: "Gasto creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_budget_and_period
    @budget = current_user.budgets.find(params[:budget_id])
    @budget_period = @budget.budget_periods.find(params[:budget_period_id])
  end

  def expense_params
    params.require(:expense).permit(:description, :amount)
  end
end
