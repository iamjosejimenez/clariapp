# frozen_string_literal: true

class Expenses::ExpenseFormComponent < ViewComponent::Base
  include SimpleForm::ActionViewExtensions::FormHelper

  def initialize(budget:, budget_period:, expense:)
    @budget = budget
    @budget_period = budget_period
    @expense = expense
  end
end
