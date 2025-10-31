# == Schema Information
#
# Table name: external_accounts
#
#  id           :bigint           not null, primary key
#  access_token :string
#  provider     :string
#  status       :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_external_accounts_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class ExternalAccount < ApplicationRecord
  belongs_to :user

  PROVIDERS = %w[fintual tests].freeze
  STATUSES  = %w[active error].freeze

  enum :status, STATUSES.index_by(&:to_sym), prefix: true

  validates :provider, presence: true, inclusion: { in: PROVIDERS }
end
