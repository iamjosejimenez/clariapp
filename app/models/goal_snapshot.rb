# == Schema Information
#
# Table name: goal_snapshots
# Database name: primary
#
#  id                :integer          not null, primary key
#  deposited         :text             not null
#  extraction_date   :date
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

class GoalSnapshot < ApplicationRecord
  belongs_to :goal

  encrypts :nav, :profit, :not_net_deposited, :deposited, :withdrawn
end
