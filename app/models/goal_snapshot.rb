# == Schema Information
#
# Table name: goal_snapshots
#
#  id                :integer          not null, primary key
#  goal_id           :integer          not null
#  nav               :decimal(15, 2)
#  profit            :decimal(15, 2)
#  not_net_deposited :decimal(15, 2)
#  deposited         :decimal(15, 2)
#  withdrawn         :decimal(15, 2)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_goal_snapshots_on_goal_id  (goal_id)
#

class GoalSnapshot < ApplicationRecord
  belongs_to :goal
end
