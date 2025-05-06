# == Schema Information
#
# Table name: goals
#
#  id                  :integer          not null, primary key
#  external_id         :string
#  name                :string
#  updated_at          :datetime         not null
#  user_id             :integer          not null
#  created_at          :datetime         not null
#  external_created_at :string
#  nav                 :text
#  profit              :text
#  not_net_deposited   :text
#  deposited           :text
#  withdrawn           :text
#
# Indexes
#
#  index_goals_on_user_id  (user_id)
#

require "test_helper"

class GoalTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
