# == Schema Information
#
# Table name: goals
#
#  id                  :bigint           not null, primary key
#  deposited           :text             not null
#  external_created_at :string
#  name                :string
#  nav                 :text             not null
#  not_net_deposited   :text             not null
#  profit              :text             not null
#  withdrawn           :text             not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  external_id         :string
#  fintual_user_id     :bigint           not null
#
# Indexes
#
#  index_goals_on_fintual_user_id  (fintual_user_id)
#
# Foreign Keys
#
#  fk_rails_...  (fintual_user_id => fintual_users.id)
#

class Goal < ApplicationRecord
  has_many :goal_snapshots, dependent: :destroy
  belongs_to :fintual_user

  encrypts :nav, :profit, :not_net_deposited, :deposited, :withdrawn
end
