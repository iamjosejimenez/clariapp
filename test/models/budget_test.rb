# == Schema Information
#
# Table name: budgets
#
#  id          :integer          not null, primary key
#  name        :string
#  category    :string
#  description :text
#  amount      :decimal(10, 2)
#  user_id     :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_budgets_on_user_id  (user_id)
#

require "test_helper"

class BudgetTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
