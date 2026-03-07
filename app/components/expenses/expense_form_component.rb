# frozen_string_literal: true

class Expenses::ExpenseFormComponent < ApplicationComponent
  include SimpleForm::ActionViewExtensions::FormHelper

  def initialize(budget:, budget_period:, expense:)
    @budget = budget
    @budget_period = budget_period
    @expense = expense
  end
end
