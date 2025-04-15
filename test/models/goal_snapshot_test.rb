# == Schema Information
#
# Table name: goal_snapshots
#
#  id                :integer          not null, primary key
#  goal_id           :integer          not null
#  nav               :float
#  profit            :float
#  not_net_deposited :float
#  deposited         :float
#  withdrawn         :float
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
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
