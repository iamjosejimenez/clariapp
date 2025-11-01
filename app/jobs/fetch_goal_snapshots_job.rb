class FetchGoalSnapshotsJob < ApplicationJob
  queue_as :default

  def perform
    ExternalAccount.where(provider: "fintual").find_each do |user|
      next if user.access_token.blank?

      logger.info "Fetching goal snapshots for user #{user.id}"
      SyncGoalsService.new(user).call
    end
  end
end
