# == Schema Information
#
# Table name: budgets
# Database name: primary
#
#  id          :bigint           not null, primary key
#  amount      :decimal(10, 2)
#  category    :string
#  description :text
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_budgets_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

require "test_helper"

class BudgetTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
