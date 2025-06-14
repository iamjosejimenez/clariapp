# == Schema Information
#
# Table name: budget_periods
#
#  id         :integer          not null, primary key
#  budget_id  :integer          not null
#  year       :integer
#  period     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_budget_periods_on_budget_id                      (budget_id)
#  index_budget_periods_on_budget_id_and_year_and_period  (budget_id,year,period) UNIQUE
#

require "test_helper"

class BudgetPeriodTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
