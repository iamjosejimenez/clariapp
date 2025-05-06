# == Schema Information
#
# Table name: goal_snapshots
#
#  id                          :integer          not null, primary key
#  goal_id                     :integer          not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  nav_encrypted               :text
#  profit_encrypted            :text
#  not_net_deposited_encrypted :text
#  deposited_encrypted         :text
#  withdrawn_encrypted         :text
#
# Indexes
#
#  index_goal_snapshots_on_goal_id  (goal_id)
#

require "test_helper"

class GoalSnapshotTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
