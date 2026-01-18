# == Schema Information
#
# Table name: expenses
# Database name: primary
#
#  id               :bigint           not null, primary key
#  amount           :decimal(, )
#  description      :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  budget_period_id :bigint           not null
#
# Indexes
#
#  index_expenses_on_budget_period_id  (budget_period_id)
#
# Foreign Keys
#
#  fk_rails_...  (budget_period_id => budget_periods.id)
#

require "test_helper"

class ExpenseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
