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

require "test_helper"

class GoalTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
