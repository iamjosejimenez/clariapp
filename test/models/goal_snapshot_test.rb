# == Schema Information
#
# Table name: goal_snapshots
# Database name: primary
#
#  id                :bigint           not null, primary key
#  deposited         :text             not null
#  extraction_date   :date
#  nav               :text             not null
#  not_net_deposited :text             not null
#  profit            :text             not null
#  withdrawn         :text             not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  goal_id           :bigint           not null
#
# Indexes
#
#  index_goal_snapshots_on_goal_id  (goal_id)
#
# Foreign Keys
#
#  fk_rails_...  (goal_id => goals.id)
#

require "test_helper"

class GoalSnapshotTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
