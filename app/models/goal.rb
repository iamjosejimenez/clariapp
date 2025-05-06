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
#  nav                 :text             not null
#  profit              :text             not null
#  not_net_deposited   :text             not null
#  deposited           :text             not null
#  withdrawn           :text             not null
#
# Indexes
#
#  index_goals_on_user_id  (user_id)
#

class Goal < ApplicationRecord
  has_many :goal_snapshots, dependent: :destroy
  belongs_to :user

  encrypts :nav, :profit, :not_net_deposited, :deposited, :withdrawn
end
