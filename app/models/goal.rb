# == Schema Information
#
# Table name: goals
#
#  id                          :integer          not null, primary key
#  external_id                 :string
#  name                        :string
#  updated_at                  :datetime         not null
#  user_id                     :integer          not null
#  created_at                  :datetime         not null
#  external_created_at         :string
#  nav_encrypted               :text
#  profit_encrypted            :text
#  not_net_deposited_encrypted :text
#  deposited_encrypted         :text
#  withdrawn_encrypted         :text
#
# Indexes
#
#  index_goals_on_user_id  (user_id)
#

class Goal < ApplicationRecord
  has_many :goal_snapshots, dependent: :destroy
  belongs_to :user

  encrypts :nav_encrypted, :profit_encrypted, :not_net_deposited_encrypted, :deposited_encrypted, :withdrawn_encrypted

  def nav
    BigDecimal(nav_encrypted || "0")
  end

  def profit
    BigDecimal(profit_encrypted || "0")
  end

  def not_net_deposited
    BigDecimal(not_net_deposited_encrypted || "0")
  end

  def deposited
    BigDecimal(deposited_encrypted || "0")
  end

  def withdrawn
    BigDecimal(withdrawn_encrypted || "0")
  end
end
