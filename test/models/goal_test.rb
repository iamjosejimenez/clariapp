# == Schema Information
#
# Table name: goals
#
#  id                  :integer          not null, primary key
#  external_id         :string
#  name                :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  fintual_user_id     :integer          not null
#  external_created_at :string
#  nav                 :text             not null
#  profit              :text             not null
#  not_net_deposited   :text             not null
#  deposited           :text             not null
#  withdrawn           :text             not null
#
# Indexes
#
#  index_goals_on_fintual_user_id  (fintual_user_id)
#

require "test_helper"

class GoalTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
