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

require "test_helper"

class GoalTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
