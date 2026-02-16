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
#  index_goals_on_external_account_id  (external_account_id)
#
# Foreign Keys
#
#  external_account_id  (external_account_id => external_accounts.id)
#

class Goal < ApplicationRecord
  has_many :goal_snapshots, dependent: :destroy
  belongs_to :external_account

  encrypts :nav, :profit, :not_net_deposited, :deposited, :withdrawn
end
