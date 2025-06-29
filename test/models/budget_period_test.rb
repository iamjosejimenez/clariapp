# == Schema Information
#
# Table name: budget_periods
#
#  id         :bigint           not null, primary key
#  period     :integer
#  total      :decimal(10, 2)   default(0.0), not null
#  year       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  budget_id  :bigint           not null
#
# Indexes
#
#  index_budget_periods_on_budget_id                      (budget_id)
#  index_budget_periods_on_budget_id_and_year_and_period  (budget_id,year,period) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (budget_id => budgets.id)
#

require "test_helper"

class BudgetPeriodTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
