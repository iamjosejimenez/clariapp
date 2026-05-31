# frozen_string_literal: true

class ExpensesController < ApplicationController
  before_action :set_budget_and_period, only: [ :index, :new, :create ]
  before_action :set_expense, only: [ :edit, :update, :destroy ]

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

  def edit
    @budget = @expense.budget_period.budget
    @budget_period = @expense.budget_period
  end

  def update
    if @expense.update(expense_params)
      redirect_to budget_budget_period_expenses_path(@expense.budget_period.budget, @expense.budget_period), notice: "Gasto actualizado exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @expense.budget_period.current?
      @expense.destroy
      redirect_to budget_budget_period_expenses_path(@expense.budget_period.budget, @expense.budget_period), notice: "Gasto eliminado exitosamente."
    else
      redirect_to budget_budget_period_expenses_path(@expense.budget_period.budget, @expense.budget_period), alert: "Solo se pueden eliminar gastos del periodo actual."
    end
  end

  private

  def set_budget_and_period
    @budget = current_user.budgets.find(params[:budget_id])
    @budget_period = @budget.budget_periods.find(params[:budget_period_id])
  end

  def set_expense
    @expense = current_user.expenses.find(params[:id])
  end

  def expense_params
    params.require(:expense).permit(:description, :amount)
  end
end
