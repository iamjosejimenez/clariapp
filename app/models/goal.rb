# == Schema Information
#
# Table name: goals
#
#  id          :integer          not null, primary key
#  external_id :string
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :integer          not null
#
# Indexes
#
#  index_goals_on_user_id  (user_id)
#

class Goal < ApplicationRecord
  has_many :goal_snapshots, dependent: :destroy
  belongs_to :user
end
