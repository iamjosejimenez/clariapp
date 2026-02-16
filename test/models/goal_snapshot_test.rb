# frozen_string_literal: true

# == Schema Information
#
# Table name: goal_snapshots
# Database name: primary
#
#  id                :integer          not null, primary key
#  deposited         :text             not null
#  extraction_date   :date             not null
#  nav               :text             not null
#  not_net_deposited :text             not null
#  profit            :text             not null
#  withdrawn         :text             not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  goal_id           :integer          not null
#
# Indexes
#
#  index_goal_snapshots_on_goal_id  (goal_id)
#
# Foreign Keys
#
#  goal_id  (goal_id => goals.id)
#

require "test_helper"

class GoalSnapshotTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
