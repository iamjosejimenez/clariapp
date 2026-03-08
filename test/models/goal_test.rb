# frozen_string_literal: true

# == Schema Information
#
# Table name: goals
# Database name: primary
#
#  id                  :integer          not null, primary key
#  deposited           :text             not null
#  external_created_at :string
#  name                :string
#  nav                 :text             not null
#  not_net_deposited   :text             not null
#  profit              :text             not null
#  withdrawn           :text             not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  external_account_id :integer
#  external_id         :string
#
# Indexes
#
#  index_goals_on_external_account_id                  (external_account_id)
#  index_goals_on_external_account_id_and_external_id  (external_account_id,external_id) UNIQUE
#
# Foreign Keys
#
#  external_account_id  (external_account_id => external_accounts.id)
#

require "test_helper"

class GoalTest < ActiveSupport::TestCase
  test "requiere external_id unico por cuenta externa" do
    external_account = create(:external_account)
    create(:goal, external_account:, external_id: "goal-123")

    duplicate = build(:goal, external_account:, external_id: "goal-123")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:external_id], "ya esta en uso para esta cuenta externa"
  end

  test "permite repetir external_id en cuentas externas distintas" do
    create(:goal, external_account: create(:external_account), external_id: "goal-123")
    duplicate = build(:goal, external_account: create(:external_account), external_id: "goal-123")

    assert duplicate.valid?
  end
end
