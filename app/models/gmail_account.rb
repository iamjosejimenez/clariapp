# frozen_string_literal: true

# == Schema Information
#
# Table name: gmail_accounts
#
#  id               :bigint           not null, primary key
#  access_token     :text
#  email            :string           not null
#  last_synced_at   :datetime
#  refresh_token    :text
#  status           :string           default("active"), not null
#  sync_status      :string           default("idle"), not null
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
  # Tracks the manual/scheduled import lifecycle, kept separate from `status`
  # (which reflects the OAuth connection health: active vs. revoked/expired).
  SYNC_STATUSES = %w[idle syncing synced failed].freeze

  encrypts :refresh_token
  encrypts :access_token

  enum :status, STATUSES.index_by(&:to_sym), prefix: true
  enum :sync_status, SYNC_STATUSES.index_by(&:to_sym), prefix: :sync

  validates :email, presence: true
  validates :email, uniqueness: {
    message: "ya está vinculado a otro usuario"
  }
  validates :user_id, uniqueness: true

  # Re-renders the Gmail status card over ActionCable (solid_cable) whenever the
  # sync lifecycle advances, so the page reflects progress without a reload.
  after_update_commit :broadcast_sync_status, if: :saved_change_to_sync_status?

  def token_expired?
    token_expires_at.nil? || token_expires_at <= Time.current
  end

  private

  def broadcast_sync_status
    broadcast_replace_to(
      self,
      target: ActionView::RecordIdentifier.dom_id(self, :status_card),
      partial: "gmail_sessions/status_card",
      locals: { gmail_account: self }
    )
  end
end
