# == Schema Information
#
# Table name: goal_snapshots
#
#  id                          :integer          not null, primary key
#  goal_id                     :integer          not null
#  nav                         :decimal(15, 2)
#  profit                      :decimal(15, 2)
#  not_net_deposited           :decimal(15, 2)
#  deposited                   :decimal(15, 2)
#  withdrawn                   :decimal(15, 2)
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

class GoalSnapshot < ApplicationRecord
  belongs_to :goal

  encrypts :nav_encrypted, :profit_encrypted, :not_net_deposited_encrypted, :deposited_encrypted, :withdrawn_encrypted
end
