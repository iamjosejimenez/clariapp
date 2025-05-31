# == Schema Information
#
# Table name: goal_snapshots
#
#  id                :integer          not null, primary key
#  goal_id           :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  nav               :text             not null
#  profit            :text             not null
#  not_net_deposited :text             not null
#  deposited         :text             not null
#  withdrawn         :text             not null
#  extraction_date   :date
#
# Indexes
#
#  index_goal_snapshots_on_goal_id  (goal_id)
#

class GoalSnapshot < ApplicationRecord
  belongs_to :goal

  encrypts :nav, :profit, :not_net_deposited, :deposited, :withdrawn
end
