# frozen_string_literal: true

# == Schema Information
#
# Table name: gmail_accounts
#
#  id               :bigint           not null, primary key
#  access_token     :text
#  email            :string           not null
#  refresh_token    :text
#  status           :string           default("active"), not null
#  token_expires_at :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  last_history_id  :string
#  user_id          :bigint           not null
#
# Indexes
#
#  index_gmail_accounts_on_email    (email) UNIQUE
#  index_gmail_accounts_on_user_id  (user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class GmailAccount < ApplicationRecord
  belongs_to :user
  has_many :bank_emails, dependent: :destroy

  STATUSES = %w[active error].freeze

  encrypts :refresh_token
  encrypts :access_token

  enum :status, STATUSES.index_by(&:to_sym), prefix: true

  validates :email, presence: true
  validates :email, uniqueness: {
    message: "ya está vinculado a otro usuario"
  }
  validates :user_id, uniqueness: true

  def token_expired?
    token_expires_at.nil? || token_expires_at <= Time.current
  end
end
