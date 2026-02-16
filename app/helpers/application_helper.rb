# frozen_string_literal: true

module ApplicationHelper
  def clp(amount)
    number_to_currency(amount, unit: "$", precision: 0, delimiter: ".", format: "%u %n")
  end
end
