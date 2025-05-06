# == Schema Information
#
# Table name: goal_snapshots
#
#  id                :integer          not null, primary key
#  goal_id           :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  nav               :string
#  profit            :string
#  not_net_deposited :string
#  deposited         :string
#  withdrawn         :string
#
# Indexes
#
#  index_goal_snapshots_on_goal_id  (goal_id)
#

class GoalSnapshot < ApplicationRecord
  belongs_to :goal

  encrypts :nav_encrypted, :profit_encrypted, :not_net_deposited_encrypted, :deposited_encrypted, :withdrawn_encrypted
end
